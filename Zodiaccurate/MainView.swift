import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        self._onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                MainCelestialBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)

                // Header containing profile badge and welcome text
                HStack(alignment: .top, spacing: 10) {
                    // Left column - Profile badge
                    ZodiacProfileBadge()
                    
                    // Right column - Date text
                    VStack(alignment: .leading, spacing: 2) {
                        Text(getDayOfWeek())
                            .foregroundColor(.white.opacity(0.7))
                            .font(.headline)
                        Text(getFormattedDate())
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding(.top, 0)
                .padding(.horizontal)
                .zIndex(1)

                ScrollView {
                    VStack(spacing: 20) {
                        // User Profile Card
                        VStack(spacing: 16) {
                            Text("Your Cosmic Profile")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                ProfileRow(title: "Name", value: OnboardingDataAccess.firstName)
                                ProfileRow(title: "Birth Date", value: OnboardingDataAccess.birthDate)
                                ProfileRow(title: "Birth Time", value: OnboardingDataAccess.birthTime.isEmpty ? "Unknown" : OnboardingDataAccess.birthTime)
                                ProfileRow(title: "Zodiac Sign", value: OnboardingDataAccess.zodiacSign)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Responses Section
                        if !OnboardingDataAccess.responses.isEmpty {
                            VStack(spacing: 16) {
                                Text("Your Responses")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ForEach(OnboardingDataAccess.responses, id: \.0) { response in
                                        ResponseRow(key: response.0, value: response.1)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // Sign Out Button
                        Button(action: {
                            // Clear onboarding data on sign out
                            OnboardingDataAccess.clearOnboardingData()
                            try? authManager.signOut()
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.3))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
                .padding(.top, 244) // Header height: 40 (top) + 180 (badge) + 24 (badge top padding) = 244
            }
            .navigationBarHidden(true)
            .onAppear {
                onboardingDataAccess.updateModelContext(modelContext)
            }
        }
    }
    
    // Helper functions for date formatting
    private func getDayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

// Profile Row Component
struct ProfileRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
    }
}

// Response Row Component
struct ResponseRow: View {
    let key: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key.capitalized)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Background View (same as onboarding)
struct BackgroundView: View {
    var body: some View {
        ZStack {

            // Vignette overlay
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.6),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .blendMode(.multiply)
            .allowsHitTesting(false)

            // Celestial bodies
            GeometryReader { geo in
                CelestialSystemBackground()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .position(x: geo.size.width / 5, y: geo.size.height / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)

            // Orange overlay
            Color.backgroundPrimary.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainView()
        .environmentObject(AuthenticationManager())
} 
