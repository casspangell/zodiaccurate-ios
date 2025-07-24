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
    @State private var showResponseChatBubble = false
    @State private var showTutorialBubble = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var animatedKeyboardOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0

    @State private var inputFieldFrame: CGRect = .zero
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var tutorialManager = TutorialManager()
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightInputField = false
    @State private var isTransitioning = false
    @State private var isProcessingUserInput = false
    @State private var scrollViewOffset: CGFloat = 0
    @State private var headerFrame: CGRect = .zero
    
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
    let onUserDataUpdate: (String, ConversationStep) -> Void
    let onStepComplete: (Int) -> Void
    let onConversationComplete: () -> Void
    let personalizeMessage: (String, String) -> String
    let determineZodiacSign: (String) -> String
    let triggerBadgeAnimation: (String) -> Void
    let badgeAnimationManager: BadgeAnimationManager
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
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
        badgeAnimationManager: BadgeAnimationManager,
        backgroundColor: Color? = nil,
        bubbleColor: ChatBubbleColor? = nil
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
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
    }
    
    // MARK: - Computed Properties
    private var contentTopSpacing: CGFloat {
        return 0
    }
    
    private var contentTopPadding: CGFloat {
        return 0
    }
    
    private var totalScrollOffset: CGFloat {
        return animatedKeyboardOffset
    }
    
    private var shouldShowCompleteButton: Bool {
        let isFinalStep = currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal
        let hasMessages = messages.count > 0
        let lastMessageIsAI = messages.last?.isUser == false
        let isConversationComplete = currentStep >= conversationSteps.count
        
        return (isFinalStep && hasMessages && lastMessageIsAI) || isConversationComplete
    }
    
    @State private var tapHintOpacity: Double = 0.0

    
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
    private var headerView: some View {
        ZodiacHeader(
            profileImage: badgeAnimationManager.currentProfileImage,
            badgeScale: badgeAnimationManager.badgeScale,
            badgeRotation: badgeAnimationManager.badgeRotation,
            cosmicGlowOpacity: badgeAnimationManager.cosmicGlowOpacity,
            nebulaOpacity: badgeAnimationManager.nebulaOpacity,
            starFieldOpacity: badgeAnimationManager.starFieldOpacity,
            cosmicParticlesOpacity: badgeAnimationManager.cosmicParticlesOpacity,
            sparkleOpacity: badgeAnimationManager.sparkleOpacity,
            stardustPoints: 0 // TODO: Get from StardustManager
        )
    }
    
    @ViewBuilder
    private var tapToContinueLabel: some View {
        if shouldShowCompleteButton {
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Circle()
                        .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .scaleEffect(tapHintOpacity > 0.5 ? 1.1 : 1.0)
                    Text("Tap anywhere to continue")
                        .font(.dmSansMedium13_4)
                        .foregroundColor(Color.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .padding(.bottom, 50)
            .opacity(tapHintOpacity)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: tapHintOpacity
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    tapHintOpacity = 1.0
                }
            }
            .onDisappear {
                tapHintOpacity = 0.0
            }
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
            .padding(.top, 60)
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
                        showTutorialBubble: $showTutorialBubble,
                        currentInput: $currentInput,
                        selectedDate: $selectedDate,
                        selectedTime: $selectedTime,
                        onSend: { handleSendWithRecordingCheck() },
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
                            if keyboardHeight > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    let targetOffset = calculateKeyboardOffset(
                                        keyboardHeight: self.keyboardHeight,
                                        inputFieldFrame: self.inputFieldFrame,
                                        lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                                    )
                                    if targetOffset > 0 {
                                        print("kilroy: 22")
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            self.animatedKeyboardOffset = 20 //bump it about the height of a text line
                                        }
                                    }
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
                .onTapGesture {
                    if shouldShowCompleteButton {
                        onConversationComplete()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -totalScrollOffset)
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
            .onChange(of: isTyping) { _, isTyping in
                if isTyping {
                    // Delay scroll until typing indicator is visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        scrollToBottom(animated: true)
                    }
                }
            }
            .onChange(of: showResponseChatBubble) { _, showResponse in
                if showResponse {
                    // Longer delay to ensure the input field is fully rendered
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        scrollToBottom(animated: true)
                    }
                    
                    // Recalculate keyboard offset when input field appears
                    if keyboardHeight > 0 {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let targetOffset = calculateKeyboardOffset(
                                keyboardHeight: self.keyboardHeight,
                                inputFieldFrame: self.inputFieldFrame,
                                lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                            )
                            if targetOffset > 0 {
                                print("kilroy 2")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.animatedKeyboardOffset = targetOffset
                                }
                            }
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
                if isFocused && keyboardHeight > 0 {
                    // Text field gained focus while keyboard is visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let targetOffset = calculateKeyboardOffset(
                            keyboardHeight: self.keyboardHeight,
                            inputFieldFrame: self.inputFieldFrame,
                            lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
                        )
                        if targetOffset < 0 {
                            print("kilroy 1")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.animatedKeyboardOffset = targetOffset
                            }
                        }
                    }
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
                headerView
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    headerFrame = geometry.frame(in: .global)
                                }
                                .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                                    headerFrame = newFrame
                                }
                        }
                    )
                chatScrollView
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
        .onDisappear {
            // Clean up timer when view disappears
            scrollDebounceTimer?.invalidate()
            scrollDebounceTimer = nil
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            self.headerHeight = headerHeight
        }
        .onReceive(Publishers.keyboardHeight) { keyboardHeight in
            handleKeyboardHeightChange(keyboardHeight)
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
                        // Show tutorial bubble if the current step has a tutorial
                        if currentStep < conversationSteps.count && conversationSteps[currentStep].tutorial != nil {
                            showTutorialBubble = true
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
        
        // Reset keyboard offset immediately before response bubble appears
        if animatedKeyboardOffset > 0 {
            print("🔧 [InputDebug] Resetting keyboard offset before response bubble")
            withAnimation(.easeInOut(duration: 0.2)) {
                animatedKeyboardOffset = 0
            }
        }

        isTransitioning = true
        isProcessingUserInput = true
        
        showInputField = false
        showResponseChatBubble = false
        showTutorialBubble = false
        
        let responseMessage = ChatMessage(
            text: input,
            isUser: true,
            timestamp: Date()
        )
        withAnimation {
            messages.append(responseMessage)
        }
        
        print("🔍 [InputDebug] Response message added, calling onUserDataUpdate")
        onUserDataUpdate(input, conversationSteps[currentStep])
        currentInput = ""
        currentStep += 1
        onStepComplete(currentStep)
        
        // Reset transition state after the response bubble is displayed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            print("🔍 [TransitionDebug] Setting isTransitioning = false (after user input)")
            isTransitioning = false
        }
        
        // Trigger next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            triggerNextQuestion()
        }
        
        // Reset processing flag after the next question appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//            print("🔍 [TransitionDebug] Setting isProcessingUserInput = false (after full cycle)")
            isProcessingUserInput = false
        }
    }
    
    private func displayQuestionMessage(_ text: String) {
        
        isTyping = true
        showInputField = false
        showResponseChatBubble = false
        
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
                    if currentStep < conversationSteps.count {
                        showInputField = true
                        // Show tutorial bubble if the current step has a tutorial
                        if currentStep < conversationSteps.count && conversationSteps[currentStep].tutorial != nil {
                            showTutorialBubble = true
                        }
                    }
                }
                
                // Reset processing flag once the input field is shown
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    print("🔍 [TransitionDebug] Setting isProcessingUserInput = false (input field shown)")
                    isProcessingUserInput = false
                }
            }
            
            // Reset transition state after the AI message is displayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                print("🔍 [TransitionDebug] Setting isTransitioning = false (after AI message)")
                isTransitioning = false
            }
        }
    }
    
    private func triggerNextQuestion() {
        if currentStep < conversationSteps.count {
            let nextMessage = conversationSteps[currentStep].message
            let personalizedMessage = personalizeMessage(nextMessage, userName)
            
            print("🔍 [ScrollDebug] Displaying next question")
            displayQuestionMessage(personalizedMessage)
        } else {
            print("🔍 [ScrollDebug] No more conversation steps to trigger")
            onConversationComplete()
        }
    }
    
    // MARK: - Auto-scroll Helper Functions
    private func handleMessageCountChange(oldCount: Int, newCount: Int) {
//        print("🔍 [AutoScroll] Message count changed from \(oldCount) to \(newCount)")
        
        // Cancel any existing debounce timer
        scrollDebounceTimer?.invalidate()
        
        // Only auto-scroll if user is at bottom or if it's a new message (not deletion)
        if newCount > oldCount && isUserAtBottom {
            // User is at bottom, debounce auto-scroll to prevent jitter
            scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                DispatchQueue.main.async {
                    scrollToBottom(animated: true)
                }
            }
        }
        
        lastMessageCount = newCount
    }
    
    private func scrollToBottom(animated: Bool) {
//        print("🔍 [AutoScroll] Scrolling to bottom, animated: \(animated)")
        
        // Prevent rapid successive scroll calls
        guard !shouldScrollToBottom else { return }
        
        // Trigger scroll by updating state
        shouldScrollToBottom = true
        
        // Reset the flag after a longer delay to prevent rapid toggling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shouldScrollToBottom = false
        }
    }
    
    private func handleKeyboardHeightChange(_ keyboardHeight: CGFloat) {
        print("🔧 [handleKeyboardHeightChange] Keyboard height changed to: \(keyboardHeight)")
        
        // Dismiss tutorial bubble when keyboard appears
        if keyboardHeight > 0 && showTutorialBubble {
            dismissTutorialOnTyping()
        }
        
        self.keyboardHeight = keyboardHeight

        // Add longer delay for first input field to ensure it's rendered
        let delay = showInputField && showResponseChatBubble ? 0.3 : 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("kilroy3")
            let targetOffset = calculateKeyboardOffset(
                keyboardHeight: self.keyboardHeight,
                inputFieldFrame: self.inputFieldFrame,
                lastResponseBubbleHeight: ChatBubbleHeightTracker.getLastResponseBubbleHeight()
            )

            if targetOffset > 0 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.animatedKeyboardOffset = targetOffset
                }
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
            // Adjust this for ++padding between question and response bubbles kilroy
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
            
            QuestionChatBubble(message: message, backgroundColor: backgroundColor, bubbleColor: bubbleColorForQuestion)
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
                            
                            let xDiff = frame.minX - previousFrame.minX
                            let yDiff = frame.minY - previousFrame.minY
                            let widthDiff = frame.width - previousFrame.width
                            let heightDiff = frame.height - previousFrame.height
                            
                            print("🔧 [ChatInputView] Frame change detected:")
                            print("   X: \(previousFrame.minX) → \(frame.minX) (diff: \(xDiff))")
                            print("   Y: \(previousFrame.minY) → \(frame.minY) (diff: \(yDiff))")
                            print("   Width: \(previousFrame.width) → \(frame.width) (diff: \(widthDiff))")
                            print("   Height: \(previousFrame.height) → \(frame.height) (diff: \(heightDiff))")
                            
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
                                onFrameChange(frame)
                                previousFrame = frame
                                print("🔧 [ChatInputView] Initial frame: \(frame)")
                            }
                            .onChange(of: geometry.frame(in: .global)) { oldFrame, newFrame in
                                // Only update if the frame has changed significantly (more than 1 point)
                                if abs(newFrame.minX - oldFrame.minX) > 1 || 
                                   abs(newFrame.minY - oldFrame.minY) > 1 ||
                                   abs(newFrame.width - oldFrame.width) > 1 ||
                                   abs(newFrame.height - oldFrame.height) > 1 {
                                    
                                    let xDiff = newFrame.minX - oldFrame.minX
                                    let yDiff = newFrame.minY - oldFrame.minY
                                    let widthDiff = newFrame.width - oldFrame.width
                                    let heightDiff = newFrame.height - oldFrame.height
                                    
                                    print("🔧 [ChatInputView] Frame change detected (GeometryReader):")
                                    print("   X: \(oldFrame.minX) → \(newFrame.minX) (diff: \(xDiff))")
                                    print("   Y: \(oldFrame.minY) → \(newFrame.minY) (diff: \(yDiff))")
                                    print("   Width: \(oldFrame.width) → \(newFrame.width) (diff: \(widthDiff))")
                                    print("   Height: \(oldFrame.height) → \(newFrame.height) (diff: \(heightDiff))")
                                    
                                    onFrameChange(newFrame)
                                    previousFrame = newFrame
                                }
                            }
                    }
                )
                .transition(.opacity)
                .opacity(isVisible ? 1 : 0)
                .allowsHitTesting(isVisible)

                Spacer()
                
                // Dynamic tutorial bubble based on conversation step
                if showTutorialBubble, 
                   currentStep < conversationSteps.count,
                   let tutorial = conversationSteps[currentStep].tutorial {
                    
                    TutorialBubble.custom(
                        title: tutorial.title,
                        subtitle: tutorial.subtitle,
                        icon: "sparkles",
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
                }
            }
        } else {
            // Return empty view when conditions are not met
            EmptyView()
        }
    }
}

