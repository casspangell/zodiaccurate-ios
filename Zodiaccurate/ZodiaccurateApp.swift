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
        // Temporarily reset onboarding flag for testing
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
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
    @State private var hasLoggedOut = false
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showSplash = false
                        // If user just logged out, reset onboarding flag and show onboarding
                        if hasLoggedOut {
                            hasCompletedOnboarding = false
                            showOnboarding = true
                        } else {
                            // Temporarily always show onboarding
                            // if hasCompletedOnboarding {
                            //     showLogin = true
                            // } else {
                                showOnboarding = true
                            // }
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
                        shouldStartWithRegistration = true
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
                hasLoggedOut = true
                showSplash = true
                showOnboarding = false
                showLogin = false
            }
        }
    }
}
