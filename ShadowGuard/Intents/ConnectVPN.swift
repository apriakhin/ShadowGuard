//
//  ConnectVPN.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation
import AppIntents
import SwiftData

struct ConnectVPN: AppIntent {
    static var title: LocalizedStringResource = "ConnectVPN"
    static var openAppWhenRun = false
    
    func perform() async throws -> some IntentResult {
        let databaseService = ShadowGuardApp.dependencyFactory.databaseService
        let tunnelService = ShadowGuardApp.dependencyFactory.tunnelService
        
        guard let defaultServer = databaseService.defaultServer else {
            return .result()
        }
        
        tunnelService.start(
            tunnelId: defaultServer.id.uuidString,
            config: defaultServer.config,
            completion: { error in print(error.rawValue) }
        )
        
        return .result()
    }
}
