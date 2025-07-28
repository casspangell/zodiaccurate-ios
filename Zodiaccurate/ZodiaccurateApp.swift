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

@main
struct ZodiaccurateApp: App {
    @StateObject private var authManager = AuthenticationManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var shouldClearAuthData = false
    
    init() {
        FirebaseApp.configure()
        
        // Check if this is the first launch after installation
        shouldClearAuthData = checkFirstLaunchAfterInstallation()
        
        // Configure API key for development (remove this after first run)
        // APIConfig.configureForDevelopment(openAIKey: "your-actual-api-key-here")
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
            
            // Clear OnboardingDataAccess data
            OnboardingDataAccess.clearAllData()
            
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
        // Get all UserDefaults keys
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        
        // Also clear any custom keys that might not be in the domain
        let keysToRemove = [
            "hasCompletedOnboarding",
            "userFirstName",
            "userBirthDate", 
            "userBirthTime",
            "userZodiacSign",
            "userResponses",
            "welcomeHoroscope",
            "lastLoggedInEmail",
            "profileUUID",
            "currentUserId"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
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
        // Clear SwiftData by deleting the container
        do {
            let container = try ModelContainer(for: UserDataModel.self, Item.self)
            let context = ModelContext(container)
            
            // Delete all UserDataModel records
            let userDescriptor = FetchDescriptor<UserDataModel>()
            let userResults = try context.fetch(userDescriptor)
            for user in userResults {
                context.delete(user)
            }
            
            // Delete all Item records
            let itemDescriptor = FetchDescriptor<Item>()
            let itemResults = try context.fetch(itemDescriptor)
            for item in itemResults {
                context.delete(item)
            }
            
            try context.save()
            print("✅ SwiftData cleared")
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
        .modelContainer(for: [UserDataModel.self, Item.self, StardustBalance.self, StardustTransaction.self])
    }
}

// RootView manages the flow: Splash → Onboarding → Login → Main
struct RootView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var showLogin = false
    @State private var shouldStartWithRegistration = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView { _ in
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showSplash = false
                        // Always show onboarding flow when coming from splash
                        showOnboarding = true
                    }
                }
                .transition(.opacity)
            }
            
            if showOnboarding {
                ConversationalOnboardingView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        // Save onboarding completion flag
                        hasCompletedOnboarding = true
                        showOnboarding = false
                        showLogin = true
                        shouldStartWithRegistration = true // New user completing onboarding should register
                    }
                }
                .transition(.opacity)
            }
            
            if showLogin && !authManager.isAuthenticated {
                LoginView(isRegistering: shouldStartWithRegistration)
                    .transition(.opacity)
            }
            
            if authManager.shouldShowOnboardingHoroscope {
                HoroscopeSplashView()
                    .transition(.opacity)
            } else if authManager.isAuthenticated {
                MainZodiacView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.7), value: showSplash)
        .animation(.easeInOut(duration: 0.7), value: showOnboarding)
        .animation(.easeInOut(duration: 0.7), value: showLogin)
        .animation(.easeInOut(duration: 0.7), value: authManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.7), value: authManager.shouldShowOnboardingHoroscope)
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
