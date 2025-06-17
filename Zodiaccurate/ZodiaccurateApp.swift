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
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
        }
    }
}

// RootView manages the dissolve transition between splash and login
struct RootView: View {
    @State private var showLogin = false

    var body: some View {
        ZStack {
            if !showLogin {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showLogin = true
                    }
                }
                .transition(.opacity)
            }
            if showLogin {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.7), value: showLogin)
    }
}
