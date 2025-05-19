//
//  ZodiaccurateApp.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 5/19/25.
//

import SwiftUI

@main
struct ZodiaccurateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
