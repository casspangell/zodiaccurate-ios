//
//  ZodiaccurateApp.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI
import SwiftData

@main
struct ZodiaccurateApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
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
