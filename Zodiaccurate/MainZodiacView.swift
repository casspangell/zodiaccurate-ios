import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var stardustManager: StardustManager?
    @State private var intakeDataManager: IntakeDataManager?
    @StateObject private var userProfileManager = UserProfileManager()
    @State private var currentStardustBalance: Int = 0
    @Query private var users: [User]
    @Query private var stardustRecords: [Stardust]
    @State private var showingSettings = false
    @State private var showingEditProfile = false
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
    
    // Questionnaire response tracking
    @State private var wellnessResponses: [String: Any] = [:]
    @State private var relationshipResponses: [String: Any] = [:]
    @State private var importantPeopleResponses: [String: Any] = [:]
    @State private var childrenResponses: [String: Any] = [:]
    @State private var employmentResponses: [String: Any] = [:]
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
    
    // Computed property that changes when completion status changes, forcing FlipBook to re-render
    private var flipBookId: String {
        let userId = authManager.user?.uid ?? "default"
        let wellnessCompleted = checkQuestionnaireCompletion(topic: "wellness", userId: userId) ? "1" : "0"
        let relationshipCompleted = checkQuestionnaireCompletion(topic: "relationship", userId: userId) ? "1" : "0"
        let importantPeopleCompleted = checkQuestionnaireCompletion(topic: "importantPeople", userId: userId) ? "1" : "0"
        let childrenCompleted = checkQuestionnaireCompletion(topic: "children", userId: userId) ? "1" : "0"
        let employmentCompleted = checkQuestionnaireCompletion(topic: "employment", userId: userId) ? "1" : "0"
        return "\(wellnessCompleted)-\(relationshipCompleted)-\(importantPeopleCompleted)-\(childrenCompleted)-\(employmentCompleted)"
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
            
            // Track question and answer for Firebase
            let userName = userProfileManager.firstName.isEmpty ? (users.first?.firstName ?? "") : userProfileManager.firstName
            let personalizedQuestion = personalizeMessage(step.message, with: userName)
            
            // Get the appropriate responses dictionary based on topic
            switch topic {
            case .wellness:
                wellnessResponses[step.dataKey] = input
                wellnessResponses["question_\(step.dataKey)"] = personalizedQuestion
            case .relationship:
                relationshipResponses[step.dataKey] = input
                relationshipResponses["question_\(step.dataKey)"] = personalizedQuestion
            case .importantPeople:
                importantPeopleResponses[step.dataKey] = input
                importantPeopleResponses["question_\(step.dataKey)"] = personalizedQuestion
            case .children:
                childrenResponses[step.dataKey] = input
                childrenResponses["question_\(step.dataKey)"] = personalizedQuestion
            case .employment:
                employmentResponses[step.dataKey] = input
                employmentResponses["question_\(step.dataKey)"] = personalizedQuestion
            case .none:
                break
            }
        } else {
            print("⚠️ Unknown topic for QuestionMenuButton: \(topic)")
        }
    }
    
    /// Save questionnaire responses to Firebase
    private func saveQuestionnaireToFirebase(topic: QuestionMenuButton, questionnaireTitle: String) {
        guard let userId = authManager.user?.uid else {
            print("⚠️ Cannot save questionnaire to Firebase: User not authenticated")
            return
        }
        
        let responses: [String: Any]
        switch topic {
        case .wellness:
            responses = wellnessResponses
        case .relationship:
            responses = relationshipResponses
        case .importantPeople:
            responses = importantPeopleResponses
        case .children:
            responses = childrenResponses
        case .employment:
            responses = employmentResponses
        case .none:
            return
        }
        
        guard !responses.isEmpty else {
            print("⚠️ No responses to save for \(questionnaireTitle)")
            return
        }
        
        Task {
            do {
                let firebaseService = FirebaseDatabaseService()
                try await firebaseService.saveQuestionnaireResponses(
                    userId: userId,
                    questionnaireTitle: questionnaireTitle,
                    responses: responses
                )
                print("✅ Saved \(questionnaireTitle) questionnaire to Firebase")
            } catch {
                print("❌ Failed to save \(questionnaireTitle) questionnaire to Firebase: \(error)")
            }
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
                    // Initialize StardustManager with SwiftData integration and Firebase userId
                    if stardustManager == nil {
                        let userId = authManager.user?.uid
                        stardustManager = StardustManager(modelContext: modelContext, userId: userId)
                    } else {
                        // Update userId if it changed (e.g., user logged in)
                        stardustManager?.userId = authManager.user?.uid
                    }
                    
                    // Load or create Stardust instance from SwiftData
                    Task { @MainActor in
                        await loadOrCreateStardustFromSwiftData()
                    }
                    
                    // Initialize IntakeDataManager
                    if intakeDataManager == nil {
                        intakeDataManager = IntakeDataManager(modelContext: modelContext)
                    }
                    
                    // Load welcome horoscope from SwiftData immediately when view appears
                    Task { @MainActor in
                        await loadWelcomeHoroscopeFromSwiftData()
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
                                profileImage: zodiacImageName(),
                                stardustPoints: currentStardustBalance,
                                onSettingsTap: {
                                    showingSettings = true
                                 },
                                onProfileBadgeTap: {
                                    showingEditProfile = true
                                },
                                displayMode: .main,
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
                                    importantPeopleDisplayName = "Important People"
                                    showImportantPeopleConversation = true
                                },
                                onChildren: {
                                    childrenDisplayName = "Children"
                                    showChildrenConversation = true
                                },
                                onEmployment: {
                                    employmentDisplayName = "Employment"
                                    showEmploymentConversation = true
                                },
                                 highlightedButton: getHighlightedQuestionMenuButton(),
                                userId: authManager.user?.uid
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
                                .id(flipBookId) // Force re-creation when completion status changes
                                .onAppear {
                                    // Initial fetch already happened in parent onAppear, but check again here
                                    if !isWelcomeHoroscopeLoaded {
                                        Task { @MainActor in
                                            await loadWelcomeHoroscopeFromSwiftData()
                                        }
                                    }
                                }
                                .onReceive(Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()) { _ in
                                    // Poll for updates if not loaded yet (e.g., if it's being generated)
                                    if !isWelcomeHoroscopeLoaded {
                                        Task { @MainActor in
                                            await loadWelcomeHoroscopeFromSwiftData()
                                        }
                                    }
                                }
                                .onReceive(NotificationCenter.default.publisher(for: .welcomeHoroscopeReady)) { _ in
                                    // Refresh when notification is received (horoscope was just saved)
                                    Task { @MainActor in
                                        await loadWelcomeHoroscopeFromSwiftData()
                                    }
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
                                    print("🔄 MainZodiacView: Received conversationProgressUpdated notification - refreshing FlipBook cards")
                                    // The flipBookId will change, causing FlipBook to recreate with updated completion status
                                }
                                .onPreferenceChange(FlipBookCardBottomPreferenceKey.self) { bottomPosition in
                                    flipBookCardBottomPosition = bottomPosition
                                    print("📍 FlipBookCard bottom position: \(bottomPosition)")
                                }
                                .id(welcomeHoroscope?.key ?? "loading") // Force re-creation when horoscope changes
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
                    UpdateCard(stardustManager: stardustManager)
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
        .onAppear {
            printUserProfileDetails()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(onProfileSaved: {
                syncUserDataToProfileManager()
            })
            .environmentObject(authManager)
        }
        .onChange(of: showingSettings) { _, newValue in
            // When settings are dismissed, refresh the header by syncing SwiftData to UserProfileManager
            if !newValue {
                syncUserDataToProfileManager()
            }
        }
        .onChange(of: showingEditProfile) { _, newValue in
            // When edit profile is dismissed, refresh the header by syncing SwiftData to UserProfileManager
            if !newValue {
                syncUserDataToProfileManager()
            }
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
                    saveQuestionnaireToFirebase(topic: .wellness, questionnaireTitle: "Wellness")
                    wellnessResponses = [:]
                    showWellnessConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .wellness
            )
            .onAppear {
                wellnessResponses = [:]
            }
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
                    saveQuestionnaireToFirebase(topic: .relationship, questionnaireTitle: "Relationship")
                    relationshipResponses = [:]
                    showRelationshipConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .relationship
            )
            .onAppear {
                relationshipResponses = [:]
            }
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
                    saveQuestionnaireToFirebase(topic: .importantPeople, questionnaireTitle: "Important People")
                    importantPeopleResponses = [:]
                    showImportantPeopleConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .importantPeople
            )
            .onAppear {
                importantPeopleResponses = [:]
            }
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
                    saveQuestionnaireToFirebase(topic: .children, questionnaireTitle: "Children")
                    childrenResponses = [:]
                    showChildrenConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .children
            )
            .onAppear {
                childrenResponses = [:]
            }
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
                    saveQuestionnaireToFirebase(topic: .employment, questionnaireTitle: "Employment")
                    employmentResponses = [:]
                    showEmploymentConversation = false
                },
                topInsetMode: .compact,
                questionCategory: .employment
            )
            .onAppear {
                employmentResponses = [:]
            }
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
        .onReceive(NotificationCenter.default.publisher(for: .stardustEarned)) { _ in
            // Update balance when stardust is earned
            if let balance = stardustManager?.currentBalance {
                currentStardustBalance = balance
            }
        }
        .onChange(of: stardustManager?.currentBalance) { oldValue, newValue in
            // Update balance when StardustManager's balance changes
            if let newBalance = newValue {
                currentStardustBalance = newBalance
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

        // Add remaining default cards with completion status
        // Check both ConversationProgressManager (UserDefaults) and IntakeData (SwiftData)
        let userId = authManager.user?.uid ?? "default"
        let isWellnessCompleted = checkQuestionnaireCompletion(topic: "wellness", userId: userId)
        let isRelationshipCompleted = checkQuestionnaireCompletion(topic: "relationship", userId: userId)
        let isImportantPeopleCompleted = checkQuestionnaireCompletion(topic: "importantPeople", userId: userId)
        let isChildrenCompleted = checkQuestionnaireCompletion(topic: "children", userId: userId)
        let isEmploymentCompleted = checkQuestionnaireCompletion(topic: "employment", userId: userId)
        
        cards.append(contentsOf: [
            FlipBookCard(
                title: "Wellness",
                content: isWellnessCompleted ? "Intake completed" : "Start your intake",
//                onCardTap: { showWellnessConversation = true },
                showStartButton: true,
                onStartButtonTap: {
                    wellnessDisplayName = "Wellness"
                    showWellnessConversation = true
                },
                isCompleted: isWellnessCompleted
            ),
            FlipBookCard(
                title: "Partner",
                content: isRelationshipCompleted ? "Intake completed" : "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    relationshipDisplayName = "Relationship"
                    showRelationshipConversation = true
                },
                isCompleted: isRelationshipCompleted
            ),
            FlipBookCard(
                title: "Important People",
                content: isImportantPeopleCompleted ? "Intake completed" : "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    importantPeopleDisplayName = "Important People"
                    showImportantPeopleConversation = true
                },
                isCompleted: isImportantPeopleCompleted
            ),
            FlipBookCard(
                title: "Children",
                content: isChildrenCompleted ? "Intake completed" : "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    childrenDisplayName = "Children"
                    showChildrenConversation = true
                },
                isCompleted: isChildrenCompleted
            ),
            FlipBookCard(
                title: "Employment",
                content: isEmploymentCompleted ? "Intake completed" : "Start your intake",
                showStartButton: true,
                onStartButtonTap: {
                    employmentDisplayName = "Employment"
                    showEmploymentConversation = true
                },
                isCompleted: isEmploymentCompleted
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
    
    /// Check if a questionnaire is completed by checking both ConversationProgressManager and IntakeData
    /// This checks SwiftData (IntakeData) on app load to determine completion status
    private func checkQuestionnaireCompletion(topic: String, userId: String) -> Bool {
        // First check ConversationProgressManager (UserDefaults - tracks step progress)
        // This is the primary source of truth for completion
        let progressCompleted = ConversationProgressManager.isTopicCompleted(for: topic)
        
        if progressCompleted {
            return true
        }
        
        // Fallback: Also check IntakeData (SwiftData - tracks actual data saved)
        // This ensures we catch completions even if progress wasn't saved properly
        if let intakeDataManager = intakeDataManager {
            let hasData = intakeDataManager.hasTopicData(userId: userId, topic: topic)
            if hasData {
                let topicData = intakeDataManager.getTopicData(userId: userId, topic: topic)
                let totalSteps = ConversationProgressManager.getTotalStepsForTopic(topic)
                // If we have data for most steps (80% or more), consider it completed
                // This handles edge cases where progress wasn't saved but data was
                if topicData.count >= Int(Double(totalSteps) * 0.8) {
                    print("✅ MainZodiacView: Topic '\(topic)' considered completed based on IntakeData (has \(topicData.count)/\(totalSteps) answers)")
                    return true
                }
            }
        }
        
        return false
    }
    
    private func zodiacImageName() -> String {
        // First check SwiftData User, then fallback to UserProfileManager
        if let user = users.first, !user.zodiacSign.isEmpty, let sign = ZodiacSign(rawValue: user.zodiacSign) {
            return sign.assetName
        }
        let signName = userProfileManager.zodiacSign
        if !signName.isEmpty, let sign = ZodiacSign(rawValue: signName) {
            return sign.assetName
        }
        return "logo"
    }
    
    private func syncUserDataToProfileManager() {
        // Sync SwiftData User data to UserProfileManager for compatibility
        if let user = users.first {
            // Update first name
            if !user.firstName.isEmpty {
                userProfileManager.updateFirstName(user.firstName)
            }
            
            // Update birth date and time to trigger zodiac sign recalculation
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            if let birthDate = dateFormatter.date(from: user.birthDate) {
                userProfileManager.updateBirthDate(birthDate)
            }
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            if let birthTime = timeFormatter.date(from: user.birthTime) {
                userProfileManager.updateBirthTime(birthTime)
            }
            
            // Also directly sync zodiac sign in case it was updated independently
            if !user.zodiacSign.isEmpty {
                userProfileManager.zodiacSign = user.zodiacSign
                UserDefaults.standard.set(user.zodiacSign, forKey: "userZodiacSign")
            }
        }
    }

    private func printUserProfileDetails() {
        print("👤 MainZodiacView loaded. User profile details →")
        print("   • First Name: '\(userProfileManager.firstName)'")
        print("   • Birth Date: '\(userProfileManager.birthDate)'")
        print("   • Birth Time: '\(userProfileManager.birthTime)'")
        print("   • Zodiac Sign: '\(userProfileManager.zodiacSign)'\n")
    }

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
    
    @MainActor
    private func loadOrCreateStardustFromSwiftData() async {
        guard let stardustManager = stardustManager else {
            print("⚠️ MainZodiacView: StardustManager not initialized")
            return
        }
        
        do {
            // Fetch existing Stardust records
            let descriptor = FetchDescriptor<Stardust>()
            let stardustRecords = try modelContext.fetch(descriptor)
            
            if let existingStardust = stardustRecords.first {
                // Load existing Stardust instance
                stardustManager.loadFromSwiftData(existingStardust)
                currentStardustBalance = existingStardust.balance
                print("✅ MainZodiacView: Loaded existing Stardust from SwiftData - Balance: \(existingStardust.balance)")
            } else {
                // Create new Stardust instance if none exists
                let newStardust = stardustManager.createStardustInstance(in: modelContext)
                stardustManager.loadFromSwiftData(newStardust)
                currentStardustBalance = 0
                print("✅ MainZodiacView: Created new Stardust instance in SwiftData")
            }
        } catch {
            print("❌ MainZodiacView: Failed to load or create Stardust from SwiftData: \(error)")
        }
    }
    
    @MainActor
    private func loadWelcomeHoroscopeFromSwiftData() async {
        do {
            let descriptor = FetchDescriptor<Horoscope>(
                predicate: #Predicate<Horoscope> { $0.key == "welcome" }
            )
            let horoscopes = try modelContext.fetch(descriptor)
            let horoscope = horoscopes.first
            
            // Update state on main thread
            let wasLoaded = self.isWelcomeHoroscopeLoaded
            self.welcomeHoroscope = horoscope
            self.isWelcomeHoroscopeLoaded = horoscope != nil
            
            if wasLoaded != self.isWelcomeHoroscopeLoaded {
                print("🎯 MainZodiacView: Welcome horoscope loading state changed to \(self.isWelcomeHoroscopeLoaded)")
                if let horoscope = horoscope {
                    print("✅ MainZodiacView: Loaded welcome horoscope from SwiftData - Title: '\(horoscope.title)'")
                } else {
                    print("⏳ MainZodiacView: Welcome horoscope not found in SwiftData yet, will continue polling")
                }
            }
        } catch {
            print("❌ Failed to fetch welcome horoscope from SwiftData: \(error)")
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
