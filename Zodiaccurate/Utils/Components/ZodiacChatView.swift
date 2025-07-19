import SwiftUI
import SwiftData
import Combine

/// A reusable zodiac-themed chat interface component
struct ZodiacChatView: View {
    // MARK: - Properties
    @State private var messages: [ChatMessage] = []
    @State private var currentInput = ""
    @State private var currentStep = 0
    @State private var isTyping = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var showInteractivePicker = false
    @State private var showInputField = false
    @State private var showSecondaryElements = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var animatedKeyboardOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var lastCalculatedOffset: CGFloat = 0

    @State private var chatBubbleFrames: [UUID: CGRect] = [:]
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var tutorialManager = TutorialManager()
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightInputField = false
    @State private var bubbleFrameChangeWorkItem: DispatchWorkItem?
    // Removed manualScrollOffset - keyboard offset handles all positioning
    
    // Unified scroll manager
    @StateObject private var scrollManager = ScrollManager()
    
    // MARK: - Configuration
    let conversationSteps: [ConversationStep]
    let profileImage: String
    let onUserDataUpdate: (String, ConversationStep) -> Void
    let onStepComplete: (Int) -> Void
    let onConversationComplete: () -> Void
    let personalizeMessage: (String, String) -> String
    let determineZodiacSign: (String) -> String
    let triggerBadgeAnimation: (String) -> Void
    let badgeAnimationManager: BadgeAnimationManager
    
    // MARK: - Initialization
    init(
        conversationSteps: [ConversationStep],
        profileImage: String = "logo",
        onUserDataUpdate: @escaping (String, ConversationStep) -> Void,
        onStepComplete: @escaping (Int) -> Void,
        onConversationComplete: @escaping () -> Void,
        personalizeMessage: @escaping (String, String) -> String,
        determineZodiacSign: @escaping (String) -> String,
        triggerBadgeAnimation: @escaping (String) -> Void,
        badgeAnimationManager: BadgeAnimationManager
    ) {
        self.conversationSteps = conversationSteps
        self.profileImage = profileImage
        self.onUserDataUpdate = onUserDataUpdate
        self.onStepComplete = onStepComplete
        self.onConversationComplete = onConversationComplete
        self.personalizeMessage = personalizeMessage
        self.determineZodiacSign = determineZodiacSign
        self.triggerBadgeAnimation = triggerBadgeAnimation
        self.badgeAnimationManager = badgeAnimationManager
    }
    
    // MARK: - Computed Properties
    private var scrollViewOffset: CGFloat {
        return max(headerHeight * 0.5, 100)
    }
    
    private var contentTopSpacing: CGFloat {
        return headerHeight + ZodiacHeader.profileBadgeHeight()
    }
    
    private var contentTopPadding: CGFloat {
        return max(headerHeight * 0.67, 80)
    }
    

    
    private var totalScrollOffset: CGFloat {
        return scrollViewOffset + animatedKeyboardOffset
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background layers
            ZodiacAuroraBackground()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    isTextFieldFocused = false
                }
            
            VStack(spacing: 0) {
                // Header Component
                ZodiacHeader(
                    profileImage: badgeAnimationManager.currentProfileImage,
                    badgeScale: badgeAnimationManager.badgeScale,
                    badgeRotation: badgeAnimationManager.badgeRotation,
                    cosmicGlowOpacity: badgeAnimationManager.cosmicGlowOpacity,
                    nebulaOpacity: badgeAnimationManager.nebulaOpacity,
                    starFieldOpacity: badgeAnimationManager.starFieldOpacity,
                    cosmicParticlesOpacity: badgeAnimationManager.cosmicParticlesOpacity,
                    sparkleOpacity: badgeAnimationManager.sparkleOpacity
                )
                
                // Chat ScrollView
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            Spacer().frame(height: contentTopSpacing)
                            
                            // Chat Content
                            ChatContentView(
                                messages: messages,
                                currentStep: currentStep,
                                onboardingConversationSteps: conversationSteps,
                                showInteractivePicker: showInteractivePicker,
                                showSecondaryElements: showSecondaryElements,
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                isTyping: isTyping,
                                onDateSelected: { date in
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    handleUserInput(input: formatter.string(from: date))
                                },
                                onTimeSelected: { time in
                                    let formatter = DateFormatter()
                                    formatter.timeStyle = .short
                                    handleUserInput(input: formatter.string(from: time))
                                },
                                onUnknownTime: {
                                    handleUserInput(input: "Unknown")
                                },
                                tutorialManager: tutorialManager,
                                onBubbleSizeChange: { message, size in
                                    // Track chat bubble frames for keyboard offset calculation
                                    // Store the frame data for this message
                                    // Note: This currently only gets size, not position
                                    // For full frame tracking, we'd need to modify the callback to pass CGRect
                                },
                                onBubbleFrameChange: { message, frame in
                                    // Track the actual frame of each chat bubble
                                    chatBubbleFrames[message.id] = frame
                                    print("🔧 [BubbleFrame] Message \(message.id): \(frame)")
                                    print("🔧 [BubbleFrame] Frame maxY: \(frame.maxY), Screen height: \(UIScreen.main.bounds.height)")
                                    print("🔧 [BubbleFrame] Keyboard height: \(keyboardHeight), totalScrollOffset: \(totalScrollOffset)")
                                }
                            )
                            
                            // Input
                            ChatInputView(
                                currentStep: currentStep,
                                onboardingConversationSteps: conversationSteps,
                                showInputField: showInputField,
                                showSecondaryElements: showSecondaryElements,
                                currentInput: $currentInput,
                                onSend: { handleSendWithRecordingCheck() },
                                isTextFieldFocused: $isTextFieldFocused,
                                onFrameChange: { frame in
                                    // No longer tracking text field frame changes
                                },
                                tutorialManager: tutorialManager,
                                highlightInputField: $highlightInputField,
                                onHeightChange: { heightDifference in
                                    // Keyboard offset handles all positioning
                                    // No need for manual scroll adjustments
                                }
                            )
                            .id("inputSection")
                            
                            // Complete Button
                            if (currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal && messages.count > 0 && messages.last?.isUser == false) ||
                               currentStep >= conversationSteps.count {
                                Button(action: { 
                                    onConversationComplete()
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text("Complete Conversation")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentGold)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 50)
                                .transition(.opacity)
                            }
                            
                            Color.clear
                                .frame(height: 1)
                                .padding(.bottom, 50)
                                .id("bottom")
                        }
                        .padding(.horizontal)
                        .padding(.top, -contentTopPadding)
                    }
                    .scrollDisabled(true)
                    .scrollDismissesKeyboard(.interactively)
                    .clipped()
                    .ignoresSafeArea(.container, edges: .bottom)
                    .coordinateSpace(name: "ScrollView")
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last, !lastMessage.isUser {
                            scrollManager.scheduleScroll(to: .lastMessage, proxy: proxy, delay: 0.1, messageId: lastMessage.id)
                        }
                    }
                    .onChange(of: isTyping) { _, newValue in
                        if newValue {
                            scrollManager.scheduleScroll(to: .typing, proxy: proxy, delay: 0.1)
                        }
                    }
                    .onChange(of: tutorialManager.showVoiceTutorial) { _, newValue in
                        if newValue {
                            scrollManager.scheduleScroll(to: .input, proxy: proxy, delay: 0.1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: -totalScrollOffset)
                .zIndex(1)
                .border(Color.red, width: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showZodiacAlert {
                ZodiacAlertView(
                    title: "Error",
                    message: zodiacAlertMessage,
                    primaryButtonTitle: "OK",
                    primaryButtonAction: {
                        showZodiacAlert = false
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            startConversation()
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            self.headerHeight = headerHeight
        }
        .onReceive(Publishers.keyboardHeight) { keyboardHeight in
            self.keyboardHeight = keyboardHeight
            
            // Only calculate offset when keyboard first appears or disappears
            // Don't recalculate while user is typing
            if (keyboardHeight > 0 && self.lastCalculatedOffset == 0) || 
               (keyboardHeight == 0 && self.lastCalculatedOffset > 0) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let targetOffset = self.calculateKeyboardOffset()
                    self.lastCalculatedOffset = targetOffset
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.animatedKeyboardOffset = targetOffset
                        print("🔧 [ScrollView] animatedKeyboardOffset set to: \(targetOffset) (keyboardHeight change)")
                    }
                }
            }
        }
        .onChange(of: chatBubbleFrames) { _, newFrames in
            // Only process if we have frames and keyboard is visible
            guard keyboardHeight > 0, let lastMessage = messages.last,
                  let lastBubbleFrame = newFrames[lastMessage.id] else { return }
            
            print("🔧 [BubbleFrameChange] Last bubble frame: \(lastBubbleFrame)")
            
            // Cancel any pending frame change work
            bubbleFrameChangeWorkItem?.cancel()
            
            let workItem = DispatchWorkItem {
                
                // Calculate offset using only the chat bubble bottom
                let screenHeight = UIScreen.main.bounds.height
                let bubbleBottom = lastBubbleFrame.maxY
                let keyboardTop = screenHeight - self.keyboardHeight
                let availableSpace = keyboardTop - bubbleBottom
                
                let targetOffset: CGFloat
                if availableSpace < 0 {
                    // Bubble is below keyboard - need to move it up by exact overlap
                    let offset = abs(availableSpace)
                    targetOffset = round(offset / 10) * 10
                } else {
                    targetOffset = 0
                }
                
                // The target offset should be ADDITIONAL to the current position
                let finalOffset: CGFloat
                if targetOffset > 0 {
                    // We need additional offset - add it to the current offset
                    finalOffset = self.lastCalculatedOffset + targetOffset
                    print("🔧 [BubbleFrameChange] Adding \(targetOffset) to current offset \(self.lastCalculatedOffset) = \(finalOffset)")
                } else {
                    // No additional offset needed, but don't reduce below what we had
                    finalOffset = max(self.lastCalculatedOffset, 0)
                    print("🔧 [BubbleFrameChange] Maintaining current offset: \(finalOffset)")
                }
                
                print("🔧 [BubbleFrameChange] bubbleBottom: \(bubbleBottom), keyboardTop: \(keyboardTop), availableSpace: \(availableSpace)")
                print("🔧 Target offset: \(targetOffset), Final offset: \(finalOffset), Last calculated: \(self.lastCalculatedOffset)")
                if abs(finalOffset - self.lastCalculatedOffset) > 5 {
                    print("🔧 Adjusting scroll offset from \(self.lastCalculatedOffset) to \(finalOffset)")
                    self.lastCalculatedOffset = finalOffset
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.animatedKeyboardOffset = finalOffset
                        print("🔧 [ScrollView] animatedKeyboardOffset set to: \(finalOffset) (bubble frame change)")
                    }
                }
            }
            
            bubbleFrameChangeWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
        .onDisappear {
            scrollManager.cancelPendingScroll()
            bubbleFrameChangeWorkItem?.cancel()
        }
    }
    
    // MARK: - Helper Functions
    private func calculateKeyboardOffset() -> CGFloat {
        guard keyboardHeight > 0 else { return 0 }
        
        let screenHeight = UIScreen.main.bounds.height
        
        // Get distance from bottom of screen to bubble
        let distanceFromBottom = getLastChatBubbleBottom()
        
        // If distance is not available, use a reasonable estimate
        let finalDistance = (distanceFromBottom > 0) ? distanceFromBottom : screenHeight * 0.2
        
        // Check if keyboard is covering the bubble
        let keyboardTop = screenHeight - keyboardHeight
        let availableSpace = finalDistance - keyboardTop
        
        print("🔧 [calculateKeyboardOffset] distanceFromBottom: \(distanceFromBottom), finalDistance: \(finalDistance)")
        print("🔧 [calculateKeyboardOffset] keyboardTop: \(keyboardTop), availableSpace: \(availableSpace)")
        
        // If keyboard is covering the bubble, move it up
        if availableSpace < 0 {
            let offset = abs(availableSpace)
            let roundedOffset = round(offset / 10) * 10
            print("🔧 [calculateKeyboardOffset] calculated offset: \(roundedOffset)")
            return roundedOffset
        }
        
        print("🔧 [calculateKeyboardOffset] no offset needed")
        return 0
    }
    
    private func getLastChatBubbleBottom() -> CGFloat {
        guard let lastMessage = messages.last else { return 0 }
        
        // Use actual tracked bubble frame if available
        if let lastBubbleFrame = chatBubbleFrames[lastMessage.id] {
            // Calculate distance from bottom of screen to bubble
            let screenHeight = UIScreen.main.bounds.height
            let distanceFromBottom = screenHeight - lastBubbleFrame.maxY
            print("🔧 [getLastChatBubbleBottom] Raw frame maxY: \(lastBubbleFrame.maxY), Screen height: \(screenHeight)")
            print("🔧 [getLastChatBubbleBottom] Distance from bottom: \(distanceFromBottom)")
            return distanceFromBottom
        }
        
        // Fallback to estimation if frame not tracked yet
        let estimatedBubbleHeight: CGFloat = 60 // Average bubble height
        let spacing: CGFloat = 16 // Spacing between bubbles
        let topSpacing: CGFloat = contentTopSpacing
        
        let estimatedBottom = topSpacing + (CGFloat(messages.count) * (estimatedBubbleHeight + spacing))
        print("🔧 [getLastChatBubbleBottom] Using estimated frame: \(estimatedBottom)")
        return estimatedBottom
    }
    
    private func calculateTypingDelay(for text: String) -> Double {
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let characterCount = text.count
        
        let baseDelay: Double = 0.8
        let wordDelay = Double(wordCount) * 0.08
        let characterDelay = characterCount > 200 ? Double(characterCount - 200) * 0.005 : 0
        let maxDelay: Double = 4.0
        let calculatedDelay = baseDelay + wordDelay + characterDelay
        
        return min(calculatedDelay, maxDelay)
    }
    
    private func startConversation() {
        showInteractivePicker = false
        showInputField = false
        showSecondaryElements = false
        
        let initialMessage = conversationSteps[0].message
        let typingDelay = calculateTypingDelay(for: initialMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                isTyping = false
                let questionMessage = ChatMessage(
                    text: initialMessage,
                    isUser: false,
                    timestamp: Date()
                )
                withAnimation {
                    messages.append(questionMessage)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showSecondaryElements = true
                        if conversationSteps[0].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[0].inputType == "date" || 
                                conversationSteps[0].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleSendWithRecordingCheck() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            highlightInputField = true
            return
        }
        highlightInputField = false
        handleUserInput(input: currentInput)
    }
    
    private func handleUserInput(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        tutorialManager.stopTutorial()
        
        let nextStepWillUsePicker = currentStep + 1 < conversationSteps.count && 
                                   (conversationSteps[currentStep + 1].inputType == "date" || 
                                    conversationSteps[currentStep + 1].inputType == "time")
        
        if !nextStepWillUsePicker {
            showInteractivePicker = false
        }
        showInputField = false
        showSecondaryElements = false
        
        let responseMessage = ChatMessage(
            text: input,
            isUser: true,
            timestamp: Date()
        )
        withAnimation {
            messages.append(responseMessage)
        }
        
        onUserDataUpdate(input, conversationSteps[currentStep])
        currentInput = ""
        currentStep += 1
        onStepComplete(currentStep)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if currentStep < conversationSteps.count {
                let nextMessage = conversationSteps[currentStep].message
                addAIMessage(nextMessage)
            }
        }
    }
    
    private func addAIMessage(_ text: String) {
        isTyping = true
        showInputField = false
        if currentStep >= conversationSteps.count || 
           (conversationSteps[currentStep].inputType != "date" && 
            conversationSteps[currentStep].inputType != "time") {
            showInteractivePicker = false
        }
        showSecondaryElements = false
        
        let typingDelay = calculateTypingDelay(for: text)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
            isTyping = false
            let questionMessage = ChatMessage(
                text: text,
                isUser: false,
                timestamp: Date()
            )
            withAnimation {
                messages.append(questionMessage)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showSecondaryElements = true
                    if currentStep < conversationSteps.count {
                        if conversationSteps[currentStep].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[currentStep].inputType == "date" || 
                                conversationSteps[currentStep].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Chat Content View
// Break out the chat content into a separate view
struct ChatContentView: View {
    let messages: [ChatMessage]
    let currentStep: Int
    let onboardingConversationSteps: [ConversationStep]
    let showInteractivePicker: Bool
    let showSecondaryElements: Bool
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let isTyping: Bool
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let tutorialManager: TutorialManager
    let onBubbleSizeChange: ((ChatMessage, CGSize) -> Void)?
    let onBubbleFrameChange: ((ChatMessage, CGRect) -> Void)?
    
    init(messages: [ChatMessage], currentStep: Int, onboardingConversationSteps: [ConversationStep], showInteractivePicker: Bool, showSecondaryElements: Bool, selectedDate: Binding<Date>, selectedTime: Binding<Date>, isTyping: Bool, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, tutorialManager: TutorialManager, onBubbleSizeChange: ((ChatMessage, CGSize) -> Void)? = nil, onBubbleFrameChange: ((ChatMessage, CGRect) -> Void)? = nil) {
        self.messages = messages
        self.currentStep = currentStep
        self.onboardingConversationSteps = onboardingConversationSteps
        self.showInteractivePicker = showInteractivePicker
        self.showSecondaryElements = showSecondaryElements
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.isTyping = isTyping
        self.onDateSelected = onDateSelected
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.tutorialManager = tutorialManager
        self.onBubbleSizeChange = onBubbleSizeChange
        self.onBubbleFrameChange = onBubbleFrameChange
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(messages) { message in
                if message.isUser {
                    // User response - use AnsweredChatBubble
                    AnsweredChatBubble(
                        message: message,
                        onSizeChange: { size in
                            onBubbleSizeChange?(message, size)
                        },
                        onFrameChange: { frame in
                            onBubbleFrameChange?(message, frame)
                        }
                    )
                    .id(message.id)
                    .transition(.opacity)
                } else {
                    // AI question - use QuestionChatBubble
                    QuestionChatBubble(
                        message: message,
                        onSizeChange: { size in
                            onBubbleSizeChange?(message, size)
                        },
                        onFrameChange: { frame in
                            onBubbleFrameChange?(message, frame)
                        }
                    )
                    .id(message.id)
                    .transition(.opacity)
                }
            }
            
            if currentStep < onboardingConversationSteps.count {
                let showPicker = !onboardingConversationSteps[currentStep].isFinal &&
                                 showInteractivePicker &&
                                 showSecondaryElements

                InteractivePickerView(
                    step: onboardingConversationSteps[currentStep],
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime
                )
                .opacity(showPicker ? 1 : 0)
                .allowsHitTesting(showPicker)
            }
            
            TypingIndicator(isAnimating: isTyping)
                .opacity(isTyping ? 1 : 0)
                .id("typingIndicator")

            // Ensure we always have a bottom anchor for scrolling
            Color.clear
                .frame(height: 1)
                .id("chatBottom")
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                print("--- minY: \(geo.frame(in: .global).minY), maxY: \(geo.frame(in: .global).maxY)")
                            }
                    }
                )
        }
        .padding(.horizontal)
        .padding(.bottom, 12) // Ensure minimum 12px padding from bottom
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showSecondaryElements)
    }
}

// MARK: - Chat Input View
// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let onboardingConversationSteps: [ConversationStep]
    let showInputField: Bool
    let showSecondaryElements: Bool
    let currentInput: Binding<String>
    let onSend: () -> Void
    let isTextFieldFocused: FocusState<Bool>.Binding
    let onFrameChange: (CGRect) -> Void
    let tutorialManager: TutorialManager
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
        
    var body: some View {
        if currentStep < onboardingConversationSteps.count && !onboardingConversationSteps[currentStep].isFinal {
            let isVisible = onboardingConversationSteps[currentStep].inputType == "text" &&
                            showInputField &&
                            showSecondaryElements
            
            VStack(spacing: 0) {
                // Response chat bubble
                ResponseChatBubble(
                    currentStep: onboardingConversationSteps[currentStep],
                    currentInput: currentInput,
                    onSend: onSend,
                    onFrameChange: onFrameChange,
                    highlightInputField: $highlightInputField,
                    onHeightChange: onHeightChange
                )
                .transition(.opacity)
                .opacity(isVisible ? 1 : 0)
                .allowsHitTesting(isVisible)
            }
            .padding(.bottom, 12) // Ensure minimum 12px padding from bottom
        }
    }
}

// MARK: - Scroll Manager
// Unified Scroll Manager for efficient scrolling
class ScrollManager: ObservableObject {
    private var scrollWorkItem: DispatchWorkItem?
    private var lastScrollTime: Date = Date()
    private let minimumScrollInterval: TimeInterval = 0.1
    
    enum ScrollTarget {
        case bottom
        case input
        case picker
        case typing
        case lastMessage
    }
    
    func scheduleScroll(to target: ScrollTarget, proxy: ScrollViewProxy, delay: Double = 0.0, messageId: UUID? = nil) {
        // Cancel any pending scroll
        scrollWorkItem?.cancel()
        
        // Check if enough time has passed since last scroll
        let timeSinceLastScroll = Date().timeIntervalSince(lastScrollTime)
        var adjustedDelay = delay
        if timeSinceLastScroll < minimumScrollInterval {
            adjustedDelay += minimumScrollInterval - timeSinceLastScroll
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performScroll(to: target, proxy: proxy, messageId: messageId)
            self?.lastScrollTime = Date()
        }
        
        scrollWorkItem = workItem
        
        if adjustedDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + adjustedDelay, execute: workItem)
        } else {
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    private func performScroll(to target: ScrollTarget, proxy: ScrollViewProxy, messageId: UUID? = nil) {
        withAnimation(.easeInOut(duration: 0.4)) {
            switch target {
            case .bottom:
                proxy.scrollTo("bottom", anchor: .bottom)
            case .input:
                proxy.scrollTo("inputSection", anchor: .bottom)
            case .picker:
                proxy.scrollTo("interactivePicker", anchor: .center)
            case .typing:
                proxy.scrollTo("typingIndicator", anchor: .center)
            case .lastMessage:
                if let messageId = messageId {
                    proxy.scrollTo(messageId, anchor: .center)
                } else {
                    proxy.scrollTo("chatBottom", anchor: .center)
                }
            }
        }
    }
    
    func cancelPendingScroll() {
        scrollWorkItem?.cancel()
    }
}
