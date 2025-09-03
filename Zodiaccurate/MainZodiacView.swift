import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var stardustManager: StardustManager?
    @State private var intakeDataManager: IntakeDataManager?
    @State private var showingSettings = false
    @State private var splashViewDismissed = false
    @State private var cameFromHoroscopeSplash = false
    @State private var hasTriggeredStardustAnimation = false
    @State private var headerDisplayMode: ZodiacHeaderDisplayMode = .initial
    @AppStorage("hasAcceptedConsentPolicies") private var hasAcceptedConsentPolicies = false
    @State private var welcomeHoroscope: Horoscope?
    @State private var isWelcomeHoroscopeLoaded = false
    @AppStorage("hasShownUpdateTutorial") private var hasShownUpdateTutorial = false
    @State private var showUpdateTutorial = false
    @AppStorage("hasShownStardustTutorial") private var hasShownStardustTutorial = false
    @State private var showStardustTutorial = false
    @State private var showWellnessConversation = false
    @State private var wellnessDisplayName: String = ""
    @State private var showRelationshipConversation = false
    @State private var relationshipDisplayName: String = ""
    @State private var showImportantPeopleConversation = false
    @State private var importantPeopleDisplayName: String = ""
    @State private var showChildrenConversation = false
    @State private var childrenDisplayName: String = ""
    @State private var showEmploymentConversation = false
    @State private var employmentDisplayName: String = ""
    @State private var moveFlipbookToTop: Bool = false
    @State private var headerFlipBookSpacing: CGFloat = 50
    @State private var headerHeight: CGFloat = 0
    @State private var activeComponent: ActiveComponent = .none
    @State private var flipBookCardBottomPosition: CGFloat = 0
    @State private var currentFlipBookIndex: Int = 0
    @State private var showHandAnimation: Bool = true
    @State private var updateCardShouldMinimize: Bool = false
    
    var headerFlipBookSpacingDefault: CGFloat {
        return headerHeight + getQuestionMenuHeight() //getSafeAreaTop() + headerHeight + getQuestionMenuHeight()
    }
    
    enum ActiveComponent {
        case none
        case flipBook
        case updateCard
    }
    
    // MARK: - IntakeData Management
    
    /// Handle conversation response and update IntakeData
    private func handleConversationResponse(input: String, step: ConversationStep, topic: QuestionMenuButton) {
        guard let intakeDataManager = intakeDataManager else {
            print("❌ IntakeDataManager not available")
            return
        }
        
        let userId = authManager.user?.uid ?? "default"
        let topicString = intakeDataManager.topicFromQuestionMenuButton(topic)
        
        if !topicString.isEmpty {
            intakeDataManager.updateIntakeData(
                userId: userId,
                topic: topicString,
                dataKey: step.dataKey,
                answer: input
            )
            print("📝 Updated IntakeData - Topic: \(topicString), Key: \(step.dataKey), Answer: \(input)")
        } else {
            print("⚠️ Unknown topic for QuestionMenuButton: \(topic)")
        }
    }
    
    // MARK: - QuestionMenu Highlight Mapping
    
    /// Maps the current FlipBook index to the corresponding QuestionMenu button that should be highlighted
    private func getHighlightedQuestionMenuButton() -> QuestionMenuButton {
        // Skip index 0 (Welcome Horoscope)
        switch currentFlipBookIndex {
        case 1: // Wellness card
            return .wellness
        case 2: // Partner card
            return .relationship
        case 3: // Important People card
            return .importantPeople
        case 4: // Children card
            return .children
        case 5: // Employment card
            return .employment
        default:
            return .none
        }
    }
    
    @State var completedOnboarding: Bool
    
    init(completedOnboarding: Bool = false) {
        self._completedOnboarding = State(initialValue: completedOnboarding)
    }
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()

            VStack(spacing: 0) {
                // Main content area
                HoroscopeSplashView(
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashViewDismissed = true
                            cameFromHoroscopeSplash = true
                        }
                    },
                    onConsentDismissed: {
                        print("Consent alert dismissed in MainZodiacView")
                        self.completedOnboarding = true
                        
                    },
                    completedOnboarding: completedOnboarding
                )
                .environmentObject(authManager)
                .onAppear {
                    // Initialize StardustManager
                    if stardustManager == nil {
                        stardustManager = StardustManager()
                    }
                    
                    // Initialize IntakeDataManager
                    if intakeDataManager == nil {
                        intakeDataManager = IntakeDataManager(modelContext: modelContext)
                    }
                    
                    // Trigger header animation to main mode when view loads
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                            headerDisplayMode = .main
                        }
                        
                        // Set header background opacity to 0.0 when main view appears
                        NotificationCenter.default.post(
                            name: .setHeaderBackgroundOpacity,
                            object: nil,
                            userInfo: ["opacity": 0.0]
                        )
                    }
                    
                    // Don't trigger stardust animation automatically - wait for tutorial dismissal
                    // Animation will be triggered after stardust tutorial is dismissed
                    
                    // Set timer to minimize UpdateCard after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        print("🔄 MainZodiacView: 5 seconds elapsed, posting updateCardShouldMinimize notification")
                        NotificationCenter.default.post(name: .updateCardShouldMinimize, object: nil)
                    }
                }
            }
            if completedOnboarding {
                ZStack {
                    // Background layer (implicit z-index 0)
                    
                    VStack(spacing: headerFlipBookSpacing) {
                        // Header layer - pinned to top
                        ZStack {
                            ZodiacHeader(
                                profileImage: "logo",
                                onSettingsTap: {
                                    showingSettings = true
                                 }, displayMode: .main,
                                 showMenu: hasAcceptedConsentPolicies,
                                 onWellness: {
                                     print("🔍 MainZodiacView: onWellness callback triggered")
                                     wellnessDisplayName = "Wellness"
                                     showWellnessConversation = true
                                 },
                                 onRelationship: {
                                     print("🔍 MainZodiacView: onRelationship callback triggered")
                                     relationshipDisplayName = "Relationship"
                                     showRelationshipConversation = true
                                 },
                                 onImportantPeople: {
                                     print("🔍 MainZodiacView: onImportantPeople callback triggered")
                                     print("🔍 MainZodiacView: Setting importantPeopleDisplayName to 'Important People'")
                                     importantPeopleDisplayName = "Important People"
                                     print("🔍 MainZodiacView: importantPeopleDisplayName is now '\(importantPeopleDisplayName)'")
                                     showImportantPeopleConversation = true
                                     print("🔍 MainZodiacView: showImportantPeopleConversation set to true")
                                 },
                                 onChildren: {
                                     childrenDisplayName = "Children"
                                     showChildrenConversation = true
                                 },
                                 onEmployment: {
                                     employmentDisplayName = "Employment"
                                     showEmploymentConversation = true
                                 },
                                 highlightedButton: getHighlightedQuestionMenuButton()
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                            .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
                                self.headerHeight = headerHeight
                            }
                            
                            // Stardust tutorial popup below profile badge
                            if showStardustTutorial {
                                Spacer()
                                VStack {
                                    
                                    TutorialBubble(
                                        type: .custom(title: "Stardust Rewards", subtitle: "Your earned stardust points appear here on your profile badge", icon: "sparkles"),
                                        arrowPosition: .topleft,
                                        pulse: true,
                                        onDismiss: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showStardustTutorial = false
                                                hasShownStardustTutorial = true
                                            }
                                            
                                            // Trigger stardust earning animation after tutorial is dismissed
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                // Earn the stardust that was supposed to be earned after onboarding
                                                stardustManager?.earnStardust(
                                                    amount: 25,
                                                    type: .achievement,
                                                    description: "Completed onboarding and received your first horoscope"
                                                )
                                                hasTriggeredStardustAnimation = true
                                            }
                                        },
                                        showArrow: false
                                    )
                                    .padding(.top, 80) // Position below profile badge
                                    .transition(.opacity.combined(with: .scale))
                                }
                                .zIndex(getZIndex(.five))
                            }
                        }
                    
                        
                        // FlipBook layer directly under header (gated by consent)
                        if hasAcceptedConsentPolicies {
                            // Push FlipBook toward bottom to reduce bottom gap
                            //                            Spacer(minLength: 0)
                            
                            FlipBook(pages: createFlipBookCards())
                                .padding(.bottom, 8)
                                .zIndex(activeComponent == .flipBook ? getZIndex(.active) : getZIndex(.one))
                                .onAppear {
                                    // Check for welcome horoscope when view appears
                                    _ = fetchWelcomeHoroscope()
                                }
                                .onReceive(Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()) { _ in
                                    // Check for welcome horoscope periodically until loaded
                                    if !isWelcomeHoroscopeLoaded {
                                        _ = fetchWelcomeHoroscope()
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .welcomeHoroscopeReady)) { _ in
                                    // Refresh welcome horoscope when notification is received
                                    _ = fetchWelcomeHoroscope()
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .flipBookMoveToTop)) { _ in
                                    // Adjust spacing when FlipBook moves to top
                                    adjustHeaderFlipBookSpacing(expanded: true)
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .flipBookCollapsed)) { _ in
                                    // Reset spacing when FlipBook collapses
                                    adjustHeaderFlipBookSpacing(expanded: false)
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .flipBookActivated)) { _ in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        activeComponent = .flipBook
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .componentDeactivated)) { _ in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        activeComponent = .none
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .flipBookIndexChanged)) { notification in
                                    if let index = notification.userInfo?["index"] as? Int {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            currentFlipBookIndex = index
                                        }
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .conversationProgressUpdated)) { _ in
                                    print("🔄 MainZodiacView: Received conversationProgressUpdated notification - individual cards will update automatically")
                                }
                                .onPreferenceChange(FlipBookCardBottomPreferenceKey.self) { bottomPosition in
                                    flipBookCardBottomPosition = bottomPosition
                                    print("📍 FlipBookCard bottom position: \(bottomPosition)")
                                }
                                .id(isWelcomeHoroscopeLoaded) // Force re-creation only when loading state changes
                        }
                        
                        Spacer()
                    }
                    .zIndex(getZIndex(.two))

                    // Hand Draw Animation overlay
//                    if hasAcceptedConsentPolicies && showHandAnimation {
//                        VStack {
//                            Spacer()
//                            ZStack {
//                                // Hand Draw Animation
//                                HandDrawAnimation(description: "Tap to Dismiss")
//                            }
//                            .onTapGesture {
//                                withAnimation(.easeInOut(duration: 0.3)) {
//                                    showHandAnimation = false
//                                }
//                            }
//                            Spacer()
//                        }
//                        .zIndex(getZIndex(.three))
//                    }
                    
                    // UpdateCard layer (topmost) - disable interaction until consent is accepted
                    UpdateCard()
                        .allowsHitTesting(hasAcceptedConsentPolicies)
                        .zIndex(activeComponent == .updateCard ? getZIndex(.active) : getZIndex(.three))
                        .onReceive(NotificationCenter.default.publisher(for: .updateCardShouldMinimize)) { _ in
                            updateCardShouldMinimize = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .updateCardActivated)) { _ in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeComponent = .updateCard
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .componentDeactivated)) { _ in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeComponent = .none
                            }
                        }
                        .onAppear {
                            // Show tutorial popups for users who just completed onboarding or have accepted consent
                            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                            if hasAcceptedConsentPolicies || hasCompletedOnboarding {
                                if !hasShownUpdateTutorial {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            showUpdateTutorial = true
                                        }
                                    }
                                }

                                // Show stardust tutorial popup
                                if !hasShownStardustTutorial {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            showStardustTutorial = true
                                        }
                                    }
                                }
                            }
                        }
                    
                    // Tutorial popup at bottom of screen
                    if showUpdateTutorial {
                        VStack {
                            Spacer()
                            
                            TutorialBubble(
                                type: .custom(title: "Instant Life Updates", subtitle: "Share your thoughts and receive stardust rewards for your daily reflections", icon: "sparkles"),
                                arrowPosition: .top,
                                pulse: true,
                                onDismiss: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showUpdateTutorial = false
                                        hasShownUpdateTutorial = true
                                    }
                                },
                                showArrow: false
                            )
                            .padding(.bottom, 20) // Position at bottom of screen
                            .transition(.opacity.combined(with: .scale))
                        }
                        .zIndex(getZIndex(.four))
                    }
                }
            }
            
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showWellnessConversation) {
            ConversationView(
                conversationSteps: wellnessConversationSteps,
                displayName: $wellnessDisplayName,
                onResponse: { input, step in
                    print("[Wellness Response] \(step.dataKey): \(input)")
                    handleConversationResponse(input: input, step: step, topic: .wellness)
                },
                onComplete: {
                    showWellnessConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .wellness
            )
            .onAppear {
                print("🔍 MainZodiacView: Starting Wellness conversation with questionCategory = .wellness")
                print("🔍 MainZodiacView: wellnessDisplayName = '\(wellnessDisplayName)'")
            }
            .ignoresSafeArea(.container, edges: .top)
            .presentationDetents([.large])
            .presentationCornerRadius(0)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showRelationshipConversation) {
            ConversationView(
                conversationSteps: relationshipConversationSteps,
                displayName: $relationshipDisplayName,
                onResponse: { input, step in
                    print("[Relationship Response] \(step.dataKey): \(input)")
                    handleConversationResponse(input: input, step: step, topic: .relationship)
                },
                onComplete: {
                    showRelationshipConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .relationship
            )
            .ignoresSafeArea(.container, edges: .top)
            .presentationDetents([.large])
            .presentationCornerRadius(0)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showImportantPeopleConversation) {
            ConversationView(
                conversationSteps: importantPeopleConversationSteps,
                displayName: $importantPeopleDisplayName,
                onResponse: { input, step in
                    print("[Important People Response] \(step.dataKey): \(input)")
                    handleConversationResponse(input: input, step: step, topic: .importantPeople)
                },
                onComplete: {
                    showImportantPeopleConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .importantPeople
            )
            .onAppear {
                print("🔍 MainZodiacView: Starting Important People conversation with questionCategory = .importantPeople")
                print("🔍 MainZodiacView: importantPeopleDisplayName = '\(importantPeopleDisplayName)'")
            }
            .ignoresSafeArea(.container, edges: .top)
            .presentationDetents([.large])
            .presentationCornerRadius(0)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showChildrenConversation) {
            ConversationView(
                conversationSteps: childrenConversationSteps,
                displayName: $childrenDisplayName,
                onResponse: { input, step in
                    print("[Children Response] \(step.dataKey): \(input)")
                    handleConversationResponse(input: input, step: step, topic: .children)
                },
                onComplete: {
                    showChildrenConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .children
            )
            .ignoresSafeArea(.container, edges: .top)
            .presentationDetents([.large])
            .presentationCornerRadius(0)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showEmploymentConversation) {
            ConversationView(
                conversationSteps: employmentConversationSteps,
                displayName: $employmentDisplayName,
                onResponse: { input, step in
                    print("[Employment Response] \(step.dataKey): \(input)")
                    handleConversationResponse(input: input, step: step, topic: .employment)
                },
                onComplete: {
                    showEmploymentConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .employment
            )
            .ignoresSafeArea(.container, edges: .top)
            .presentationDetents([.large])
            .presentationCornerRadius(0)
            .presentationDragIndicator(.hidden)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTutorialBubbles)) { _ in
            // Respect persisted dismissal flags when showing tutorials via notification
            DispatchQueue.main.async {
                if !hasShownUpdateTutorial {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showUpdateTutorial = true
                    }
                }
                // Slight delay to stagger the appearance
                if !hasShownStardustTutorial {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showStardustTutorial = true
                        }
                    }
                }
            }
        }
    }
    
    private func triggerStardustAnimation() {
        guard let stardustManager = stardustManager else {
            print("⚠️ MainZodiacView: StardustManager not available")
            return
        }
        
        print("🎯 MainZodiacView: Current stardust balance: \(stardustManager.currentBalance)")
        
        // Check if user has completed onboarding and has stardust to show
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding && stardustManager.currentBalance > 0 {
            print("🎯 MainZodiacView: User has completed onboarding with \(stardustManager.currentBalance) stardust - triggering animation")
            
            // Trigger the stardust earned notification to show the animation
            // Use a small amount (1) to trigger the animation without changing the balance
            NotificationCenter.default.post(
                name: .stardustEarned,
                object: nil,
                userInfo: [
                    "amount": 1, // Small amount to trigger animation
                    "type": StardustTransactionType.achievement
                ]
            )
        } else {
            print("🎯 MainZodiacView: No stardust animation needed - onboarding: \(hasCompletedOnboarding), balance: \(stardustManager.currentBalance)")
        }
    }
    
    // MARK: - FlipBook Cards
    
    private func createFlipBookCards() -> [FlipBookCard] {
        var cards: [FlipBookCard] = []
        
        // Add welcome horoscope as first card
        if let welcomeHoroscope = welcomeHoroscope {
            print("🎯 MainZodiacView: Creating welcome horoscope card with content")
            print("🎯 MainZodiacView: Horoscope title: '\(welcomeHoroscope.title)'")
            print("🎯 MainZodiacView: Horoscope message length: \(welcomeHoroscope.message.count) characters")
            cards.append(FlipBookCard(
                horoscope: welcomeHoroscope,
                isLoading: false
            ))
        } else {
            print("🎯 MainZodiacView: Creating welcome horoscope card with loading state")
            print("🎯 MainZodiacView: welcomeHoroscope is nil")
            // Show loading state for welcome horoscope if not available yet
            cards.append(FlipBookCard(
                horoscope: nil,
                isLoading: true
            ))
        }

        // Add remaining default cards
        cards.append(contentsOf: [
            FlipBookCard(
                title: "Wellness",
                content: "Start your intake",
//                onCardTap: { showWellnessConversation = true },
                showStartButton: true,
                onStartButtonTap: {
                    wellnessDisplayName = "Wellness"
                    showWellnessConversation = true
                }
            ),
            FlipBookCard(
                title: "Partner",
                content: "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    relationshipDisplayName = "Relationship"
                    showRelationshipConversation = true
                }
            ),
            FlipBookCard(
                title: "Important People",
                content: "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    importantPeopleDisplayName = "Important People"
                    showImportantPeopleConversation = true
                }
            ),
            FlipBookCard(
                title: "Children",
                content: "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    childrenDisplayName = "Children"
                    showChildrenConversation = true
                }
            ),
            FlipBookCard(
                title: "Employment",
                content: "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    employmentDisplayName = "Employment"
                    showEmploymentConversation = true
                }
            )
        ])
        
        return cards
    }
    
    // MARK: - FlipBook Spacing Control
    
    private func adjustHeaderFlipBookSpacing(expanded: Bool) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
            headerFlipBookSpacing = expanded ? -200 : headerFlipBookSpacingDefault
        }
    }
    
    // MARK: - Helper Functions
    
    private func getQuestionCategoryFromDisplayName(_ displayName: String) -> QuestionMenuButton {
        print("🔍 MainZodiacView: getQuestionCategoryFromDisplayName called with '\(displayName)'")
        let result: QuestionMenuButton
        switch displayName {
        case "Wellness":
            result = .wellness
        case "Relationship":
            result = .relationship
        case "Important People":
            result = .importantPeople
        case "Children":
            result = .children
        case "Employment":
            result = .employment
        default:
            result = .wellness
        }
        print("🔍 MainZodiacView: getQuestionCategoryFromDisplayName returning \(result)")
        return result
    }
    
    private func fetchWelcomeHoroscope() -> Horoscope? {
        do {
            let descriptor = FetchDescriptor<Horoscope>(
                predicate: #Predicate<Horoscope> { $0.key == "welcome" }
            )
            let horoscopes = try modelContext.fetch(descriptor)
            let horoscope = horoscopes.first
            
            // Update loading state and trigger UI refresh
            DispatchQueue.main.async {
                let wasLoaded = self.isWelcomeHoroscopeLoaded
                self.welcomeHoroscope = horoscope
                self.isWelcomeHoroscopeLoaded = horoscope != nil
                
                // If the loading state changed, print for debugging
                if wasLoaded != self.isWelcomeHoroscopeLoaded {
                    print("🎯 MainZodiacView: Welcome horoscope loading state changed to \(self.isWelcomeHoroscopeLoaded)")
                }
            }
            
            return horoscope
        } catch {
            print("❌ Failed to fetch welcome horoscope: \(error)")
            return nil
        }
    }
}

#Preview {
    // Set consent to false for testing
    UserDefaults.standard.set(true, forKey: "hasAcceptedConsentPolicies")
    
    // Create a preview-specific view that ensures data is loaded
    return MainZodiacView(completedOnboarding: true)
        .environmentObject(AuthenticationManager())
}
