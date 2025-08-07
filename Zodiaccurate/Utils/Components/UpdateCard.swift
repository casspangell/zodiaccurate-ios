import SwiftUI

struct UpdateCard: View {
    // Card height constants
    private let cardHeightDismissed: CGFloat = 0.35
    private let cardHeightExpanded: CGFloat = 0.5
    private let cardHeightExpandedWithTutorial: CGFloat = 0.75
    private let cardHeightExpandedWithKeyboard: CGFloat = 1.0
    
    @State private var cardHeight: CGFloat = 0.25
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    @State private var isDragging = false
    @State private var currentInput = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var highlightInputField = false
    @State private var showTutorialBubble = false
    @State private var hasShownTutorial = false
    @State private var hasDismissedTutorial = false
    @State private var isKeyboardVisible = false
    @State private var isLoading = false
    @State private var gptResponse: (line1: String, line2: String)?
    @State private var resetTimer: Timer?
    @State private var showGreenBackground = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                VStack() {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Draggable indicator
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.white.opacity(0.6))
//                            .frame(width: 40, height: 4)
//                            .padding(.top, 24)
//                            .padding(.bottom, 8)
                        
                        Spacer()
                        // Card content
                        VStack(spacing: 16) {
                            // Label text or loading spinner
                            if isLoading {
                                Spacer()
                                ZodiacLoadingSpinner(size: .medium)
                                Spacer()
                            } else {
                                UpdateCardText(
                                    line1: gptResponse != nil ? "" : "Hey there!",
                                    line2: gptResponse?.line1 ?? "How is everything?",
                                    line3: gptResponse?.line2 ?? "What's the latest?"
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 40)
                            }
                            
                            // Chat bubble (only when expanded)
                            if isExpanded {
                                VStack(spacing: 16) {
                                    UpdateBubble(
                                        currentInput: $currentInput,
                                        onSend: {
                                            // Dismiss keyboard first
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            
                                            // Handle send action
                                            let userUpdate = currentInput
                                            print("Update sent: \(userUpdate)")
                                            
                                            // Start loading state and collapse card
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                isLoading = true
                                            }
                                            onCardDismiss()
                                            
                                            // Call GPTDailyUpdate and handle the response
                                            Task {
                                                let response = await GPTDailyUpdate.generatePersonalizedResponse(for: userUpdate)
                                                print("🤖 GPTDailyUpdate Response:")
                                                print("   Line 1: \(response.line1)")
                                                print("   Line 2: \(response.line2)")
                                                
                                                // Update UI on main thread
                                                await MainActor.run {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        gptResponse = response
                                                        isLoading = false
                                                    }
                                                    
                                                    // Trigger green background after loading spinner dismisses
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                        triggerGreenBackground()
                                                    }
                                                    
                                                    // Start timer to reset to default text after 5 seconds
                                                    resetTimer?.invalidate()
                                                    resetTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                                                        withAnimation(.easeInOut(duration: 0.5)) {
                                                            gptResponse = nil
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            currentInput = ""
                                        },
                                        onFrameChange: { _ in },
                                        highlightInputField: .constant(false)
                                    )
                                    
                                    // Tutorial bubble (show on first expansion)
                                    if showTutorialBubble {
                                        TutorialBubble.custom(
                                            title: "Share Your Day",
                                            subtitle: "Tell me how you're feeling and what's on your mind.",
                                            icon: "heart.fill",
                                            arrowPosition: .top,
                                            pulse: true,
                                            onDismiss: {
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showTutorialBubble = false
                                                    hasDismissedTutorial = true
                                                    cardHeight = cardHeightExpanded
                                                }
                                            }
                                        )
                                        .transition(.opacity)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .opacity(isExpanded ? 1.0 : 0.0)
                                .offset(y: isExpanded ? 0 : 50)
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }
                            
                        }
                        .padding(.bottom, 80)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * cardHeight)
                    .background(
                        showGreenBackground ? Color.green : Color.black
                    )
                    .cornerRadius(24)
                    
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .offset(y: dragOffset - (isKeyboardVisible ? keyboardHeight : 0))
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow drag when response is not displaying
                        guard gptResponse == nil else { return }
                        
                        isDragging = true
                        let translation = value.translation.height
                        let screenHeight = geometry.size.height
                        
                        // Calculate new height based on drag
                        let newHeight = isExpanded ? cardHeightExpanded : cardHeightDismissed
                        let heightDifference = (cardHeightExpanded - cardHeightDismissed) * screenHeight
                        
                        // Limit drag to reasonable bounds
                        let maxDrag = heightDifference * 0.3
                        dragOffset = max(-maxDrag, min(translation, maxDrag))
                    }
                    .onEnded { value in
                        // Only allow drag when response is not displaying
                        guard gptResponse == nil else { return }
                        
                        let translation = value.translation.height
                        let velocity = value.velocity.height
                        let screenHeight = geometry.size.height
                        
                        // Determine if we should expand or collapse based on drag and velocity
                        let shouldExpand = translation < -50 || velocity < -500
                        let shouldCollapse = translation > 50 || velocity > 500
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            if shouldExpand && !isExpanded {
                                onCardExpanded()
                            } else if shouldCollapse && isExpanded {
                                onCardDismiss()
                            }
                            dragOffset = 0
                        }
                        
                        isDragging = false
                    }
            )
            .onTapGesture {
                // Only allow tap when response is not displaying
                guard gptResponse == nil else { return }
                
                if isExpanded {
                    // Dismiss keyboard first
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // Then animate card collapse
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onCardDismiss()
                    }
                } else {
                    onCardExpanded()
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            setupKeyboardObservers()
            onCardDismiss()
        }
        .onDisappear {
            removeKeyboardObservers()
            resetTimer?.invalidate()
            resetTimer = nil
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
                showTutorialBubble = false
                hasDismissedTutorial = true
                if isExpanded {
//                    cardHeight = cardHeightExpandedWithKeyboard
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
                if isExpanded {
                    if !hasDismissedTutorial {
//                        cardHeight = cardHeightExpandedWithTutorial
                    } else {
//                        cardHeight = cardHeightExpanded
                    }
                } else if isLoading {
                    // When keyboard hides during loading, ensure card stays in dismissed state
//                    cardHeight = cardHeightDismissed
                }
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Card State Management
    private func onCardDismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
            cardHeight = cardHeightDismissed
            isExpanded = false
            dragOffset = 0
        }
    }
    
    private func onCardExpanded() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
            if !hasDismissedTutorial {
                cardHeight = cardHeightExpandedWithTutorial
                isExpanded = true
                
                // Show tutorial on first expansion
                if !hasShownTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showTutorialBubble = true
                            hasShownTutorial = true
                        }
                    }
                }
            } else {
                cardHeight = cardHeightExpanded
                isExpanded = true
            }
            dragOffset = 0
        }
    }
    
    // MARK: - Green Background Animation
    func triggerGreenBackground() {
        // Show green background
        withAnimation(.easeInOut(duration: 0.5)) {
            showGreenBackground = true
        }
        
        // Return to black background after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showGreenBackground = false
            }
        }
    }
}

#Preview {
    ZStack {
        // Background for preview
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            // Test button to trigger green background
            Button("🟢 Test Green Background") {
                // Simulate a response to trigger the green background
                // This will show the green background effect in the preview
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.bottom, 100)
            
            UpdateCard()
        }
    }
} 
