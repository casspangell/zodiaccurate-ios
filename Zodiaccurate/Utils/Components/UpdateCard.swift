import SwiftUI

struct UpdateCard: View {
    // Card height constants
    private let cardHeightDismissed: CGFloat = 0.25
    private let cardHeightExpanded: CGFloat = 0.5
    private let cardHeightExpandedWithTutorial: CGFloat = 0.75
    private let cardHeightExpandedWithKeyboard: CGFloat = 0.95
    
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
    @State private var isSubmitting = false
    
    // Sample conversation step for the update card
    private var updateConversationStep: ConversationStep {
        let timestamp = getTimestampString()
        
        return ConversationStep(
            message: "How are you feeling today? Share your thoughts and let me know what's on your mind...",
            inputType: "multiLine",
            placeholder: "",
            dataKey: "dailyUpdate-\(timestamp)"
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black rectangle covering safe area at bottom (static)
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.black)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .ignoresSafeArea(.container, edges: .bottom)
                }
                .ignoresSafeArea(.container, edges: .bottom)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Draggable indicator
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.white.opacity(0.6))
//                            .frame(width: 40, height: 4)
//                            .padding(.top, 24)
//                            .padding(.bottom, 8)
                        
                        // Card content
                        VStack(spacing: 16) {
                            // Label text
                            UpdateCardText()
                                .padding(.horizontal, 20)
                                .padding(.top, 40)
                            
                            // Chat bubble (only when expanded)
                            if isExpanded {
                                VStack(spacing: 16) {
                                    UpdateBubble(
                                        currentInput: $currentInput,
                                        onSend: {
                                            // Dismiss keyboard first
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            
                                            // Handle send action
                                            print("Update sent: \(currentInput)")
                                            currentInput = ""
                                            
                                            // Collapse card to dismissed state
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                                cardHeight = cardHeightDismissed
                                                isExpanded = false
                                            }
                                        },
                                        onFrameChange: { _ in },
                                        highlightInputField: .constant(false)
                                    )
                                    
                                    // Tutorial bubble (show on first expansion)
                                    if showTutorialBubble {
                                        TutorialBubble.custom(
                                            title: "Share Your Day",
                                            subtitle: "Tell me how you're feeling and what's on your mind. Your daily updates help me understand you better.",
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
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * cardHeight)
                    .background(Color.black)
                    .cornerRadius(24)
                }
                .offset(y: dragOffset)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
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
                        let translation = value.translation.height
                        let velocity = value.velocity.height
                        let screenHeight = geometry.size.height
                        
                        // Determine if we should expand or collapse based on drag and velocity
                        let shouldExpand = translation < -50 || velocity < -500
                        let shouldCollapse = translation > 50 || velocity > 500
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            if shouldExpand && !isExpanded {
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
                            } else if shouldCollapse && isExpanded {
                                cardHeight = cardHeightDismissed
                                isExpanded = false
                            }
                            dragOffset = 0
                        }
                        
                        isDragging = false
                    }
            )
            .onTapGesture {
                if isExpanded {
                    // Dismiss keyboard first
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    // Then animate card collapse
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            cardHeight = cardHeightDismissed
                            isExpanded = false
                            dragOffset = 0
                        }
                    }
                } else {
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
            }
        }
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
                showTutorialBubble = false
                hasDismissedTutorial = true
                if isExpanded {
                    cardHeight = cardHeightExpandedWithKeyboard
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
                if isExpanded {
                    if !hasDismissedTutorial {
                        cardHeight = cardHeightExpandedWithTutorial
                    } else {
                        cardHeight = cardHeightExpanded
                    }
                }
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        UpdateCard()
    }
} 
