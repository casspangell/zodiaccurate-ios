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
    @State private var showLoadingOverlay = true
    @State private var showHoroscopeContent = false
    @State private var tapHintOpacity: Double = 0.0
    @State private var showConsentAlert = true
    @State private var consentChecked = false
    @State private var showConsentError = false
    @State private var consentJiggle = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VerticleAuroraBackgroundView()
                // Consent Alert Overlay (blocks all interaction until accepted)
                if showConsentAlert {
//                    VisualEffectBlur(blurStyle: .systemMaterialDark)
//                        .ignoresSafeArea()
//                        .opacity(0.98)
//                        .zIndex(100)
//                        .transition(.opacity)
//                        .animation(.easeInOut(duration: 0.4), value: showConsentAlert)
//                        .allowsHitTesting(true)
//                        .overlay(
//                            VStack(spacing: 0) {
//                                Spacer()
//                                VStack(spacing: 18) {
//                                    // Title
//                                    Text("Consent Policies")
//                                        .font(.dmSansSemibold(size: 24))
//                                        .foregroundColor(.white)
//                                        .multilineTextAlignment(.center)
//
//                                    // Subtitle
//                                    Text("Your information is secure and encrypted. Please:")
//                                        .font(.dmSansMedium(size: 16))
//                                        .foregroundColor(.white.opacity(0.8))
//                                        .multilineTextAlignment(.center)
//
//                                    // Consent Row
//                                    HStack(alignment: .center, spacing: 10) {
//                                        Button(action: {
//                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
//                                                consentChecked.toggle()
//                                                showConsentError = false
//                                            }
//                                        }) {
//                                            Image(systemName: consentChecked ? "checkmark.square.fill" : "square")
//                                                .resizable()
//                                                .frame(width: 24, height: 24)
//                                                .foregroundColor(consentChecked ? Color.accentGreen : (showConsentError ? Color.red : Color.white.opacity(0.7)))
//                                                .scaleEffect(consentJiggle ? 1.15 : 1.0)
//                                                .animation(.default, value: consentJiggle)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                        .accessibilityLabel("Agree to GDPR Privacy Policy")
//
//                                        // Wrap the text in a VStack for word wrapping
//                                        VStack(alignment: .leading, spacing: 0) {
//                                            HStack(alignment: .firstTextBaseline, spacing: 0) {
//                                                Text("I agree to the Zodiaccurate ")
//                                                    .foregroundColor(.white.opacity(0.85))
//                                                    .font(.dmSansMedium(size: 15))
//                                                    .fixedSize(horizontal: false, vertical: true)
//                                                Text("GDPR Privacy Policy")
//                                                    .foregroundColor(Color.accentGreen)
//                                                    .underline()
//                                                    .font(.dmSansMedium(size: 15))
//                                                    .fixedSize(horizontal: false, vertical: true)
//                                                    .onTapGesture {
//                                                        if let url = URL(string: "https://zodiaccurate.com/privacy-policy") {
//                                                            UIApplication.shared.open(url)
//                                                        }
//                                                    }
//                                            }
//                                            .multilineTextAlignment(.leading)
//                                        }
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                    }
//                                    .padding(.top, 8)
//                                    .padding(.bottom, 2)
//                                    .offset(x: consentJiggle ? -12 : 0)
//                                    .animation(consentJiggle ? .default : .none, value: consentJiggle)
//
//                                    if showConsentError {
//                                        Text("You must agree to the GDPR Privacy Policy to continue.")
//                                            .foregroundColor(.red)
//                                            .font(.dmSansMedium(size: 14))
//                                            .frame(maxWidth: .infinity)
//                                            .multilineTextAlignment(.center)
//                                            .padding(.top, 2)
//                                            .transition(.opacity)
//                                    }
//
//                                    // Ok Button
//                                    PrimaryGradientButton(title: "Ok") {
//                                        if consentChecked {
//                                            withAnimation(.easeInOut(duration: 0.3)) {
//                                                showConsentAlert = false
//                                            }
//                                        } else {
//                                            // Jiggle and highlight error
//                                            showConsentError = true
//                                            consentJiggle = true
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
//                                                consentJiggle = false
//                                            }
//                                        }
//                                    }
//                                    .padding(.top, 10)
//                                }
//                                .padding(.horizontal, 28)
//                                .padding(.vertical, 32)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
//                                        .fill(Color.indigo.opacity(0.92))
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                                                .stroke(Color.accentGold.opacity(0.3), lineWidth: 1)
//                                        )
//                                )
//                                .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
//                                .padding(.horizontal, 40)
//                                .offset(x: consentJiggle ? -12 : 0)
//                                .animation(consentJiggle ? .default : .none, value: consentJiggle)
//                                Spacer()
//                            }
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .zIndex(101)
//                        )
                } //concent alert

                VStack(spacing: 0) {
                    // Top padding for safe area
                    Spacer()
                        .frame(height: 60)
                    
                    // Horoscope Content
                    VStack(spacing: 20) {
//                        if onboardingDataAccess?.isGeneratingHoroscope == true {
//                            // Content is hidden when loading - overlay shows instead
//                            Color.clear
//                                .frame(maxHeight: geo.size.height * 0.7)
//                                .frame(maxWidth: .infinity)
//                        } else if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
//                            VStack(spacing: 0) {
//                                // Show welcome message for newly generated horoscope
//                                if showWelcomeMessage {
//                                    VStack(spacing: 12) {
//                                        Text("Welcome to Zodiaccurate, \(onboardingDataAccess?.firstName ?? "")!")
//                                            .font(.title2)
//                                            .fontWeight(.bold)
//                                            .foregroundColor(.white)
//                                            .multilineTextAlignment(.center)
//                                        
//                                        Text("We've just barely tasted the waters...")
//                                            .font(.subheadline)
//                                            .foregroundColor(.white.opacity(0.8))
//                                            .multilineTextAlignment(.center)
//                                    }
//                                    .padding(.bottom, 16)
//                                }
//                                
//                                // Horoscope text with full screen utilization
//                                ScrollView {
//                                    Text(horoscope)
//                                        .font(.body)
//                                        .foregroundColor(.white.opacity(0.95))
//                                        .lineSpacing(8)
//                                        .multilineTextAlignment(.center)
//                                        .padding(.horizontal, 8)
//                                        .padding(.bottom, 20)
//                                }
//                                .frame(maxHeight: geo.size.height * 0.65)
//                            }
//                            .padding(.vertical, 20)
//                            .background(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color.black.opacity(0.4))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 16)
//                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
//                                    )
//                            )
//                            .opacity(showHoroscopeContent ? 1 : 0)
//                            .animation(.easeInOut(duration: 2.2), value: showHoroscopeContent)
//                            .frame(maxWidth: .infinity)
//                        }
                    }
//                    .padding(.horizontal, 24)
//                    .frame(maxWidth: .infinity)
                    
//                    Spacer()
                    
                    // Tap anywhere to continue label (replaces button)
                    if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                        HStack(spacing: 8) {
                            Circle()
                                .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                                .frame(width: 18, height: 18)
                                .scaleEffect(tapHintOpacity > 0.5 ? 1.1 : 1.0)
                            Text("Tap anywhere to continue")
                                .font(.dmSansMedium13_4)
                                .foregroundColor(Color.gray.opacity(0.7))
                        }
//                        .padding(.bottom, 50) kilroy
                        .opacity(tapHintOpacity)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: tapHintOpacity
                        )
                    }
                }
                
                // Loading spinner overlay - always present, fades out smoothly
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
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .opacity(showLoadingOverlay ? 1 : 0)
                .animation(.easeInOut(duration: 2.2), value: showLoadingOverlay)
                .allowsHitTesting(showLoadingOverlay)
            }
            // Make the whole screen tappable to continue (except when loading)
            .contentShape(Rectangle())
            .onTapGesture {
                if let horoscope = onboardingDataAccess?.coreDataWelcomeHoroscope, !horoscope.isEmpty, showHoroscopeContent {
                    navigateToMain()
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
                // Start tap hint animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        tapHintOpacity = 1.0
                    }
                }
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
                    // Show tap hint after content fade-in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            tapHintOpacity = 1.0
                        }
                    }
                }
            } else {
                startMysticalSentenceTimer()
                showLoadingOverlay = true
                showHoroscopeContent = false
                tapHintOpacity = 0.0
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserDataModel.self, configurations: config)
    
    // Create mock user data
    let mockUserData = UserDataModel(
        firstName: "Erika",
        birthDate: "July 25, 1970",
        birthTime: "10:31 PM",
        zodiacSign: "Leo",
        responses: ["What's your name?|name|Erika", "When were you born?|birthDate|July 25, 1970"],
        welcomeHoroscope: """
        Dearest Erika, born under the fiery heart of Leo with the night's twilight as your celestial cloak, the cosmos has whispered your name. Born at 10:31 PM on July 25, 2025, your birth was graced with the shimmering secrets of the evening, and it's those same secrets that have come to symbolize your deep-seated passion and regal spirit, typical of a true Leo.
        
        Your intuitive greeting, filled with multiple hellos, speaks to your innate ability to connect energetically with those around you, a vibrant 'hi' that echoes through the universe. Remember, dear Erika, your dreams may be silent now, but in that silence, there is a boundless potential, a universe of possibilities waiting for you. Embrace this journey, for it's in the quiet moments that your true strength emerges.
        
        The stars have aligned to reveal that your path is one of leadership and creativity. Your natural charisma draws others to you like moths to a flame, and your generous spirit makes you a beacon of warmth in the lives of those around you. Trust in your intuition, for it is sharper than you know.
        
        As you navigate through this cosmic journey, remember that every challenge is an opportunity for growth. Your Leo heart beats with the rhythm of the universe, and your courage will guide you through any storm. The future holds great promise for you, dear Erika.
        """
    )
    
    container.mainContext.insert(mockUserData)
    
    return OnboardingHoroscopeView()
        .environmentObject(AuthenticationManager())
        .modelContainer(container)
} 
