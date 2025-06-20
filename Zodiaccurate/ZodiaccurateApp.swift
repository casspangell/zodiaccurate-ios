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
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showSplash = false
                        // Temporarily always show onboarding
                        // if hasCompletedOnboarding {
                        //     showLogin = true
                        // } else {
                            showOnboarding = true
                        // }
                    }
                }
                .transition(.opacity)
            }
            
            if showOnboarding {
                ConversationalOnboardingView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        // Temporarily comment out onboarding completion
                        // hasCompletedOnboarding = true
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
    }
}
