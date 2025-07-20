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
    @State private var showInputField = false
    @State private var showSecondaryElements = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var animatedKeyboardOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var lastCalculatedOffset: CGFloat = 0

    @State private var chatBubbleFrames: [UUID: CGRect] = [:]
    @State private var inputFieldFrame: CGRect = .zero
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var tutorialManager = TutorialManager()
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightInputField = false
    @State private var bubbleFrameChangeWorkItem: DispatchWorkItem?
    @State private var isTransitioning = false
    // Removed manualScrollOffset - keyboard offset handles all positioning
    
    // Unified scroll manager
    @StateObject private var scrollManager = ScrollManager()
    
    // MARK: - Configuration
    let conversationSteps: [ConversationStep]
    let profileImage: String
    @Binding var userName: String
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
        userName: Binding<String>,
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
        self._userName = userName
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
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: contentTopSpacing)
                            
                            // Chat Content
                            ChatContentView(
                                messages: messages,
                                currentStep: currentStep,
                                onboardingConversationSteps: conversationSteps,
                                showInputField: showInputField,
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
                                }
                            )
                            
                            // Input
                            ChatInputView(
                                currentStep: currentStep,
                                onboardingConversationSteps: conversationSteps,
                                showInputField: showInputField,
                                showSecondaryElements: showSecondaryElements,
                                currentInput: $currentInput,
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                onSend: { handleSendWithRecordingCheck() },
                                onDateSelected: { date in
                                    print("🔍 [PickerDebug] Date picker submitted")
                                    scrollManager.cancelPendingScroll()
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    let formattedDate = formatter.string(from: date)
                                    
                                    // Add delay for picker submission
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        handleUserInput(input: formattedDate)
                                    }
                                },
                                onTimeSelected: { time in
                                    print("🔍 [PickerDebug] Time picker submitted")
                                    scrollManager.cancelPendingScroll()
                                    let formatter = DateFormatter()
                                    formatter.timeStyle = .short
                                    let formattedTime = formatter.string(from: time)
                                    
                                    // Add delay for picker submission
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        handleUserInput(input: formattedTime)
                                    }
                                },
                                onUnknownTime: {
                                    print("🔍 [PickerDebug] Unknown time submitted")
                                    scrollManager.cancelPendingScroll()
                                    
                                    // Add delay for picker submission
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        handleUserInput(input: "Unknown")
                                    }
                                },
                                isTextFieldFocused: $isTextFieldFocused,
                                onFrameChange: { frame in
                                    // Track input field frame for keyboard offset calculation
                                    inputFieldFrame = frame
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
                        if let lastMessage = messages.last {
                            print("🔍 [ScrollDebug] New message added - isUser: \(lastMessage.isUser), text: \(String(lastMessage.text.prefix(50)))...")
                            print("🔍 [ScrollDebug] keyboardHeight: \(keyboardHeight), isTransitioning: \(isTransitioning)")
                            
                            if lastMessage.isUser {
                                // New response bubble appeared - don't scroll, just trigger next question
                                print("🔍 [ScrollDebug] Response bubble added - no scroll needed")
                                
                                // Trigger next question after response bubble is displayed with additional delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    if currentStep < conversationSteps.count {
                                        let nextMessage = conversationSteps[currentStep].message
                                        print("🔍 [PersonalizationDebug] Current userName: '\(userName)'")
                                        print("🔍 [PersonalizationDebug] Next message template: '\(nextMessage)'")
                                        let personalizedMessage = personalizeMessage(nextMessage, userName)
                                        print("🔍 [PersonalizationDebug] Personalized message: '\(personalizedMessage)'")
                                        displayQuestionMessage(personalizedMessage)
                                    }
                                }
                            } else {
                                // New AI question appeared - scroll to show entire bubble in frame
                                // Always scroll for new question bubbles
                                
                                print("🔍 [ScrollDebug] currentStep: \(currentStep)")
                                
                                if keyboardHeight == 0 && !isTransitioning {
                                    print("🔍 [ScrollDebug] ✅ Scheduling scroll for new question bubble")
                                    scrollManager.scheduleScroll(to: .lastMessage, proxy: proxy, delay: 0.3, messageId: lastMessage.id)
                                } else {
                                    print("🔍 [ScrollDebug] ❌ Skipping scroll for question bubble - keyboardHeight: \(keyboardHeight), isTransitioning: \(isTransitioning)")
                                }
                            }
                        }
                    }
                    .onChange(of: isTyping) { _, newValue in
                        if newValue {
                            // Only scroll if keyboard is not visible and input field is visible
                            if keyboardHeight == 0 && showInputField && showSecondaryElements {
                                scrollManager.scheduleScroll(to: .typing, proxy: proxy, delay: 0.3)
                            }
                        }
                    }
                    .onChange(of: tutorialManager.showVoiceTutorial) { _, newValue in
                        if newValue {
                            // Only scroll if keyboard is not visible and input field is visible
                            if keyboardHeight == 0 && showInputField && showSecondaryElements {
                                scrollManager.scheduleScroll(to: .input, proxy: proxy, delay: 0.3)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: -totalScrollOffset)
                .zIndex(1)
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
            
            // Cancel any pending frame change work
            bubbleFrameChangeWorkItem?.cancel()
            
            let workItem = DispatchWorkItem {
                
                // Calculate offset using only the chat bubble bottom
                let screenHeight = UIScreen.main.bounds.height
                let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
                let bottomSafeArea = safeAreaInsets.bottom
                let bubbleBottom = lastBubbleFrame.maxY
                let keyboardTop = screenHeight - self.keyboardHeight - bottomSafeArea
                let availableSpace = keyboardTop - bubbleBottom
                
                // Only adjust if there's a significant overlap (more than 10 points)
                guard availableSpace < -10 else { return }
                
                let targetOffset: CGFloat
                let offset = abs(availableSpace)
                // Add 20 points of padding so the bubble isn't flush with the keyboard
                let paddingOffset: CGFloat = 20
                let totalOffset = offset + paddingOffset
                targetOffset = round(totalOffset / 10) * 10
                
                // The target offset should be ADDITIONAL to the current position
                let finalOffset: CGFloat
                if targetOffset > 0 {
                    // We need additional offset - add it to the current offset
                    finalOffset = self.lastCalculatedOffset + targetOffset
                } else {
                    // No additional offset needed, but don't reduce below what we had
                    finalOffset = max(self.lastCalculatedOffset, 0)
                }
                
                print("🔧 [BubbleFrameChange] bubbleBottom: \(bubbleBottom), keyboardTop: \(keyboardTop), availableSpace: \(availableSpace)")
                print("🔧 Target offset: \(targetOffset), Final offset: \(finalOffset), Last calculated: \(self.lastCalculatedOffset)")
                
                // Only animate if there's a significant change (more than 5 points)
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
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        let bottomSafeArea = safeAreaInsets.bottom
        
        // Get the bubble's bottom position from the top of the screen
        let bubbleBottomFromTop = getLastChatBubbleBottomFromTop()
        
        // If bubble position is not available, use a reasonable estimate
        guard bubbleBottomFromTop > 0 else { return 0 }
        
        // Check if keyboard is covering the bubble
        // Account for the fact that ScrollView ignores bottom safe area
        let keyboardTop = screenHeight - keyboardHeight - bottomSafeArea
        let availableSpace = keyboardTop - bubbleBottomFromTop
        
        print("🔧 [calculateKeyboardOffset] bubbleBottomFromTop: \(bubbleBottomFromTop)")
        print("🔧 [calculateKeyboardOffset] keyboardTop: \(keyboardTop), bottomSafeArea: \(bottomSafeArea)")
        print("🔧 [calculateKeyboardOffset] availableSpace: \(availableSpace)")
        
        // If keyboard is covering the bubble, move it up
        if availableSpace < 0 {
            let offset = abs(availableSpace)
            // Add 20 points of padding so the bubble isn't flush with the keyboard
            let paddingOffset: CGFloat = 20
            let totalOffset = offset + paddingOffset
            let roundedOffset = round(totalOffset / 10) * 10
            print("🔧 [calculateKeyboardOffset] calculated offset: \(roundedOffset) (base: \(offset) + padding: \(paddingOffset))")
            return roundedOffset
        }
        
        print("🔧 [calculateKeyboardOffset] no offset needed")
        return 0
    }
    
    private func getLastChatBubbleBottomFromTop() -> CGFloat {
        // If input field is visible and has a valid frame, use that instead
        if showInputField && showSecondaryElements && inputFieldFrame.height > 0 {
            print("🔧 [getLastChatBubbleBottomFromTop] Using input field frame maxY: \(inputFieldFrame.maxY)")
            return inputFieldFrame.maxY
        }
        
        guard let lastMessage = messages.last else { return 0 }
        
        // Use actual tracked bubble frame if available
        if let lastBubbleFrame = chatBubbleFrames[lastMessage.id] {
            // Return the bubble's bottom position from the top of the screen
            print("🔧 [getLastChatBubbleBottomFromTop] Raw frame maxY: \(lastBubbleFrame.maxY)")
            return lastBubbleFrame.maxY
        }
        
        // Fallback to estimation if frame not tracked yet
        let estimatedBubbleHeight: CGFloat = 60 // Average bubble height
        let spacing: CGFloat = 16 // Spacing between bubbles
        let topSpacing: CGFloat = contentTopSpacing
        
        let estimatedBottom = topSpacing + (CGFloat(messages.count) * (estimatedBubbleHeight + spacing))
        print("🔧 [getLastChatBubbleBottomFromTop] Using estimated frame: \(estimatedBottom)")
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
        showInputField = false
        showSecondaryElements = false
        
        let initialMessage = conversationSteps[0].message
        print("🔍 [PersonalizationDebug] Initial userName: '\(userName)'")
        print("🔍 [PersonalizationDebug] Initial message template: '\(initialMessage)'")
        let personalizedInitialMessage = personalizeMessage(initialMessage, userName)
        print("🔍 [PersonalizationDebug] Initial personalized message: '\(personalizedInitialMessage)'")
        let typingDelay = calculateTypingDelay(for: personalizedInitialMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                isTyping = false
                let questionMessage = ChatMessage(
                    text: personalizedInitialMessage,
                    isUser: false,
                    timestamp: Date()
                )
                withAnimation {
                    messages.append(questionMessage)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showSecondaryElements = true
                        showInputField = true
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
        
        // Cancel any pending scrolls immediately when user submits input
        scrollManager.cancelPendingScroll()
        
        // Set transition state to prevent scrolling when response bubble disappears
        print("🔍 [TransitionDebug] Setting isTransitioning = true")
        isTransitioning = true
        
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
        
        // Reset transition state after the response bubble is displayed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔍 [TransitionDebug] Setting isTransitioning = false (after user input)")
            isTransitioning = false
        }
    }
    
    private func displayQuestionMessage(_ text: String) {
        isTyping = true
        showInputField = false
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
            
            // Add delay between question bubble and response input field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showSecondaryElements = true
                    if currentStep < onboardingConversationSteps.count {
                        showInputField = true
                    }
                }
            }
            
            // Reset transition state after the AI message is displayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔍 [TransitionDebug] Setting isTransitioning = false (after AI message)")
                isTransitioning = false
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
    let showInputField: Bool
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
    
    init(messages: [ChatMessage], currentStep: Int, onboardingConversationSteps: [ConversationStep], showInputField: Bool, showSecondaryElements: Bool, selectedDate: Binding<Date>, selectedTime: Binding<Date>, isTyping: Bool, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, tutorialManager: TutorialManager, onBubbleSizeChange: ((ChatMessage, CGSize) -> Void)? = nil, onBubbleFrameChange: ((ChatMessage, CGRect) -> Void)? = nil) {
        self.messages = messages
        self.currentStep = currentStep
        self.onboardingConversationSteps = onboardingConversationSteps
        self.showInputField = showInputField
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
        VStack(spacing: 0) {
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
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let onSend: () -> Void
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let isTextFieldFocused: FocusState<Bool>.Binding
    let onFrameChange: (CGRect) -> Void
    let tutorialManager: TutorialManager
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
        
    var body: some View {
        if currentStep < onboardingConversationSteps.count && !onboardingConversationSteps[currentStep].isFinal {
            let isVisible = showInputField && showSecondaryElements
            
            VStack(spacing: 0) {
                // Response chat bubble
                ResponseChatBubble(
                    currentStep: onboardingConversationSteps[currentStep],
                    currentInput: currentInput,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onSend: onSend,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime,
                    onFrameChange: onFrameChange,
                    highlightInputField: $highlightInputField,
                    onHeightChange: onHeightChange
                )
                .transition(.opacity)
                .opacity(isVisible ? 1 : 0)
                .allowsHitTesting(isVisible)
            }
        }
    }
}

// MARK: - Scroll Manager
// Unified Scroll Manager for efficient scrolling
class ScrollManager: ObservableObject {
    private var scrollWorkItem: DispatchWorkItem?
    private var lastScrollTime: Date = Date()
    private let minimumScrollInterval: TimeInterval = 0.3
    private var isScrolling = false
    
    enum ScrollTarget {
        case bottom
        case input
        case picker
        case typing
        case lastMessage
    }
    
    func scheduleScroll(to target: ScrollTarget, proxy: ScrollViewProxy, delay: Double = 0.0, messageId: UUID? = nil) {
        print("🔍 [ScrollManager] Scheduling scroll to \(target) with delay: \(delay), messageId: \(messageId?.uuidString.prefix(8) ?? "nil")")
        
        // Don't schedule if already scrolling
        guard !isScrolling else { 
            print("🔍 [ScrollManager] ❌ Already scrolling, skipping")
            return 
        }
        
        // Cancel any pending scroll
        scrollWorkItem?.cancel()
        
        // Check if enough time has passed since last scroll
        let timeSinceLastScroll = Date().timeIntervalSince(lastScrollTime)
        var adjustedDelay = delay
        if timeSinceLastScroll < minimumScrollInterval {
            adjustedDelay += minimumScrollInterval - timeSinceLastScroll
            print("🔍 [ScrollManager] Adjusted delay to \(adjustedDelay) (timeSinceLastScroll: \(timeSinceLastScroll))")
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            print("🔍 [ScrollManager] Executing scroll to \(target)")
            self?.performScroll(to: target, proxy: proxy, messageId: messageId)
            self?.lastScrollTime = Date()
        }
        
        scrollWorkItem = workItem
        
        if adjustedDelay > 0 {
            print("🔍 [ScrollManager] Scheduling scroll with delay: \(adjustedDelay)")
            DispatchQueue.main.asyncAfter(deadline: .now() + adjustedDelay, execute: workItem)
        } else {
            print("🔍 [ScrollManager] Executing scroll immediately")
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    private func performScroll(to target: ScrollTarget, proxy: ScrollViewProxy, messageId: UUID? = nil) {
        print("🔍 [ScrollManager] Performing scroll to \(target)")
        isScrolling = true
        
        withAnimation(.easeInOut(duration: 0.6)) { 
            switch target {
            case .bottom:
                print("🔍 [ScrollManager] Scrolling to bottom")
                proxy.scrollTo("bottom", anchor: .bottom)
            case .input:
                print("🔍 [ScrollManager] Scrolling to input section")
                proxy.scrollTo("inputSection", anchor: .bottom)
            case .picker:
                print("🔍 [ScrollManager] Scrolling to picker")
                proxy.scrollTo("interactivePicker", anchor: .center)
            case .typing:
                print("🔍 [ScrollManager] Scrolling to typing indicator")
                proxy.scrollTo("typingIndicator", anchor: .center)
            case .lastMessage:
                if let messageId = messageId {
                    print("🔍 [ScrollManager] Scrolling to message: \(messageId.uuidString.prefix(8))")
                    proxy.scrollTo(messageId, anchor: .center)
                } else {
                    print("🔍 [ScrollManager] Scrolling to chat bottom")
                    proxy.scrollTo("chatBottom", anchor: .center)
                }
            }
        }
        
        // Reset scrolling flag after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            print("🔍 [ScrollManager] Scroll animation completed, resetting isScrolling")
            self.isScrolling = false
        }
    }
    
    func cancelPendingScroll() {
        scrollWorkItem?.cancel()
        isScrolling = false
    }
}
