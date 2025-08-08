import SwiftUI

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var stardustManager: StardustManager?
    @State private var showingSettings = false
    @State private var splashViewDismissed = false
    @State private var cameFromHoroscopeSplash = false
    @State private var hasTriggeredStardustAnimation = false
    @State private var headerDisplayMode: ZodiacHeaderDisplayMode = .initial
    @AppStorage("hasAcceptedConsentPolicies") private var hasAcceptedConsentPolicies = false
    
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
                    
                    // Always trigger stardust animation when MainZodiacView loads (with 3-second delay)
                    if !hasTriggeredStardustAnimation {
                        print("🎯 MainZodiacView: Scheduling stardust animation with 3-second delay")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            triggerStardustAnimation()
                            hasTriggeredStardustAnimation = true
                        }
                    }
                }
            }
            if completedOnboarding {
                ZStack {
                    // Background layer (implicit z-index 0)
                    
                    VStack(spacing: 0) {
                        // Header layer - pinned to top
                        ZodiacHeader(
                            profileImage: "logo",
                            onSettingsTap: {
                                showingSettings = true
                            }, displayMode: .main
                        )
                        .frame(maxWidth: .infinity)
                        
                        // FlipBook layer directly under header (gated by consent)
                        if hasAcceptedConsentPolicies {
                            FlipBook()
                                .padding(.top, 40)
                        }
                        
                        Spacer()
                    }
                    .zIndex(2)
                    
                    // UpdateCard layer (topmost) - disable interaction until consent is accepted
                    UpdateCard()
                        .allowsHitTesting(hasAcceptedConsentPolicies)
                        .zIndex(3)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
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
}

#Preview {
    // Set consent to false for testing
    UserDefaults.standard.set(true, forKey: "hasAcceptedConsentPolicies")
    
    // Create a preview-specific view that ensures data is loaded
    return MainZodiacView(completedOnboarding: false)
        .environmentObject(AuthenticationManager())
}
