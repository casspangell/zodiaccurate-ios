import SwiftUI
import SwiftData

struct OnboardingHoroscopeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    @State private var showWelcomeMessage = true
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        _onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                MainCelestialBackground()
                
                VStack(spacing: 0) {
                    // Header with user info
                    VStack(spacing: 16) {
                        if let userData = onboardingDataAccess.userData {
                            VStack(spacing: 8) {
                                Text("Welcome, \(userData.firstName)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Your Cosmic Journey Begins")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            VStack(spacing: 8) {
                                Text("Welcome to Your Cosmic Journey")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text("Your personalized horoscope awaits")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding(.top, 60)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Horoscope Content
                    VStack(spacing: 20) {
                        if onboardingDataAccess.isGeneratingHoroscope {
                            VStack(spacing: 24) {
                                // Enhanced loading view with cosmic elements
                                ZStack {
                                    // Background cosmic particles
                                    ForEach(0..<12, id: \.self) { index in
                                        Circle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 4, height: 4)
                                            .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
                                            .animation(
                                                Animation.easeInOut(duration: 2.0)
                                                    .repeatForever(autoreverses: true)
                                                    .delay(Double(index) * 0.2),
                                                value: onboardingDataAccess.isGeneratingHoroscope
                                            )
                                    }
                                    
                                    // Main glass shard
                                    GlassShardLoadingView()
                                        .scaleEffect(1.2)
                                }
                                
                                VStack(spacing: 12) {
                                    Text("The cosmos are aligning for you...")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Crafting your personalized cosmic journey")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .frame(maxHeight: geo.size.height * 0.6)
                            .frame(maxWidth: .infinity)
                        } else if let horoscope = onboardingDataAccess.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                            // Show welcome message for newly generated horoscope
                            if showWelcomeMessage {
                                VStack(spacing: 12) {
                                    Text("Welcome to Your Cosmic Journey!")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Your personalized horoscope has been crafted just for you.")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.bottom, 8)
                            }
                            
                            ScrollView {
                                Text(horoscope)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 16)
                            }
                            .frame(maxHeight: geo.size.height * 0.6)
                        } else {
                            // Fallback message if no horoscope is available
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.largeTitle)
                                    .foregroundColor(.purple)
                                
                                Text("Your personalized horoscope will appear here")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxHeight: geo.size.height * 0.6)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Continue Button
                    if let horoscope = onboardingDataAccess.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                        Button(action: {
                            navigateToMain()
                        }) {
                            Text("Continue to App")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("OnboardingHoroscopeView appeared, setting up data access...")
            onboardingDataAccess.updateModelContext(modelContext)
            onboardingDataAccess.loadUserData()
            
            // Check if horoscope is already generated
            if let horoscope = onboardingDataAccess.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                print("Horoscope already exists, showing welcome message")
                showWelcomeMessage = true
                
                // Hide welcome message after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    showWelcomeMessage = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .horoscopeGenerated)) { _ in
            // Reload data when horoscope is generated
            print("Horoscope generated notification received, reloading data...")
            onboardingDataAccess.loadUserData()
            showWelcomeMessage = true
            
            // Hide welcome message after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showWelcomeMessage = false
            }
        }

    }
    
    private func navigateToMain() {
        print("Navigating to MainView...")
        authManager.completeSignUp()
    }
}

#Preview {
    OnboardingHoroscopeView()
        .environmentObject(AuthenticationManager())
} 