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
    @State private var keyboardHeight: CGFloat = 0
    @State private var animatedKeyboardOffset: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var lastCalculatedOffset: CGFloat = 0

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
            sparkleOpacity: badgeAnimationManager.sparkleOpacity
        )
    }
    
    @ViewBuilder
    private var completeButtonView: some View {
        if shouldShowCompleteButton {
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
            .id("completeButton")
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
        Color.red
            .frame(height: 1)
            .padding(.top, 50)
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
                    Color.green
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
                        tutorialManager: tutorialManager
                    )
                    .opacity(calculateContentOpacity())
                    
                    // Input
                    ChatInputView(
                        currentStep: currentStep,
                        conversationSteps: conversationSteps,
                        showInputField: showInputField,
                        showResponseChatBubble: showResponseChatBubble,
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
                            // Track input field frame for keyboard offset calculation
                            print("🔧 [onFrameChange] Input field frame updated: \(frame)")
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
                    
                    completeButtonView
                    bottomAnchorView
                }
                .padding(.horizontal)
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
                            let targetOffset = self.calculateKeyboardOffset()
                            if targetOffset > 0 && self.lastCalculatedOffset != targetOffset {
                                self.lastCalculatedOffset = targetOffset
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
                        let targetOffset = self.calculateKeyboardOffset()
                        if targetOffset > 0 && self.lastCalculatedOffset != targetOffset {
                            self.lastCalculatedOffset = targetOffset
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
    private func calculateKeyboardOffset() -> CGFloat {
        guard keyboardHeight > 0 else { return 0 }
        
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaInsets = getSafeAreaInsets()
        let bottomSafeArea = safeAreaInsets.bottom
        
        // Get the bubble's bottom position from the top of the screen
        let bubbleBottomFromTop = getLastChatBubbleBottomFromTop()
        
        // If bubble position is not available, use a reasonable estimate
        guard bubbleBottomFromTop > 0 else { return 0 }
        
        // Calculate bubble's distance from bottom of screen
        let bubbleBottomFromBottom = screenHeight - bubbleBottomFromTop
        
        // Check if keyboard is covering the bubble
        // Account for the fact that ScrollView ignores bottom safe area
        let keyboardTop = screenHeight - keyboardHeight - bottomSafeArea
        let availableSpace = keyboardTop - bubbleBottomFromTop
        
        print("🔧 [calculateKeyboardOffset] bubbleBottomFromTop: \(bubbleBottomFromTop), keyboardTop: \(keyboardTop), availableSpace: \(availableSpace)")
        
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
        
        // For the first input field, add a calculated offset to ensure it's visible
        if messages.count == 1 && showInputField && showResponseChatBubble {
            // Calculate a reasonable offset based on keyboard height and screen dimensions
            let estimatedInputFieldHeight: CGFloat = 80
            let padding: CGFloat = 20
            let firstInputOffset = min(keyboardHeight * 0.3, 120) + padding
            print("🔧 [calculateKeyboardOffset] First input field - calculated offset: \(firstInputOffset)")
            return firstInputOffset
        }
        
        return 0
    }
    
    private func getLastChatBubbleBottomFromTop() -> CGFloat {
        // If input field is visible and has a valid frame, use that instead
        if showInputField && showResponseChatBubble && inputFieldFrame.height > 0 {
            print("🔧 [getLastChatBubbleBottomFromTop] Using frame: \(inputFieldFrame.maxY)")
            return inputFieldFrame.maxY
        }
        
        // For the first input field, use a more conservative estimate
        if messages.count == 1 && showInputField && showResponseChatBubble {
            let estimatedBubbleHeight: CGFloat = 60 // Average bubble height
            let inputFieldHeight: CGFloat = 80 // Estimated input field height
            let spacing: CGFloat = 16 // Spacing between bubbles
            let topSpacing: CGFloat = contentTopSpacing
            
            let result = topSpacing + estimatedBubbleHeight + spacing + inputFieldHeight
            print("🔧 [getLastChatBubbleBottomFromTop] First input field estimate: \(result)")
            return result
        }
        
        // Fallback to estimation if frame not tracked yet
        let estimatedBubbleHeight: CGFloat = 60 // Average bubble height
        let spacing: CGFloat = 16 // Spacing between bubbles
        let topSpacing: CGFloat = contentTopSpacing
        
        let estimatedBottom = topSpacing + (CGFloat(messages.count) * (estimatedBubbleHeight + spacing))
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
        showResponseChatBubble = false
        
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
        
        print("🔍 [InputDebug] handleUserInput called with: '\(input)'")
        print("🔍 [InputDebug] currentStep: \(currentStep), keyboardHeight: \(keyboardHeight)")
        print("🔍 [InputDebug] Before state changes - showInputField: \(showInputField), showResponseChatBubble: \(showResponseChatBubble)")
        
        tutorialManager.stopTutorial()
        
        // Reset keyboard offset immediately before response bubble appears
        if animatedKeyboardOffset > 0 {
            print("🔧 [InputDebug] Resetting keyboard offset before response bubble")
            withAnimation(.easeInOut(duration: 0.2)) {
                animatedKeyboardOffset = 0
                lastCalculatedOffset = 0
            }
        }
        
        // Set transition state to prevent scrolling when response bubble disappears
        print("🔍 [TransitionDebug] Setting isTransitioning = true")
        isTransitioning = true
        isProcessingUserInput = true
        
        showInputField = false
        showResponseChatBubble = false
        
        print("🔍 [InputDebug] After hiding input - showInputField: \(showInputField), showResponseChatBubble: \(showResponseChatBubble)")
        
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
        
        print("🔍 [InputDebug] Step completed, new currentStep: \(currentStep)")
        
        // Reset transition state after the response bubble is displayed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("🔍 [TransitionDebug] Setting isTransitioning = false (after user input)")
            isTransitioning = false
        }
        
        // Trigger next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            print("🔍 [InputDebug] Triggering next question after user input")
            triggerNextQuestion()
        }
        
        // Reset processing flag after the next question appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            print("🔍 [TransitionDebug] Setting isProcessingUserInput = false (after full cycle)")
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
                    }
                }
                
                // Reset processing flag once the input field is shown
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("🔍 [TransitionDebug] Setting isProcessingUserInput = false (input field shown)")
                    isProcessingUserInput = false
                }
            }
            
            // Reset transition state after the AI message is displayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("🔍 [TransitionDebug] Setting isTransitioning = false (after AI message)")
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
        print("🔍 [AutoScroll] Message count changed from \(oldCount) to \(newCount)")
        
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
        print("🔍 [AutoScroll] Scrolling to bottom, animated: \(animated)")
        
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
        self.keyboardHeight = keyboardHeight
        
        // Handle keyboard appearance and disappearance
        if keyboardHeight > 0 {
            // Keyboard appeared - calculate offset if needed
            if self.lastCalculatedOffset == 0 {
                // Add longer delay for first input field to ensure it's rendered
                let delay = showInputField && showResponseChatBubble ? 0.3 : 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let targetOffset = self.calculateKeyboardOffset()
                    self.lastCalculatedOffset = targetOffset
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.animatedKeyboardOffset = targetOffset
                    }
                }
            }
        } else {
            // Keyboard disappeared - reset offset to 0
            if self.lastCalculatedOffset > 0 {
                print("🔧 [KeyboardDebug] Keyboard disappeared, resetting offset to 0")
                self.lastCalculatedOffset = 0
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.animatedKeyboardOffset = 0
                    self.lastCalculatedOffset = 0
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
    
    init(messages: [ChatMessage], currentStep: Int, onboardingConversationSteps: [ConversationStep], showInputField: Bool, showResponseChatBubble: Bool, selectedDate: Binding<Date>, selectedTime: Binding<Date>, isTyping: Bool, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, tutorialManager: TutorialManager) {
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
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                if message.isUser {
                    // User response - use AnsweredChatBubble
                    AnsweredChatBubble(message: message)
                        .id("message_\(index)")
                        .transition(.opacity)
                } else {
                    // AI question - use QuestionChatBubble
                    QuestionChatBubble(message: message)
                        .id("message_\(index)")
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
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showResponseChatBubble)
    }
}

// MARK: - Chat Input View
// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInputField: Bool
    let showResponseChatBubble: Bool
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
        if currentStep < conversationSteps.count && !conversationSteps[currentStep].isFinal {
            let isVisible = showInputField && showResponseChatBubble
            
            VStack(spacing: 0) {
                // Response chat bubble
                ResponseChatBubble(
                    currentStep: conversationSteps[currentStep],
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

