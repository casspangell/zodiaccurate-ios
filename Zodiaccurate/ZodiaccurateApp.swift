//
//  ZodiaccurateApp.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import UIKit

// Minimal app delegate to satisfy GoogleUtilities
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Firebase is now configured in the SwiftUI App init
        return true
    }
}

@main
struct ZodiaccurateApp: App {
    @StateObject private var authManager: AuthenticationManager
    @State private var shouldClearAuthData = false
    
    // Add the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        // Configure Firebase first
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Initialize AuthenticationManager after Firebase is configured
        self._authManager = StateObject(wrappedValue: AuthenticationManager())
        
        // Suppress GoogleUtilities warning for SwiftUI apps
        suppressGoogleUtilitiesWarning()
        
        // Check if this is the first launch after installation
        shouldClearAuthData = checkFirstLaunchAfterInstallation()
        
        // Configure API key for development (remove this after first run)
        // APIConfig.configureForDevelopment(openAIKey: "your-actual-api-key-here")
    }
    
    private func suppressGoogleUtilitiesWarning() {
        // Set environment variable to suppress GoogleUtilities warning
        setenv("GOOGLE_UTILITIES_APP_DELEGATE_SWIZZLER_DISABLED", "1", 1)
    }
    
    private func checkFirstLaunchAfterInstallation() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            // This is the first launch after installation
            print("🚀 First launch after installation detected - clearing all data")
            
            // Clear all UserDefaults data
            clearAllUserDefaults()
            
            // Clear Firebase Auth state
            clearFirebaseAuthState()
            
            // Clear SwiftData
            clearSwiftData()

            // Clear keychain data
            SecureKeychain.clearAllSecrets()
            
            // Mark that the app has been launched before
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            print("✅ All data cleared for fresh installation")
            return true
        }
        return false
    }
    
    private func clearAllUserDefaults() {
        // No longer clearing UserDefaults
    }
    
    private func clearFirebaseAuthState() {
        do {
            try Auth.auth().signOut()
            print("✅ Firebase Auth state cleared")
        } catch {
            print("⚠️ Error clearing Firebase Auth state: \(error)")
        }
    }
    
    private func clearSwiftData() {
        // Clear SwiftData when needed for fresh installation
        do {
            let context = try ModelContext(ModelContainer(for: User.self))
            try context.delete(model: User.self)
            print("✅ SwiftData cleared successfully")
        } catch {
            print("⚠️ Error clearing SwiftData: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .onAppear {
                    if shouldClearAuthData {
                        authManager.clearAllData()
                        shouldClearAuthData = false
                    }
                }
        }
        .modelContainer(for: [User.self, Horoscope.self, Stardust.self, IntakeData.self])
    }
}

// RootView manages the flow: Splash → Onboarding → Login → Main
struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isTrialActive") private var isTrialActive = false
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var showLogin = false
    @State private var shouldStartWithRegistration = false
    @State private var showMain: Bool = false

    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView { _ in
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showSplash = false
                        print("Splashscreen dismissed")
                        // Check if user has completed onboarding and trial status
                        if hasCompletedOnboarding {
                            print("✅ User has completed onboarding")
                        } else {
                            print("🆕 New user detected, showing onboarding flow")
                            showOnboarding = true
                        }
                    }
                }
                .transition(.opacity)
            }

            if showOnboarding {
//                ZStack {
                    ConversationalOnboardingView(
                        onComplete: {
                            // Onboarding completion is now handled via notification from consent
                            print("🔄 ConversationalOnboardingView completed")
                            showMain = true
                        },
                        triggerBadgeAnimation: { newAssetName in
                            // Post notification to trigger badge animation
                            NotificationCenter.default.post(
                                name: .badgeAnimationTriggered,
                                object: nil,
                                userInfo: ["newAssetName": newAssetName]
                            )
                        }
                    )
                }
//                .ignoresSafeArea(.all, edges: .top)ef
//                .transition(.opacity)
//            }
//            
//            if showLogin && !authManager.isAuthenticated {
//                LoginView(isRegistering: shouldStartWithRegistration)
//                    .transition(.opacity)
//            }
//            
//            // If user is already authenticated and has completed onboarding, show main view
//            if authManager.isAuthenticated && hasCompletedOnboarding {
            if hasCompletedOnboarding || showMain {
                ZStack {
                    MainZodiacView(completedOnboarding: true)
                        .transition(.opacity)
                        .onAppear {
                            print("🚀 Authenticated user with completed onboarding, showing MainZodiacView")
                        }
                }
            }
//            else if authManager.shouldShowOnboardingHoroscope && !hasCompletedOnboarding {
//                HoroscopeSplashView(completedOnboarding: false)
//                    .transition(.opacity)
//                    .onAppear {
//                        print("✨ Showing onboarding horoscope splash")
//                    }
//            }
//            else if authManager.isAuthenticated {
//                MainZodiacView(completedOnboarding: hasCompletedOnboarding)
//                    .transition(.opacity)
//                    .onAppear {
//                        print("🔐 Authenticated user, showing MainZodiacView")
//                    }
//            }
        }
        .animation(.easeInOut(duration: 0.7), value: showSplash)
        .animation(.easeInOut(duration: 0.7), value: showOnboarding)
        .animation(.easeInOut(duration: 0.7), value: showLogin)
        .animation(.easeInOut(duration: 0.7), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.7), value: authManager.shouldShowOnboardingHoroscope)
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            withAnimation(.easeInOut(duration: 0.7)) {
                hasCompletedOnboarding = true
                // Trigger tutorial bubbles after onboarding completes
                NotificationCenter.default.post(name: .showTutorialBubbles, object: nil)
                print("✅ Onboarding completed via consent notification")
            }
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            // Handle logout - when user goes from authenticated to not authenticated
            if oldValue == true && newValue == false {
                print("🚪 User logged out, returning to splash screen")
                showSplash = true
                showOnboarding = false
                showLogin = false
            }
        }
    }
}
