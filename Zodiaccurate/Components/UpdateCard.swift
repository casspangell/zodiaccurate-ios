import SwiftUI

/// Enum representing the different states of the UpdateCard
enum UpdateCardState {
    case minimized
    case dismissed
    case expanded
    case expandedWithTutorial
    case expandedWithKeyboard
}

struct UpdateCard: View {
    // Card height constants
    private let cardHeightMinimized: CGFloat = 0.05
    private let cardHeightDismissed: CGFloat = 0.25
    private let cardHeightExpanded: CGFloat = 0.5
    private let cardHeightExpandedWithTutorial: CGFloat = 0.55
    private let cardHeightExpandedWithKeyboard: CGFloat = 0.75
    
    @EnvironmentObject var authManager: AuthenticationManager
    var stardustManager: StardustManager?
    
    @State private var cardHeight: CGFloat = 0.25
    @State private var isExpanded = false
    @State private var isMinimized = false
    @State private var currentInput = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var highlightInputField = false
    @State private var showTutorialBubble = false
    @AppStorage("hasDismissedUpdateCardTutorial") private var hasDismissedUpdateCardTutorial: Bool = false
    @State private var hasShownTutorial = false
    @State private var hasDismissedTutorial = false
    @State private var isKeyboardVisible = false
    @State private var isLoading = false
    @State private var gptResponse: (line1: String, line2: String)?
    @State private var resetTimer: Timer?
    @State private var triggerGlistening = false
    @State private var dragOffset: CGSize = .zero
    
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
                        
                        // Card content
                        VStack(spacing: 16) {
                            // Label text or loading spinner
                            if isLoading {
                                ZodiacLoadingSpinner(size: .medium)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                UpdateCardText(
                                    line1: isMinimized ? "" : (gptResponse != nil ? "" : "Hey there!"),
                                    line2: isMinimized ? "" : (gptResponse?.line1 ?? "How is everything?"),
                                    line3: gptResponse?.line2 ?? "What's the latest?"
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, isMinimized ? 0 : 40)
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
                                            
                                            // Earn stardust for submitting an update
                                            if !userUpdate.isEmpty, let stardustManager = stardustManager {
                                                stardustManager.earnStardust(
                                                    amount: 25,
                                                    type: .dailyReward,
                                                    description: "Daily update submitted"
                                                )
                                                print("🪙 UpdateCard: Earned 25 stardust for daily update")
                                            }
                                            
                                            // Save to Firebase
                                            if let userId = authManager.user?.uid, !userUpdate.isEmpty {
                                                let timestamp = Date()
                                                let formatter = DateFormatter()
                                                formatter.dateFormat = "yyyyMMdd-HHmmss"
                                                let updateId = "dailyUpdate-\(formatter.string(from: timestamp))"
                                                
                                                Task {
                                                    do {
                                                        let firebaseService = FirebaseDatabaseService()
                                                        try await firebaseService.saveUpdate(
                                                            userId: userId,
                                                            updateId: updateId,
                                                            content: userUpdate,
                                                            timestamp: timestamp
                                                        )
                                                        print("✅ Update saved to Firebase: /responses/\(userId)/Updates/\(updateId)")
                                                    } catch {
                                                        print("❌ Failed to save update to Firebase: \(error)")
                                                    }
                                                }
                                            }
                                            
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
                                                        fireGlisteningBackground()
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
                                                    hasDismissedUpdateCardTutorial = true
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
                    .frame(height: geometry.size.height * (isMinimized ? cardHeightMinimized : cardHeight))
                    .background(
                        ZStack {
                            Color.red
                            GlisteningBackground(
                                autoStart: false,
                                triggerAnimation: $triggerGlistening
                            )
                        }
                    )
                    .cornerRadius(24)
                    .overlay(
                        // Gold border to visualize hit area
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.accentGold, lineWidth: 3)
                    )
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                // Check if it's a downward swipe (positive height translation)
                                if value.translation.height > 50 {
                                    // Dismiss keyboard first if visible
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    
                                    // Minimize the card
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                        cardHeight = cardHeightMinimized
                                        isExpanded = false
                                        isMinimized = true
                                    }
                                    postStateChangeNotification(state: .minimized)
                                    NotificationCenter.default.post(name: .componentDeactivated, object: nil)
                                }
                                dragOffset = .zero
                            }
                    )
                    .onTapGesture {
                        // Post notification to activate UpdateCard
                        NotificationCenter.default.post(name: .updateCardActivated, object: nil)
                        if isExpanded {
                            // Dismiss keyboard first
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                            // Then animate card collapse
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                    cardHeight = cardHeightDismissed
                                    isExpanded = false
                                    isMinimized = false
                                }
                                postStateChangeNotification(state: .dismissed)
                                NotificationCenter.default.post(name: .updateCardDismissed, object: nil)
                            }
                        } else if isMinimized {
                            // Tap to return to dismissed state from minimized
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                cardHeight = cardHeightDismissed
                                isMinimized = false
                            }
                            postStateChangeNotification(state: .dismissed)
                            NotificationCenter.default.post(name: .updateCardDismissed, object: nil)
                        } else {
                            // Expand from dismissed state
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                if !hasDismissedTutorial {
                                    cardHeight = cardHeightExpandedWithTutorial
                                    isExpanded = true
                                    postStateChangeNotification(state: .expandedWithTutorial)
                                    
                                    // Show tutorial on first expansion
                                    if !hasShownTutorial && !hasDismissedUpdateCardTutorial {
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
                                    postStateChangeNotification(state: .expanded)
                                }
                                isMinimized = false
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            setupKeyboardObservers()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                fireGlisteningBackground()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .flipBookActivated)) { _ in
            // Minimize UpdateCard when FlipBook is activated/expanded
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                cardHeight = cardHeightMinimized
                isExpanded = false
                isMinimized = true
            }
            postStateChangeNotification(state: .minimized)
        }
        .onReceive(NotificationCenter.default.publisher(for: .flipBookCollapsed)) { _ in
            // Don't change UpdateCard state when FlipBook collapses - keep current state
            // This allows UpdateCard to remain minimized if it was already minimized
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateCardShouldMinimize)) { _ in
            // Minimize UpdateCard after 5 seconds as requested
            print("🔄 UpdateCard: Received updateCardShouldMinimize notification, minimizing card")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                cardHeight = cardHeightMinimized
                isExpanded = false
                isMinimized = true
            }
            postStateChangeNotification(state: .minimized)
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
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
                showTutorialBubble = false
                hasDismissedTutorial = true
                if isExpanded {
                    cardHeight = cardHeightExpandedWithKeyboard
                    postStateChangeNotification(state: .expandedWithKeyboard)
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
                        postStateChangeNotification(state: .expandedWithTutorial)
                    } else {
                        cardHeight = cardHeightExpanded
                        postStateChangeNotification(state: .expanded)
                    }
                }
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Card State Management
    
    private func postStateChangeNotification(state: UpdateCardState) {
        NotificationCenter.default.post(
            name: .updateCardStateChanged,
            object: nil,
            userInfo: ["state": state]
        )
    }
    
    private func onCardDismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
            cardHeight = cardHeightDismissed
            isExpanded = false
            isMinimized = false
        }
        postStateChangeNotification(state: .dismissed)
        // Post notification to deactivate component
        NotificationCenter.default.post(name: .componentDeactivated, object: nil)
        // Post specific notification that UpdateCard is dismissed
        NotificationCenter.default.post(name: .updateCardDismissed, object: nil)
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
            isMinimized = false
        }
    }

    // MARK: - Glistening Animation
    func fireGlisteningBackground() {
        triggerGlistening = true
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
        
        UpdateCard(stardustManager: nil)
            .environmentObject(AuthenticationManager())
    }
} 
