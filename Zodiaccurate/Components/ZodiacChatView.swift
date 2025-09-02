import SwiftUI
import Combine

// MARK: - Chat Top Inset Mode
enum ChatTopInsetMode {
    case compact   // For compact header (3/4 height)
    case large     // For initial/full header height
}

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
    @State private var showResponseChatBubble = false
    @State private var showTutorialBubble = false
    @StateObject private var keyboardManager = KeyboardManager()
    @State private var headerHeight: CGFloat = 0
    @State private var previousResponses: [String] = []

    @State private var inputFieldFrame: CGRect = .zero
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var tutorialManager = TutorialManager()
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightInputField = false
    @State private var scrollViewOffset: CGFloat = 0
    @State private var headerFrame: CGRect = .zero
    @State private var responseBubbleOpacity: Double = 0.0
    @State private var tutorialBubbleOpacity: Double = 0.0
    @State private var headerDisplayMode: ZodiacHeaderDisplayMode = .initial
    
    // MARK: - Auto-scroll Properties
    @State private var isUserAtBottom = true
    @State private var isUserAtTop = true
    @State private var lastMessageCount = 0
    @State private var shouldScrollToBottom = false
    @State private var scrollDebounceTimer: Timer?
    
    // MARK: - Configuration
    let conversationSteps: [ConversationStep]
    let profileImage: String
    @Binding var userName: String
    let userData: User
    let onUserDataUpdate: (String, ConversationStep) -> Void
    let onStepComplete: (Int) -> Void
    let onConversationComplete: () -> Void
    let personalizeMessage: (String, String) -> String
    let determineZodiacSign: (String) -> String
    let triggerBadgeAnimation: (String) -> Void
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    let topInsetMode: ChatTopInsetMode
    
    // MARK: - Initialization
    init(
        conversationSteps: [ConversationStep],
        profileImage: String = "logo",
        userName: Binding<String>,
        userData: User,
        onUserDataUpdate: @escaping (String, ConversationStep) -> Void,
        onStepComplete: @escaping (Int) -> Void,
        onConversationComplete: @escaping () -> Void,
        personalizeMessage: @escaping (String, String) -> String,
        determineZodiacSign: @escaping (String) -> String,
        triggerBadgeAnimation: @escaping (String) -> Void,
        backgroundColor: Color? = nil,
        bubbleColor: ChatBubbleColor? = nil,
        topInsetMode: ChatTopInsetMode = .large
    ) {
        self.conversationSteps = conversationSteps
        self.profileImage = profileImage
        self._userName = userName
        self.userData = userData
        self.onUserDataUpdate = onUserDataUpdate
        self.onStepComplete = onStepComplete
        self.onConversationComplete = onConversationComplete
        self.personalizeMessage = personalizeMessage
        self.determineZodiacSign = determineZodiacSign
        self.triggerBadgeAnimation = triggerBadgeAnimation
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
        self.topInsetMode = topInsetMode
    }
    
    // MARK: - Computed Properties
    private var headerTopInset: CGFloat {
        let base = ZodiacHeader.profileBadgeHeight()
        switch topInsetMode {
        case .large:
            return max(base - 10, 0)
        case .compact:
            return max(base * 0.75 - 10, 0)
        }
    }
    
    private var totalScrollOffset: CGFloat {
        return keyboardManager.animatedKeyboardOffset
    }
    
    private var shouldShowCompleteButton: Bool {
        let isFinalStep = currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal
        let hasMessages = messages.count > 0
        let lastMessageIsAI = messages.last?.isUser == false
        let isConversationComplete = currentStep >= conversationSteps.count
        
        return (isFinalStep && hasMessages && lastMessageIsAI) || isConversationComplete
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private var backgroundView: some View {
        ZodiacAuroraBackground()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .onTapGesture {
                isTextFieldFocused = false
            }
    }

    @ViewBuilder
    private var tapToContinueLabel: some View {
        if shouldShowCompleteButton {
            HStack {
                Spacer()
                TapAnywhere()
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding(.bottom, 50)
        }
    }
    
    @ViewBuilder
    private var bottomAnchorView: some View {
        Color.clear
            .frame(height: 1)
            .padding(.bottom, 50)
            .id("bottomAnchor")
            .onAppear {
                // User scrolled to bottom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isUserAtBottom = true
                }
            }
            .onDisappear {
                // User scrolled away from bottom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isUserAtBottom = false
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Ensure content doesn't extend into safe area
                            let safeAreaBottom = geometry.safeAreaInsets.bottom
                            if safeAreaBottom > 0 {
                                print("🔧 [SafeArea] Bottom safe area detected: \(safeAreaBottom)")
                            }
                        }
                }
            )
    }
    
    @ViewBuilder
    private var topAnchorView: some View {
        Color.clear
            .frame(height: 1)
            .padding(.top, headerTopInset)
            .id("topAnchor")
            .onAppear {
                // User scrolled to top
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isUserAtTop = true
                }
            }
            .onDisappear {
                // User scrolled away from top
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isUserAtTop = false
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Ensure content doesn't extend into safe area
                            let safeAreaTop = geometry.safeAreaInsets.top
                            if safeAreaTop > 0 {
                                print("🔧 [SafeArea] Top safe area detected: \(safeAreaTop)")
                            }
                        }
                }
            )
    }
    

    
    // MARK: - Computed Views
    @ViewBuilder
    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                LazyVStack(alignment: .leading, spacing: 0) {
                    topAnchorView
                        
                    // Chat History Content
                    ChatHistoryContentView(
                        messages: messages,
                        currentStep: currentStep,
                        onboardingConversationSteps: conversationSteps,
                        showInputField: showInputField,
                        showResponseChatBubble: showResponseChatBubble,
                        selectedDate: $selectedDate,
                        selectedTime: $selectedTime,
                        isTyping: isTyping,
                        onDateSelected: handleDateSelected,
                        onTimeSelected: handleTimeSelected,
                        onUnknownTime: handleUnknownTime,
                        tutorialManager: tutorialManager,
                        backgroundColor: backgroundColor,
                        questionBubbleColor: bubbleColor,
                        answeredBubbleColor: bubbleColor
                    )
                    .opacity(calculateContentOpacity())
                    
                    // Input
                    ChatInputView(
                        currentStep: currentStep,
                        conversationSteps: conversationSteps,
                        showInputField: showInputField,
                        showResponseChatBubble: showResponseChatBubble,
                        responseBubbleOpacity: responseBubbleOpacity,
                        tutorialBubbleOpacity: tutorialBubbleOpacity,
                        showTutorialBubble: $showTutorialBubble,
                        currentInput: $currentInput,
                        selectedDate: $selectedDate,
                        selectedTime: $selectedTime,
                        onSend: { handleSend() },
                        onDateSelected: { date in
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            let formattedDate = formatter.string(from: date)
                            
                            // Add delay for picker submission
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                handleUserInput(input: formattedDate)
                            }
                        },
                        onTimeSelected: { time in
                            let formatter = DateFormatter()
                            formatter.timeStyle = .short
                            let formattedTime = formatter.string(from: time)
                            
                            // Add delay for picker submission
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                handleUserInput(input: formattedTime)
                            }
                        },
                        onUnknownTime: {
                            // Add delay for picker submission
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                handleUserInput(input: "Unknown")
                            }
                        },
                        isTextFieldFocused: $isTextFieldFocused,
                        onFrameChange: { frame in
                            inputFieldFrame = frame
                            // Recalculate keyboard offset when input field appears
                            if keyboardManager.keyboardHeight > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    keyboardManager.updateKeyboardOffset(
                                        keyboardHeight: keyboardManager.keyboardHeight,
                                        inputFieldFrame: self.inputFieldFrame,
                                        lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                                    )
                                }
                            }
                        },
                        tutorialManager: tutorialManager,
                        highlightInputField: $highlightInputField,
                        onHeightChange: { heightDifference in
                            // Keyboard offset handles all positioning
                            // No need for manual scroll adjustments
                        },
                        backgroundColor: backgroundColor,
                        bubbleColor: bubbleColor
                    )
                    .id("inputSection")
                    
                    tapToContinueLabel
                    bottomAnchorView
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
                .offset(y: -totalScrollOffset) // Apply negative offset to pull content up when keyboard appears
                .onTapGesture {
                    if shouldShowCompleteButton {
                        onConversationComplete()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(1)
            .background(Color.clear)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollViewOffset = value
            }
            .padding(.top, -headerFrame.midY)
            .onChange(of: messages.count) { oldCount, newCount in
                handleMessageCountChange(oldCount: oldCount, newCount: newCount)
            }
//            .onChange(of: isTyping) { _, isTyping in
//                if isTyping {
//                    print("++ is typing")
//                    // Delay scroll until typing indicator is visible
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                         scrollToBottom(animated: true)
//                    }
//                }
//            }
            .onChange(of: showResponseChatBubble) { _, showResponse in
                if showResponse {
                    // First scroll to bottom, then fade in the response bubble
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                         scrollToBottom(animated: true)
                        
                        // After scroll completes, fade in the response bubble and tutorial
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                responseBubbleOpacity = 1.0
                                tutorialBubbleOpacity = 1.0
                            }
                        }
                    }
                    
                    // Recalculate keyboard offset when input field appears
                    if keyboardManager.keyboardHeight > 0 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            keyboardManager.updateKeyboardOffset(
                                keyboardHeight: keyboardManager.keyboardHeight,
                                inputFieldFrame: self.inputFieldFrame,
                                lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                            )
                        }
                    }
                }
            }
            .onAppear {
                // Initial scroll to bottom with longer delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                     scrollToBottom(animated: false)
                }
            }
            .onChange(of: shouldScrollToBottom) { _, shouldScroll in
                if shouldScroll {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        proxy.scrollTo("bottomAnchor", anchor: .bottom)
                    }
                }
            }
            .onChange(of: isTextFieldFocused) { _, isFocused in
                if isFocused && keyboardManager.keyboardHeight > 0 {
                    print("is focused")
                    // Text field gained focus while keyboard is visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        keyboardManager.updateKeyboardOffset(
                            keyboardHeight: keyboardManager.keyboardHeight,
                            inputFieldFrame: self.inputFieldFrame,
                            lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                        )
                    }
                } else {
                    print("not focused")
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        // Track when user scrolls away from top or bottom
                        if value.translation.height < -20 && isUserAtBottom {
                            isUserAtBottom = false
                        }
                        if value.translation.height > 20 && isUserAtTop {
                            isUserAtTop = false
                        }
                    }
                    .onEnded { _ in
                        // Check if user scrolled to top or bottom after drag ends
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            // This will be handled by the anchor's onAppear/onDisappear
                        }
                    }
            )
        }
    }
    
    // MARK: - Helper Functions for ChatContentView
    private func handleDateSelected(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        handleUserInput(input: formatter.string(from: date))
    }
    
    private func handleTimeSelected(_ time: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        handleUserInput(input: formatter.string(from: time))
    }
    
    private func handleUnknownTime() {
        handleUserInput(input: "Unknown")
    }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return .zero
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
                
            VStack(spacing: 0) {
                chatScrollView
                
                // Progress indicator at the bottom
                ProgressBar(progress: Double(currentStep) / Double(conversationSteps.count), foregroundColor: .accentGold)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
        .onAppear {
            startConversation()
        }
        .onDisappear {
            // Clean up timer when view disappears
            scrollDebounceTimer?.invalidate()
            scrollDebounceTimer = nil
            
            // Reset keyboard offset when view disappears
            keyboardManager.resetKeyboardOffset()
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            self.headerHeight = headerHeight
        }
        .onReceive(keyboardManager.$keyboardHeight) { keyboardHeight in
            handleKeyboardHeightChange(keyboardHeight)
            
            // Ensure offset is reset when keyboard is hidden
            if keyboardHeight == 0 {
                keyboardManager.resetKeyboardOffset()
            }
        }

    }
    
    // MARK: - Helper Functions
    
    private func dismissTutorialOnTyping() {
        if showTutorialBubble {
            withAnimation(.easeInOut(duration: 0.3)) {
                showTutorialBubble = false
            }
        }
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
        showResponseChatBubble = false
        showTutorialBubble = false
        responseBubbleOpacity = 0.0
        tutorialBubbleOpacity = 0.0
        
        let initialMessage = conversationSteps[0].message
        let personalizedInitialMessage = personalizeMessage(initialMessage, userName)
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
                        showResponseChatBubble = true
                        showInputField = true
                        responseBubbleOpacity = 0.0 // Start with opacity 0
                        // Show tutorial bubble if the current step has a tutorial
                        if currentStep < conversationSteps.count && conversationSteps[currentStep].tutorial != nil {
                            showTutorialBubble = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleSend() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            highlightInputField = true
            return
        }
        highlightInputField = false
        handleUserInput(input: trimmed)
    }
    
    private func handleUserInput(input: String) {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        tutorialManager.stopTutorial()
        
        // Reset keyboard offset immediately before response bubble appears
        keyboardManager.resetKeyboardOffset()
        
        showInputField = false
        showResponseChatBubble = false
        showTutorialBubble = false
        responseBubbleOpacity = 0.0
        tutorialBubbleOpacity = 0.0
        
        let responseMessage = ChatMessage(
            text: trimmedInput,
            isUser: true,
            timestamp: Date()
        )
        withAnimation {
            messages.append(responseMessage)
        }
        
        // Track user response for AI steps
        if currentStep < conversationSteps.count && conversationSteps[currentStep].aiStep {
            previousResponses.append(trimmedInput)
        }
        
        onUserDataUpdate(trimmedInput, conversationSteps[currentStep])
        currentInput = ""
        currentStep += 1
        onStepComplete(currentStep)
        
        // Trigger next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            triggerNextQuestion()
        }
    }
    
    private func displayQuestionMessage(_ text: String) {
        
        isTyping = true
        showInputField = false
        showResponseChatBubble = false
        responseBubbleOpacity = 0.0
        tutorialBubbleOpacity = 0.0
        
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
                    showResponseChatBubble = true
                    responseBubbleOpacity = 0.0 // Start with opacity 0
                    if currentStep < conversationSteps.count {
                        showInputField = true
                        // Show tutorial bubble if the current step has a tutorial
                        if currentStep < conversationSteps.count && conversationSteps[currentStep].tutorial != nil {
                            showTutorialBubble = true
                        }
                    }
                }
            }
        }
    }
    
    private func triggerNextQuestion() {
        if currentStep < conversationSteps.count {
            let nextStep = conversationSteps[currentStep]
            let nextMessage = nextStep.message
            
            // Use GPTOnboarding if aiStep is true
            if nextStep.aiStep {
                // Show typing indicator immediately
                isTyping = true
                
                Task {
                    let gptPersonalizedMessage = await GPTOnboarding.personalizeOnboardingMessage(nextMessage, with: userData, previousResponses: previousResponses)
                    await MainActor.run {
                        isTyping = false
                        displayQuestionMessage(gptPersonalizedMessage)
                    }
                }
            } else {
                let personalizedMessage = personalizeMessage(nextMessage, userName)
                displayQuestionMessage(personalizedMessage)
            }
        } else {
            onConversationComplete()
        }
    }
    
    // MARK: - Auto-scroll Helper Functions
    private func handleMessageCountChange(oldCount: Int, newCount: Int) {
        lastMessageCount = newCount
    }
    
    private func scrollToBottom(animated: Bool) {
//        print("scrollToBottom")
        guard !shouldScrollToBottom else { return }
        
        // Trigger scroll by updating state
        shouldScrollToBottom = true
        
        // Reset the flag after a longer delay to prevent rapid toggling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shouldScrollToBottom = false
        }
    }
    
    private func handleKeyboardHeightChange(_ keyboardHeight: CGFloat) {
//        print("🔧 [handleKeyboardHeightChange] Keyboard height changed to: \(keyboardHeight)")
        
        // Dismiss tutorial bubble when keyboard appears
        if keyboardHeight > 0 {
            dismissTutorialOnTyping()
        }

        // Add longer delay for first input field to ensure it's rendered
        let delay = showInputField && showResponseChatBubble ? 0.3 : 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            keyboardManager.updateKeyboardOffset(
                keyboardHeight: keyboardHeight,
                inputFieldFrame: self.inputFieldFrame,
                lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
            )
            
            if keyboardHeight == 0 {
                // ++ prevents when pressing return everything goes below the screen
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                      scrollToBottom(animated: true) //kilroy
//                }
            }
        }
    }
    
    // MARK: - Fade Effect Helper
    private func calculateContentOpacity() -> Double {
        let fadeStart: CGFloat = 0
        let fadeEnd: CGFloat = headerHeight * 0.5
        
        if scrollViewOffset >= fadeStart {
            return 1.0
        } else if scrollViewOffset <= -fadeEnd {
            return 0.0
        } else {
            let progress = abs(scrollViewOffset) / fadeEnd
            return 1.0 - progress
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Chat History Content View
// Break out the chat history content into a separate view
struct ChatHistoryContentView: View {
    let messages: [ChatMessage]
    let currentStep: Int
    let onboardingConversationSteps: [ConversationStep]
    let showInputField: Bool
    let showResponseChatBubble: Bool
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let isTyping: Bool
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let tutorialManager: TutorialManager
    let backgroundColor: Color?
    let questionBubbleColor: ChatBubbleColor?
    let answeredBubbleColor: ChatBubbleColor?
    
    init(messages: [ChatMessage], currentStep: Int, onboardingConversationSteps: [ConversationStep], showInputField: Bool, showResponseChatBubble: Bool, selectedDate: Binding<Date>, selectedTime: Binding<Date>, isTyping: Bool, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, tutorialManager: TutorialManager, backgroundColor: Color?, questionBubbleColor: ChatBubbleColor?, answeredBubbleColor: ChatBubbleColor?) {
        self.messages = messages
        self.currentStep = currentStep
        self.onboardingConversationSteps = onboardingConversationSteps
        self.showInputField = showInputField
        self.showResponseChatBubble = showResponseChatBubble
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.isTyping = isTyping
        self.onDateSelected = onDateSelected
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.tutorialManager = tutorialManager
        self.backgroundColor = backgroundColor
        self.questionBubbleColor = questionBubbleColor
        self.answeredBubbleColor = answeredBubbleColor
    }
    
    var body: some View {
        VStack(spacing: -20) { //space between question and response bubbles
            ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                MessageBubbleView(
                    index: index,
                    message: message,
                    messages: messages,
                    backgroundColor: backgroundColor,
                    questionBubbleColor: questionBubbleColor,
                    answeredBubbleColor: answeredBubbleColor
                )
                .id("message_\(index)")
                .transition(.opacity)             }
            
            TypingIndicator(isAnimating: isTyping)
                .opacity(isTyping ? 1 : 0)
                .id("typingIndicator")

            // Ensure we always have a bottom anchor for scrolling
            // Adjust this for ++padding between question and response bubbles
            Color.clear
                .frame(height: 20)
                .id("chatBottom")
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showResponseChatBubble)
    }
}

// MARK: - Message Bubble View Helper
struct MessageBubbleView: View {
    let index: Int
    let message: ChatMessage
    let messages: [ChatMessage]
    let backgroundColor: Color?
    let questionBubbleColor: ChatBubbleColor?
    let answeredBubbleColor: ChatBubbleColor?
    
    var body: some View {
        if message.isUser {
            // User response - use AnsweredChatBubble
            AnsweredChatBubble(message: message, backgroundColor: backgroundColor, bubbleColor: .submitted)
        } else {
            // AI question - determine color based on whether it's been answered
            let bubbleColorForQuestion: ChatBubbleColor? = {
                if let bubbleColor = questionBubbleColor {
                    return bubbleColor
                }
                let hasBeenAnswered = index + 1 < messages.count && messages[index + 1].isUser
                return hasBeenAnswered ? .submitted : .active
            }()
            
            // Determine logo opacity based on whether the question has been answered
            let logoOpacity: Double = {
                let hasBeenAnswered = index + 1 < messages.count && messages[index + 1].isUser
                return hasBeenAnswered ? 0.5 : 1.0 // Fade logo when in history
            }()
            
            QuestionChatBubble(
                message: message, 
                backgroundColor: backgroundColor, 
                bubbleColor: bubbleColorForQuestion,
                logoOpacity: logoOpacity
            )
        }
    }
}

// MARK: - Chat Input View
// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInputField: Bool
    let showResponseChatBubble: Bool
    let responseBubbleOpacity: Double
    let tutorialBubbleOpacity: Double
    @Binding var showTutorialBubble: Bool
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
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
    // Frame tracking state
    @State private var previousFrame: CGRect = .zero
    
    var body: some View {
        if currentStep < conversationSteps.count && !conversationSteps[currentStep].isFinal {
            let isVisible = showInputField && showResponseChatBubble
            
            VStack(spacing: 0) {
                // Response chat bubble with frame tracking
                ResponseChatBubble(
                    currentStep: conversationSteps[currentStep],
                    currentInput: currentInput,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onSend: onSend,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime,
                    onFrameChange: { frame in
                        // Only update if the frame has changed significantly (more than 1 point)
                        if abs(frame.minX - previousFrame.minX) > 1 || 
                           abs(frame.minY - previousFrame.minY) > 1 ||
                           abs(frame.width - previousFrame.width) > 1 ||
                           abs(frame.height - previousFrame.height) > 1 {
                            
                            onFrameChange(frame)
                            previousFrame = frame
                        }
                    },
                    highlightInputField: $highlightInputField,
                    onHeightChange: onHeightChange,
                    backgroundColor: backgroundColor,
                    bubbleColor: ChatBubbleColor.clear
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                let frame = geometry.frame(in: .global)
                                previousFrame = frame
                            }
                            .onChange(of: geometry.frame(in: .global)) { oldFrame, newFrame in
                                // Only update if the frame has changed significantly (more than 1 point)
                                if abs(newFrame.minX - oldFrame.minX) > 1 || 
                                   abs(newFrame.minY - oldFrame.minY) > 1 ||
                                   abs(newFrame.width - oldFrame.width) > 1 ||
                                   abs(newFrame.height - oldFrame.height) > 1 {
                                    
                                    onFrameChange(newFrame)
                                    previousFrame = newFrame
                                }
                            }
                    }
                )
                .transition(.opacity)
                .opacity(responseBubbleOpacity)
                .allowsHitTesting(responseBubbleOpacity > 0)

                Spacer()
                
                // Dynamic tutorial bubble based on conversation step
                if showTutorialBubble, 
                   currentStep < conversationSteps.count,
                   let tutorial = conversationSteps[currentStep].tutorial {
                    
                    TutorialBubble.custom(
                        title: tutorial.title,
                        subtitle: tutorial.subtitle,
                        icon: tutorial.icon,
                        arrowPosition: TutorialBubble.getArrowPosition(from: tutorial.arrow),
                        pulse: true,
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showTutorialBubble = false
                            }
                        }
                    )
                    .padding(.bottom, 16)
                    .transition(.opacity)
                    .opacity(tutorialBubbleOpacity)
                }
            }
        } else {
            // Return empty view when conditions are not met
            EmptyView()
        }
    }
}

