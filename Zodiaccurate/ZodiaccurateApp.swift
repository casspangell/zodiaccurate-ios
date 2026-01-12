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

// RootView manages the flow: Splash → Login/Registration → Onboarding (if needed) → Main
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
                        // Check authentication status first, then onboarding completion
                        if authManager.isAuthenticated {
                            print("✅ User is authenticated")
                            if hasCompletedOnboarding {
                                print("✅ User has completed onboarding, showing MainZodiacView")
                                showMain = true
                            } else {
                                print("🆕 User registered but hasn't completed onboarding, showing onboarding")
                                showOnboarding = true
                            }
                        } else {
                            // User is not authenticated
                            if hasCompletedOnboarding {
                                print("🔐 User completed onboarding but not authenticated, showing LoginView")
                                shouldStartWithRegistration = false
                                showLogin = true
                            } else {
                                print("🆕 New user detected, showing LoginView for registration")
                                shouldStartWithRegistration = true
                                showLogin = true
                            }
                        }
                    }
                }
                .transition(.opacity)
            }

            if showOnboarding {
                ConversationalOnboardingView(
                    onComplete: {
                        print("🔄 ConversationalOnboardingView completed")
                        withAnimation(.easeInOut(duration: 0.7)) {
                            hasCompletedOnboarding = true
                            showOnboarding = false
                            
                            // Check if user is already authenticated (registered)
                            if authManager.isAuthenticated {
                                print("✅ User already registered, navigating directly to MainZodiacView")
                                showMain = true
                            } else {
                                print("🔐 User not registered yet, showing LoginView for registration")
                                shouldStartWithRegistration = true
                                showLogin = true
                            }
                        }
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
                .transition(.opacity)
            }
            
            // Show login view if user has completed onboarding but isn't authenticated
            if showLogin && !authManager.isAuthenticated {
                LoginView(isRegistering: shouldStartWithRegistration)
                    .transition(.opacity)
            }
            
            // If user is already authenticated and has completed onboarding, show main view
            if showMain && authManager.isAuthenticated && hasCompletedOnboarding {
                MainZodiacView(completedOnboarding: true)
                    .transition(.opacity)
                    .onAppear {
                        print("🚀 Authenticated user with completed onboarding, showing MainZodiacView")
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
        .animation(.easeInOut(duration: 0.7), value: showMain)
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
            // Handle successful login/registration - when user goes from not authenticated to authenticated
            if oldValue == false && newValue == true {
                print("✅ User authenticated (registered or logged in)")
                withAnimation(.easeInOut(duration: 0.7)) {
                    showLogin = false
                    
                    // Check if onboarding is completed
                    if hasCompletedOnboarding {
                        // Returning user or user who completed onboarding, show main view
                        print("✅ User has completed onboarding, showing MainZodiacView")
                        showMain = true
                    } else {
                        // New registration, show onboarding
                        print("🆕 New registration detected, showing onboarding")
                        showOnboarding = true
                    }
                }
            }
            // Handle logout - when user goes from authenticated to not authenticated
            if oldValue == true && newValue == false {
                print("🚪 User logged out")
                if hasCompletedOnboarding {
                    // If user has completed onboarding, show login view
                    print("🔐 Showing login view after logout")
                    withAnimation(.easeInOut(duration: 0.7)) {
                        shouldStartWithRegistration = false
                        showLogin = true
                        showOnboarding = false
                        showMain = false
                        showSplash = false
                    }
                } else {
                    // If user hasn't completed onboarding, return to splash screen
                    print("🔄 Returning to splash screen")
                    showSplash = true
                    showOnboarding = false
                    showLogin = false
                    showMain = false
                }
            }
        }
        .onAppear {
            // Check initial state after splash is dismissed
            if !showSplash {
                if authManager.isAuthenticated {
                    if hasCompletedOnboarding {
                        // Authenticated user with completed onboarding
                        if !showMain {
                            print("🔐 App appeared: Authenticated user with completed onboarding, showing MainZodiacView")
                            showMain = true
                        }
                    } else {
                        // Authenticated user without completed onboarding
                        if !showOnboarding {
                            print("🔐 App appeared: Authenticated user without completed onboarding, showing onboarding")
                            showOnboarding = true
                        }
                    }
                } else {
                    // Not authenticated
                    if hasCompletedOnboarding {
                        // User completed onboarding but not authenticated
                        if !showLogin {
                            print("🔐 App appeared: User completed onboarding but not authenticated, showing LoginView")
                            shouldStartWithRegistration = false
                            showLogin = true
                        }
                    } else {
                        // New user, show login for registration
                        if !showLogin {
                            print("🔐 App appeared: New user, showing LoginView for registration")
                            shouldStartWithRegistration = true
                            showLogin = true
                        }
                    }
                }
            }
        }
    }
}
