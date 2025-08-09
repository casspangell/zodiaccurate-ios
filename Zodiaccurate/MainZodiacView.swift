import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var stardustManager: StardustManager?
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
                }
            }
            if completedOnboarding {
                ZStack {
                    // Background layer (implicit z-index 0)
                    
                    VStack(spacing: 0) {
                        // Header layer - pinned to top
                        ZStack {
                            ZodiacHeader(
                                profileImage: "logo",
                                onSettingsTap: {
                                    showingSettings = true
                                }, displayMode: .main
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                            
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
                                .zIndex(5)
                            }
                        }
                        
                        // FlipBook layer directly under header (gated by consent)
                        if hasAcceptedConsentPolicies {
                            // Question menu above FlipBook
                            QuestionMenu(
                                onWellness: {
                                    wellnessDisplayName = "Wellness"
                                    showWellnessConversation = true
                                },
                                onRelationship: {
                                    print("Relationship menu tapped")
                                },
                                onPartner: {
                                    print("Partner menu tapped")
                                },
                                onImportantPeople: {
                                    print("Important People menu tapped")
                                },
                                onChildren: {
                                    print("Children menu tapped")
                                },
                                onEmployment: {
                                    print("Employment menu tapped")
                                }
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                            // Push FlipBook toward bottom to reduce bottom gap
                            Spacer(minLength: 0)

                            FlipBook(pages: createFlipBookCards())
                                .padding(.bottom, 8)
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
                                .id(isWelcomeHoroscopeLoaded) // Force re-creation when loading state changes
                        }
                        
                        Spacer()
                    }
                    .zIndex(2)
                    
                    // UpdateCard layer (topmost) - disable interaction until consent is accepted
                    UpdateCard()
                        .allowsHitTesting(hasAcceptedConsentPolicies)
                        .zIndex(3)
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
                        .zIndex(4)
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
                },
                onComplete: {
                    showWellnessConversation = false
                },
                topInsetMode: .compact
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
    
    private func createFlipBookCards() -> [ZodiacCard] {
        var cards: [ZodiacCard] = []
        
        // Add welcome horoscope as first card
        if let welcomeHoroscope = welcomeHoroscope {
            print("🎯 MainZodiacView: Creating welcome horoscope card with content")
            cards.append(ZodiacCard(
                horoscope: welcomeHoroscope,
                isLoading: false
            ))
        } else {
            print("🎯 MainZodiacView: Creating welcome horoscope card with loading state")
            // Show loading state for welcome horoscope if not available yet
            cards.append(ZodiacCard(
                horoscope: nil,
                isLoading: true
            ))
        }
        
        // Add Wellness card as the 2nd card in the stack
        cards.append(
            ZodiacCard(
                title: "Wellness",
                content: "Start your personal wellness intake",
                onTap: { showWellnessConversation = true }
            )
        )
        
        // Add remaining default cards
        cards.append(contentsOf: [
            ZodiacCard(
                title: "Daily Horoscope",
                content: "Discover what the stars have in store for you today"
            ),
            ZodiacCard(
                title: "Weekly Forecast",
                content: "Plan your week with cosmic guidance"
            ),
            ZodiacCard(
                title: "Monthly Insights",
                content: "Deep dive into your monthly astrological journey"
            )
        ])
        
        return cards
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
    return MainZodiacView(completedOnboarding: false)
        .environmentObject(AuthenticationManager())
}
