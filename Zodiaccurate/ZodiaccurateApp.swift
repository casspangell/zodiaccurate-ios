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
    
    init() {
        FirebaseApp.configure()
        
        // Configure API key for development (remove this after first run)
        // APIConfig.configureForDevelopment(openAIKey: "your-actual-api-key-here")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
        }
        .modelContainer(for: [UserDataModel.self, Item.self])
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
                SplashScreenView { hasCompletedOnboarding in
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showSplash = false
                        // Always check the actual onboarding completion status
                        // The hasLoggedOut flag doesn't affect navigation after splash
                        if hasCompletedOnboarding {
                            showLogin = true
                            shouldStartWithRegistration = false // Existing user should sign in
                        } else {
                            showOnboarding = true
                        }
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
            
            if authManager.isAuthenticated {
                MainView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.7), value: showSplash)
        .animation(.easeInOut(duration: 0.7), value: showOnboarding)
        .animation(.easeInOut(duration: 0.7), value: showLogin)
        .animation(.easeInOut(duration: 0.7), value: authManager.isAuthenticated)
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
