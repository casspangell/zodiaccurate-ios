import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    @State private var showingSettings = false
    @State private var isMenuOpen = false
    @State private var showWidgetMenu = false
    @State private var showDailyHoroscope = false
    @State private var dailyHoroscope: String?
    @StateObject private var onboardingAI = OnboardingAI()
    @State private var showWelcomeMessage = false
    
    // Polling mechanism for horoscope generation status
    @State private var horoscopePollingTimer: Timer?
    @State private var lastHoroscopeStatus: (isGenerating: Bool, didGenerate: Bool) = (false, false)
    @State private var pollingStartTime: Date?
    private let maxPollingDuration: TimeInterval = 300 // 5 minutes max
    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        self._onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                NavigationView {
                    ZStack(alignment: .topLeading) {
                        MainCelestialBackground()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea(.all, edges: .all)

                        // Main header HStack: badge and date
                        HStack(alignment: .top, spacing: 0) {
                            // Profile badge on the left
                            ZodiacProfileBadge()
                                .frame(width: 140, height: 140)

                            Spacer()

                            // Date text at the far right
                            VStack(alignment: .leading, spacing: 0) {
                                Text(getDayOfWeek())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                                Text(getFormattedDate())
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.top, 80)
                            .padding(.trailing, 8)
                        }
                        .padding(.top, 0)
                        .padding(.horizontal)
                        .zIndex(1)

                        VStack(spacing: 20) {
                            // User Profile Card
                            VStack(spacing: 16) {
                                Text("Your Cosmic Profile")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    ProfileRow(title: "Name", value: onboardingDataAccess.coreDataFirstName)
                                    ProfileRow(title: "Birth Date", value: onboardingDataAccess.coreDataBirthDate)
                                    ProfileRow(title: "Birth Time", value: onboardingDataAccess.coreDataBirthTime.isEmpty ? "Unknown" : onboardingDataAccess.coreDataBirthTime)
                                    ProfileRow(title: "Zodiac Sign", value: onboardingDataAccess.coreDataZodiacSign)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                
                                // Welcome Horoscope Section
                                GeometryReader { geo in
                                    VStack {
                                        Spacer(minLength: 0)
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("✨ Your Welcome Horoscope ✨")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                            // Show loading state if horoscope is being generated
                                            if onboardingDataAccess.isGeneratingHoroscope {
                                                VStack(spacing: 16) {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                        .scaleEffect(1.2)
                                                    
                                                    Text("Generating your cosmic insights...")
                                                        .font(.body)
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .multilineTextAlignment(.center)
                                                }
                                                .frame(maxHeight: geo.size.height * 0.6)
                                                .frame(maxWidth: .infinity)
                                            } else if let horoscope = onboardingDataAccess.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                                                // Show welcome message for newly generated horoscope
                                                if showWelcomeMessage {
                                                    VStack(spacing: 12) {
                                                        Text("🌟 Welcome to Your Cosmic Journey! 🌟")
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
                                        .padding(.bottom, 32)
                                        Spacer(minLength: 0)
                                    }
                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Daily Horoscope Card
                            // VStack(spacing: 16) {
                            //     Text("Today's Cosmic Guidance")
                            //         .font(.title2)
                            //         .fontWeight(.semibold)
                            //         .foregroundColor(.white)
                            //     
                            //     Button(action: {
                            //         showDailyHoroscope = true
                            //     }) {
                            //         VStack(spacing: 12) {
                            //             if let horoscope = dailyHoroscope {
                            //                 Text(horoscope)
                            //                     .font(.body)
                            //                     .foregroundColor(.white)
                            //                     .lineSpacing(4)
                            //                     .multilineTextAlignment(.leading)
                            //                     .frame(maxWidth: .infinity, alignment: .leading)
                            //             } else {
                            //                 HStack {
                            //                     Image(systemName: "sparkles")
                            //                     Text("Generate Your Daily Horoscope")
                            //                     Image(systemName: "arrow.right")
                            //                 }
                            //                 .font(.headline)
                            //                 .foregroundColor(.white)
                            //             }
                            //         }
                            //         .padding()
                            //         .background(Color.white.opacity(0.1))
                            //         .cornerRadius(12)
                            //     }
                            //     .buttonStyle(PlainButtonStyle())
                            // }
                            // .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding(.top, 244) // Header height: 40 (top) + 180 (badge) + 24 (badge top padding) = 244
                    }
                    .navigationBarHidden(true)
                    .sheet(isPresented: $showingSettings) {
                        SettingsView()
                    }
                    .onAppear {
                        print("🔄 MainView appeared, setting up data access...")
                        onboardingDataAccess.updateModelContext(modelContext)
                        onboardingDataAccess.loadUserData()
                        startHoroscopePolling()
                        
                        // Also check for horoscope every few seconds as a fallback
                        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                            if let horoscope = onboardingDataAccess.coreDataWelcomeHoroscope, !horoscope.isEmpty {
                                print("🔄 Found horoscope in Core Data, reloading data...")
                                onboardingDataAccess.loadUserData()
                            }
                        }
                    }
                    .onDisappear {
                        stopHoroscopePolling()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        // Restart polling when app comes to foreground
                        if onboardingDataAccess.isGeneratingHoroscope {
                            print("🔄 App entered foreground, restarting horoscope polling...")
                            startHoroscopePolling()
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                        // Stop polling when app goes to background to save resources
                        print("🔄 App entered background, stopping horoscope polling...")
                        stopHoroscopePolling()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .horoscopeGenerated)) { _ in
                        // Reload data when horoscope is generated
                        print("🔄 Horoscope generated notification received, reloading data...")
                        onboardingDataAccess.loadUserData()
                        showWelcomeMessage = true
                        
                        // Hide welcome message after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            showWelcomeMessage = false
                        }
                    }
                }
                // Overlay: Notification and Settings buttons in upper right
                ZStack {
                    VStack(spacing: 8) {
                        CircleIconButton(systemName: "bell", accessibilityLabel: "Notifications") {
                            //alert action
                        }
                        CircleIconButton(systemName: "gearshape", accessibilityLabel: "Settings") {
                            showWidgetMenu = true
                        }
                    }
                    .frame(width: 80, height: 120)
                    .position(x: UIScreen.main.bounds.width - 40, y: 60)
                    .zIndex(100)
                }
                // Widget menu overlay
                if showWidgetMenu {
                    SettingsWidgetMenu(isPresented: $showWidgetMenu)
                        .environmentObject(authManager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(200)
                }
                
                // Daily Horoscope Sheet
                if showDailyHoroscope {
                    DailyHoroscopeSheet(
                        isPresented: $showDailyHoroscope,
                        horoscope: $dailyHoroscope,
                        onboardingAI: onboardingAI
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(300)
                }
            }
        }
    }
    
    // MARK: - Polling Methods
    
    private func startHoroscopePolling() {
        print("🔄 Starting horoscope polling...")
        stopHoroscopePolling() // Ensure we don't have multiple timers
        
        // Initialize the last status
        lastHoroscopeStatus = (onboardingDataAccess.isGeneratingHoroscope, onboardingDataAccess.didGenerateHoroscope)
        
        // Record start time for timeout
        pollingStartTime = Date()
        
        // Create timer that fires every second
        horoscopePollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            checkHoroscopeStatus()
        }
        
        // Also check immediately
        checkHoroscopeStatus()
    }
    
    private func stopHoroscopePolling() {
        print("🔄 Stopping horoscope polling...")
        horoscopePollingTimer?.invalidate()
        horoscopePollingTimer = nil
        pollingStartTime = nil
    }
    
    private func checkHoroscopeStatus() {
        let currentStatus = (onboardingDataAccess.isGeneratingHoroscope, onboardingDataAccess.didGenerateHoroscope)
        
        // Check for timeout
        if let startTime = pollingStartTime,
           Date().timeIntervalSince(startTime) > maxPollingDuration {
            print("⚠️ Horoscope polling timeout reached, stopping polling...")
            stopHoroscopePolling()
            return
        }
        
        // Check if status has changed
        if currentStatus != lastHoroscopeStatus {
            print("🔄 Horoscope status changed: generating=\(currentStatus.0), didGenerate=\(currentStatus.1)")
            
            // Update the last status
            lastHoroscopeStatus = currentStatus
            
            // If horoscope generation completed, reload user data to get the new horoscope
            if !currentStatus.0 && currentStatus.1 {
                print("✅ Horoscope generation completed, reloading user data...")
                
                // Reload user data on main thread
                DispatchQueue.main.async {
                    self.onboardingDataAccess.loadUserData()
                    // Show welcome message for newly generated horoscope
                    self.showWelcomeMessage = true
                    
                    // Hide welcome message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.showWelcomeMessage = false
                    }
                }
                
                // Stop polling since we're done
                stopHoroscopePolling()
            }
            
            // If horoscope generation started, ensure we're polling
            if currentStatus.0 && !lastHoroscopeStatus.0 {
                print("🔄 Horoscope generation started, ensuring polling is active...")
                if horoscopePollingTimer == nil {
                    startHoroscopePolling()
                }
            }
        }
        
        // Safety check: if we're generating but no timer is running, restart polling
        if currentStatus.0 && horoscopePollingTimer == nil {
            print("⚠️ Horoscope is generating but no timer running, restarting polling...")
            startHoroscopePolling()
        }
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
