import SwiftUI
import SwiftData

struct MainZodiacView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
    @State private var showingSettings = false
    @State private var isMenuOpen = false
    @State private var showWidgetMenu = false
    @State private var showDailyHoroscope = false
    @State private var dailyHoroscope: String?
    @StateObject private var onboardingAI = Onboarding()

    
    init() {
        // Initialize with a temporary context - will be updated in onAppear
        self._onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
//                NavigationView {
//                    ZStack(alignment: .topLeading) {
////                        MainCelestialBackground()
////                            .frame(maxWidth: .infinity, maxHeight: .infinity)
////                            .ignoresSafeArea(.all, edges: .all)
//
//                        // Main header HStack: badge and date
//                        HStack(alignment: .top, spacing: 0) {
//                            // Profile badge on the left
//                            ZodiacProfileBadge()
//                                .frame(width: 140, height: 140)
//
//                            Spacer()
//
//                            // Date text at the far right
//                            VStack(alignment: .leading, spacing: 0) {
//                                Text(getDayOfWeek())
//                                    .font(.system(size: 36, weight: .bold))
//                                    .foregroundColor(.white.opacity(0.9))
//                                Text(getFormattedDate())
//                                    .font(.system(size: 28, weight: .semibold))
//                                    .foregroundColor(.white.opacity(0.9))
//                            }
//                            .padding(.top, 80)
//                            .padding(.trailing, 8)
//                        }
//                        .padding(.top, 0)
//                        .padding(.horizontal)
//                        .zIndex(1)
//
//                        VStack(spacing: 20) {
//                            // User Profile Card
//                            VStack(spacing: 16) {
//                                Text("Your Cosmic Profile")
//                                    .font(.title2)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.white)
//                                
//                                VStack(spacing: 12) {
//                                    ProfileRow(title: "Name", value: onboardingDataAccess.coreDataFirstName)
//                                    ProfileRow(title: "Birth Date", value: onboardingDataAccess.coreDataBirthDate)
//                                    ProfileRow(title: "Birth Time", value: onboardingDataAccess.coreDataBirthTime.isEmpty ? "Unknown" : onboardingDataAccess.coreDataBirthTime)
//                                    ProfileRow(title: "Zodiac Sign", value: onboardingDataAccess.coreDataZodiacSign)
//                                }
//                                .padding()
//                                .background(Color.white.opacity(0.1))
//                                .cornerRadius(12)
//                                
//                                // Welcome Horoscope Section
//                                GeometryReader { geo in
//                                    VStack {
//                                        Spacer(minLength: 0)
//                                        VStack(alignment: .leading, spacing: 12) {
//                                            if let userData = onboardingDataAccess.userData {
//                                                Text("Welcome back, \(userData.firstName)")
//                                                    .font(.headline)
//                                                    .fontWeight(.semibold)
//                                                    .foregroundColor(.white)
//                                                
//                                                Text("Your cosmic journey continues")
//                                                    .font(.subheadline)
//                                                    .foregroundColor(.white.opacity(0.8))
//                                            } else {
//                                                Text("Welcome to Zodiaccurate")
//                                                    .font(.headline)
//                                                    .fontWeight(.semibold)
//                                                    .foregroundColor(.white)
//                                                
//                                                Text("Your personalized cosmic experience")
//                                                    .font(.subheadline)
//                                                    .foregroundColor(.white.opacity(0.8))
//                                            }
//                                        }
//                                        .padding()
//                                        .background(Color.white.opacity(0.1))
//                                        .cornerRadius(12)
//                                        .padding(.bottom, 32)
//                                        Spacer(minLength: 0)
//                                    }
//                                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
//                                }
//                            }
//                            .padding(.horizontal)
                            
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
                            
//                            Spacer()
//                        }
//                        .padding(.top, 244) // Header height: 40 (top) + 180 (badge) + 24 (badge top padding) = 244
//                    }
//                    .navigationBarHidden(true)
//                    .sheet(isPresented: $showingSettings) {
//                        SettingsView()
//                    }
//                    .onAppear {
//                        print("🔄 MainView appeared, setting up data access...")
//                        onboardingDataAccess.updateModelContext(modelContext)
//                        onboardingDataAccess.loadUserData()
//                    }
//                }
//                // Overlay: Notification and Settings buttons in upper right
//                ZStack {
//                    VStack(spacing: 8) {
//                        CircleIconButton(systemName: "bell", accessibilityLabel: "Notifications") {
//                            //alert action
//                        }
//                        CircleIconButton(systemName: "gearshape", accessibilityLabel: "Settings") {
//                            showWidgetMenu = true
//                        }
//                    }
//                    .frame(width: 80, height: 120)
//                    .position(x: UIScreen.main.bounds.width - 40, y: 60)
//                    .zIndex(100)
//                }
//                // Widget menu overlay
//                if showWidgetMenu {
//                    SettingsWidgetMenu(isPresented: $showWidgetMenu)
//                        .environmentObject(authManager)
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
//                        .zIndex(200)
//                }
//                
//                // Daily Horoscope Sheet
//                if showDailyHoroscope {
//                    DailyHoroscopeSheet(
//                        isPresented: $showDailyHoroscope,
//                        horoscope: $dailyHoroscope,
//                        onboardingAI: onboardingAI
//                    )
//                    .transition(.move(edge: .bottom).combined(with: .opacity))
//                    .zIndex(300)
//                }
                // Localized stardust animation is now handled by the profile badge components
            }
            
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


#Preview {
    MainZodiacView()
        .environmentObject(AuthenticationManager())
} 
