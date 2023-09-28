//
//  ShadowGuardApp.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 23.08.2023.
//

import SwiftUI

@main
struct ShadowGuardApp: App {
    // MARK: Static
    
    static let dependencyFactory: DependencyFactoring = DependencyFactory()
    
    // MARK: Dependencies

    private let databaseService = dependencyFactory.databaseService

    @State private var mainViewModel = MainViewModel(
        statusMapper: dependencyFactory.statusMapper,
        tunnelService: dependencyFactory.tunnelService, 
        databaseService: dependencyFactory.databaseService
    )

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(mainViewModel)
        }
        .modelContainer(databaseService.modelContainer)
        #if os(macOS)
        .defaultSize(width: 320, height: 480)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        #endif
    }
}
