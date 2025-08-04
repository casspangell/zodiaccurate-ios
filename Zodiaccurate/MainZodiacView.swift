import SwiftUI

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var stardustManager: StardustManager?
    @State private var showingSettings = false
    @State private var splashViewDismissed = false
    @State private var cameFromHoroscopeSplash = false
    @State private var hasTriggeredStardustAnimation = false
    @StateObject private var badgeAnimationManager = BadgeAnimationManager()
    
    let completedOnboarding: Bool
    
    init(completedOnboarding: Bool = false) {
        self.completedOnboarding = completedOnboarding
    }
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            // Clear rectangle at top for users coming from HoroscopeSplashView to ensure background visibility
            if cameFromHoroscopeSplash {
                VStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: getSafeAreaTop())
                        .frame(maxWidth: .infinity, alignment: .top)
                        .ignoresSafeArea(.all, edges: .top)
                        .zIndex(999) // Add high z-index to ensure it's visible
                        .onAppear {
                        }
                    Spacer()
                }
                .zIndex(999) // Also add z-index to the VStack
            }
            
            VStack(spacing: 0) {
                if splashViewDismissed || completedOnboarding {
                    ZodiacHeader(
                        profileImage: "Leo",
                        badgeScale: 1.0,
                        badgeRotation: 0,
                        cosmicGlowOpacity: 0.5,
                        nebulaOpacity: 0.3,
                        starFieldOpacity: 0.4,
                        cosmicParticlesOpacity: 0.6,
                        sparkleOpacity: 0.8,
                        stardustPoints: stardustManager?.currentBalance ?? 0,
                        badgeSize: nil,
                        horoscopeDate: "Monday\nJanuary 5, 2025",
                        onSettingsTap: {
                            showingSettings = true
                        },
                        badgeAnimationManager: badgeAnimationManager
                    )
                    .onAppear {
                        print("🎯 MainZodiacView: ZodiacHeaderFull appeared with stardust: \(stardustManager?.currentBalance ?? 0)")
                    }
//                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.5), value: splashViewDismissed)
                    .padding(.top, cameFromHoroscopeSplash ? getSafeAreaTop() : 0) // Align with purple rectangle bottom
                }
                
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
                    },
                    completedOnboarding: completedOnboarding
                )
                .environmentObject(authManager)
                .onAppear {
                    // Initialize StardustManager
                    if stardustManager == nil {
                        stardustManager = StardustManager()
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
            if splashViewDismissed || completedOnboarding {
                UpdateCard()
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
