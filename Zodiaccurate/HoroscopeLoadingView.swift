import SwiftUI
import SwiftData

struct HoroscopeLoadingView: View {
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
    @State private var showLoadingOverlay = true
    @State private var showHoroscopeContent = false

    @State private var showConsentAlert = true
    @State private var shouldReverseTagline = false
    @State private var showTapAnywhere = true
    @State private var showLoadingSpinner = true
    
    var body: some View {
        ZStack {
            VerticleAuroraBackgroundView()
            // Consent Alert Overlay (blocks all interaction until accepted)
            if showConsentAlert {
                VisualEffectBlur(blurStyle: .systemMaterialDark)
                    .ignoresSafeArea()
                    .opacity(0.98)
                    .zIndex(100)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: showConsentAlert)
                    .allowsHitTesting(true)
                    .overlay(
                        ConsentAlertView(showConsentAlert: $showConsentAlert)
                    )
            }
            
            // Show tap to continue label only after consent is dismissed
            if !showConsentAlert {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Tagline at 30% from top
                        TaglineView(onReverseAnimation: {
                            // Navigate to main after tagline animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                navigateToMain()
                            }
                        }, shouldReverse: $shouldReverseTagline)
                        .animation(.easeInOut(duration: 0.5), value: showConsentAlert)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.3)
                        
                        Spacer()
                        
                        // ZodiacLoadingSpinner 50px above tap anywhere
                        if showLoadingSpinner {
                            ZodiacLoadingSpinner(size: .large)
                                .padding(.bottom, 80)
                                .transition(.opacity)
                        }
                        
                        // Tap anywhere at the bottom
                        if showTapAnywhere {
                            tapToContinueLabel
                                .transition(.opacity)
                        }
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: showConsentAlert)
            }
        }
        // Make the whole screen tappable to continue (except when loading)
        .contentShape(Rectangle())
        .onTapGesture {
//            if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty, showHoroscopeContent {
                // Dismiss tap anywhere label
                withAnimation(.easeOut(duration: 0.3)) {
                    showTapAnywhere = false
                }
            
                shouldReverseTagline = true
            
                withAnimation(.easeOut(duration: 0.3).delay(0.9)) {
                    showLoadingSpinner = false
                }
//            }
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
                // Fade out loading overlay and fade in horoscope content
                withAnimation(.easeInOut(duration: 2.2)) {
                    showLoadingOverlay = false
                }
                // Fade in horoscope content after a slight delay for mystical effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 2.2)) {
                        showHoroscopeContent = true
                    }

                }
            } else {
                startMysticalSentenceTimer()
                showLoadingOverlay = true
                showHoroscopeContent = false
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
@ViewBuilder
private var tapToContinueLabel: some View {
    HStack {
        Spacer()
        TapAnywhere()
            .frame(maxWidth: .infinity)
        Spacer()
    }
    .padding(.bottom, 50)
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserDataModel.self, configurations: config)
    
    // Create mock user data
    let mockUserData = UserDataModel.createMockUserData()
    
    container.mainContext.insert(mockUserData)
    
    return HoroscopeLoadingView()
        .environmentObject(AuthenticationManager())
        .modelContainer(container)
} 
