import SwiftUI
import SwiftData

struct OnboardingHoroscopeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var onboardingDataAccess: OnboardingDataAccess?
    @State private var showWelcomeMessage = true
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                MainCelestialBackground()
                
                VStack(spacing: 0) {
                    // Header with user info
                    VStack(spacing: 16) {
                        if let userData = onboardingDataAccess?.userData {
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
                        if onboardingDataAccess?.isGeneratingHoroscope == true {
                            // Content is hidden when loading - overlay shows instead
                            Color.clear
                                .frame(maxHeight: geo.size.height * 0.6)
                                .frame(maxWidth: .infinity)
                        } else if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                            VStack(spacing: 16) {
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
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                        } else {
                            // Fallback message if no horoscope is available
                            VStack(spacing: 24) {
                                VStack(spacing: 16) {
                                    Image(systemName: "sparkles")
                                        .font(.largeTitle)
                                        .foregroundColor(.purple)
                                    
                                    Text("Your personalized horoscope will appear here")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .frame(maxHeight: geo.size.height * 0.6)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Continue Button
                    if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
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
                
                // Loading spinner overlay - appears on top of all content
                if onboardingDataAccess?.coreDataWelcomeHoroscope?.isEmpty ?? true {
                    VStack(spacing: 24) {
                        // Celestial loading spinner
                        CelestialLoadingSpinner(size: .large)
                            .scaleEffect(1.2)
                        
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("OnboardingHoroscopeView appeared, setting up data access...")
            
            // Initialize OnboardingDataAccess with the correct ModelContext
            if onboardingDataAccess == nil {
                onboardingDataAccess = OnboardingDataAccess(modelContext: modelContext)
            } else {
                onboardingDataAccess?.updateModelContext(modelContext)
            }
            
            onboardingDataAccess?.loadUserData()
            
            // Check if horoscope is already generated
            if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
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
            onboardingDataAccess?.loadUserData()
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