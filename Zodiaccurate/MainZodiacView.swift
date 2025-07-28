import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var onboardingDataAccess: OnboardingDataAccess?
    @State private var showingSettings = false
    @State private var splashViewDismissed = false
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            
            VStack(spacing: 0) {
                if splashViewDismissed {
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
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.5), value: splashViewDismissed)
                }
                
                // Main content area
                let _ = print("MainZodiacView: Creating HoroscopeSplashView with onConsentDismissed callback")
                HoroscopeSplashView(
                    onDismiss: {
                        print("horoscope splash view dismissed")
                        withAnimation(.easeInOut(duration: 0.5)) {
                            splashViewDismissed = true
                        }
                    },
                    onConsentDismissed: {
                        print("=== CONSENT DISMISSED CALLBACK EXECUTED ===")
                        print("Consent alert dismissed in MainZodiacView")
                    }
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
            if splashViewDismissed {
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
    
    // Create a preview-specific view that ensures data is loaded
    return MainZodiacView()
        .modelContainer(container)
        .environmentObject(AuthenticationManager())
}
