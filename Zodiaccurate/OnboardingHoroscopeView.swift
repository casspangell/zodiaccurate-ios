import SwiftUI
import SwiftData

struct OnboardingHoroscopeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var onboardingDataAccess: OnboardingDataAccess?
    @State private var showWelcomeMessage = true
    @State private var refreshTrigger = false
    // Mystical loading sentences
    private let mysticalLoadingSentences = [
        "Consulting the stars...",
        "Aligning your cosmic energies...",
        "Reading your astral chart...",
        "Whispering to the cosmos...",
        "Gathering celestial insights...",
        "Translating zodiac wisdom...",
        "Peering into the future...",
        "Summoning your horoscope..."
    ]
    @State private var currentMysticalSentenceIndex = 0
    @State private var mysticalSentenceTimer: Timer? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                MainCelestialBackground()
                
                VStack(spacing: 0) {
                    // Top padding for safe area
                    Spacer()
                        .frame(height: 60)
                    
                    // Horoscope Content
                    VStack(spacing: 0) {
                        if onboardingDataAccess?.isGeneratingHoroscope == true {
                            // Content is hidden when loading - overlay shows instead
                            Color.clear
                                .frame(maxHeight: geo.size.height * 0.7)
                                .frame(maxWidth: .infinity)
                        } else if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                            VStack(spacing: 20) {
                                // Show welcome message for newly generated horoscope
                                if showWelcomeMessage {
                                    VStack(spacing: 12) {
                                        Text("Welcome to Zodiaccurate!")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("We've just barely tasted the waters...")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.bottom, 16)
                                }
                                
                                // Horoscope text with full screen utilization
                                ScrollView {
                                    Text(horoscope)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineSpacing(8)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 20)
                                }
                                .frame(maxHeight: geo.size.height * 0.65)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Continue Button
                    if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                        Button(action: {
                            navigateToMain()
                        }) {
                            HStack {
                                Text("Continue to App")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.purple.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                }
                
                // Loading spinner overlay - appears on top of all content
                if onboardingDataAccess?.coreDataWelcomeHoroscope?.isEmpty ?? true {
                    ZStack {
                        // Centered spinner
                        VStack {
                            Spacer()
                            ZodiacLoadingSpinner(size: .large)
                                .scaleEffect(1.2)
                            Spacer()
                        }
                        // Bottom-anchored mystical sentence
                        VStack {
                            Spacer()
                            Text(mysticalLoadingSentences[currentMysticalSentenceIndex])
                                .id(currentMysticalSentenceIndex)
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 48)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 2.2), value: currentMysticalSentenceIndex)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                    .allowsHitTesting(false)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: refreshTrigger) { _, _ in
            // This will trigger a view refresh when refreshTrigger changes
        }
        .onChange(of: onboardingDataAccess?.dataRefreshTrigger) { _, _ in
            // This will trigger a view refresh when data is refreshed
        }
        .onAppear {
            print("OnboardingHoroscopeView appeared, setting up data access...")
            // Start mystical sentence timer if loading
            if onboardingDataAccess?.coreDataWelcomeHoroscope?.isEmpty ?? true {
                startMysticalSentenceTimer()
            }
            // Initialize OnboardingDataAccess with the correct ModelContext
            if onboardingDataAccess == nil {
                onboardingDataAccess = OnboardingDataAccess(modelContext: modelContext)
            } else {
                onboardingDataAccess?.updateModelContext(modelContext)
            }
            // Load user data and trigger refresh
            onboardingDataAccess?.loadUserData()
            // Check if horoscope is already generated
            if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                print("Horoscope already exists, showing welcome message")
                showWelcomeMessage = true
                // Hide welcome message after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    showWelcomeMessage = false
                }
                // Stop mystical sentence timer if running
                stopMysticalSentenceTimer()
            }
        }
        .onChange(of: onboardingDataAccess?.coreDataWelcomeHoroscope) { _, newValue in
            // Start or stop mystical sentence timer based on loading state
            if let horoscope = newValue, !horoscope.isEmpty {
                stopMysticalSentenceTimer()
            } else {
                startMysticalSentenceTimer()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("horoscopeGenerated"))) { _ in
            // Only refresh if the horoscope is not already present
            if onboardingDataAccess?.coreDataWelcomeHoroscope?.isEmpty ?? true {
                print("🎉 OnboardingHoroscopeView: Horoscope generated notification received, reloading data...")
                onboardingDataAccess?.refreshAndLoadUserData()
                showWelcomeMessage = true

                // Check if horoscope is now available with multiple retries
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                        print("✅ OnboardingHoroscopeView: Horoscope loaded successfully, length: \(horoscope.count) characters")
                        refreshTrigger.toggle() // Trigger view refresh
                    } else {
                        print("⚠️ OnboardingHoroscopeView: Horoscope not available after first reload, trying again...")
                        // Try again after a longer delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onboardingDataAccess?.loadUserData()
                            if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                                print("✅ OnboardingHoroscopeView: Horoscope loaded successfully on second attempt, length: \(horoscope.count) characters")
                                refreshTrigger.toggle() // Trigger view refresh
                            } else {
                                print("⚠️ OnboardingHoroscopeView: Horoscope still not available after second reload")
                            }
                        }
                    }
                }

                // Hide welcome message after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    showWelcomeMessage = false
                }
            } else {
                print("🎉 OnboardingHoroscopeView: Horoscope already present, skipping refresh.")
            }
        }
    }
    
    private func navigateToMain() {
        print("Navigating to MainView...")
        authManager.completeSignUp()
    }
    
    private func forceRefresh() {
        print("🔄 OnboardingHoroscopeView: Forcing refresh...")
        onboardingDataAccess?.loadUserData()
        refreshTrigger.toggle()
    }
    
    // MARK: - Mystical Sentence Timer
    private func startMysticalSentenceTimer() {
        stopMysticalSentenceTimer()
        mysticalSentenceTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation {
                currentMysticalSentenceIndex = (currentMysticalSentenceIndex + 1) % mysticalLoadingSentences.count
            }
        }
    }
    private func stopMysticalSentenceTimer() {
        mysticalSentenceTimer?.invalidate()
        mysticalSentenceTimer = nil
        currentMysticalSentenceIndex = 0
    }
}

#Preview {
    OnboardingHoroscopeView()
        .environmentObject(AuthenticationManager())
} 
