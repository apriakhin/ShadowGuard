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
    @State private var vpnStatusObserver = VPNStatusObserver()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(DatabaseService.shared.sharedModelContainer)
        .environment(vpnStatusObserver)
    }
}
