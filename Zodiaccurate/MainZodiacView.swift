import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var onboardingDataAccess: OnboardingDataAccess?
    @State private var showingSettings = false
    @State private var splashViewDismissed = false
    @State private var cameFromHoroscopeSplash = false
    
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
                        .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                        .frame(maxWidth: .infinity, alignment: .top)
                        .ignoresSafeArea(.all, edges: .top)
                        .zIndex(999) // Add high z-index to ensure it's visible
                        .onAppear {
                            let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
                            print("🔍 Clear Rectangle Debug:")
                            print("   📊 cameFromHoroscopeSplash: \(cameFromHoroscopeSplash)")
                            print("   📊 Safe area top: \(safeAreaTop)")
                            print("   📊 Screen bounds: \(UIScreen.main.bounds)")
                            print("   📊 Window safe area: \(UIApplication.shared.windows.first?.safeAreaInsets ?? .zero)")
                        }
                    Spacer()
                }
                .zIndex(999) // Also add z-index to the VStack
            }
            
            VStack(spacing: 0) {
                if splashViewDismissed || completedOnboarding {
                    ZodiacHeaderFull(
                        profileImage: "Leo",
                        badgeScale: 1.0,
                        badgeRotation: 0,
                        cosmicGlowOpacity: 0.5,
                        nebulaOpacity: 0.3,
                        starFieldOpacity: 0.4,
                        cosmicParticlesOpacity: 0.6,
                        sparkleOpacity: 0.8,
                        stardustPoints: 0,
                        badgeSize: nil,
                        horoscopeDate: "Monday\nJanuary 5, 2025",
                        onSettingsTap: {
                            showingSettings = true
                        }
                    )
//                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.5), value: splashViewDismissed)
                    .padding(.top, cameFromHoroscopeSplash ? (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) : 0) // Align with purple rectangle bottom
                    .onAppear {
                        print("🎯 MainZodiacView: Header is being shown")
                        print("   📊 splashViewDismissed: \(splashViewDismissed)")
                        print("   📊 completedOnboarding: \(completedOnboarding)")
                        print("   🎭 Context: \(splashViewDismissed ? "After splash dismissed" : "Completed onboarding")")
                    }
                }
                
                // Main content area
                HoroscopeSplashView(
                    onDismiss: {
                        print("🎯 MainZodiacView: HoroscopeSplashView dismissed")
                        print("   📊 Before - splashViewDismissed: \(splashViewDismissed)")
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashViewDismissed = true
                            cameFromHoroscopeSplash = true
                        }
                        print("   📊 After - splashViewDismissed: \(splashViewDismissed)")
                        print("   🎭 This should trigger header to appear")
                    },
                    onConsentDismissed: {
                        print("=== CONSENT DISMISSED CALLBACK EXECUTED ===")
                        print("Consent alert dismissed in MainZodiacView")
                    },
                    completedOnboarding: completedOnboarding
                )
                .environmentObject(authManager)
                .onAppear {
                    print("MainZodiacView: Setting up onConsentDismissed callback")
                    // Initialize OnboardingDataAccess with the correct ModelContext
                    if onboardingDataAccess == nil {
                        onboardingDataAccess = OnboardingDataAccess(modelContext: modelContext)
                    } else {
                        onboardingDataAccess?.updateModelContext(modelContext)
                    }
                    // Load user data
                    onboardingDataAccess?.loadUserData()
                }
            }
            .onChange(of: splashViewDismissed) { _, newValue in
                if !newValue && !completedOnboarding {
                    print("🚫 MainZodiacView: Header is NOT being shown")
                    print("   📊 splashViewDismissed: \(newValue)")
                    print("   📊 completedOnboarding: \(completedOnboarding)")
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserDataModel.self, configurations: config)
    
    // Create mock user data
    let mockUserData = UserDataModel.createMockUserData()
    
    container.mainContext.insert(mockUserData)
    
    // Set consent to false for testing
    UserDefaults.standard.set(true, forKey: "hasAcceptedConsentPolicies")
    
    // Create a preview-specific view that ensures data is loaded
    return MainZodiacView(completedOnboarding: false)
        .modelContainer(container)
        .environmentObject(AuthenticationManager())
}
