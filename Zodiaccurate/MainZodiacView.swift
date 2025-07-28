import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var onboardingDataAccess: OnboardingDataAccess?
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            HoroscopeLoadingView()
                .environmentObject(authManager)
                .onAppear {
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
    }
}

#Preview {
    MainZodiacView()
        .environmentObject(AuthenticationManager())
}
