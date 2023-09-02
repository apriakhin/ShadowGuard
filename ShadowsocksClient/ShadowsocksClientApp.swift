//
//  ShadowsocksClientApp.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 23.08.2023.
//

import SwiftUI
import SwiftData

@main
struct ShadowsocksClientApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Config.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
