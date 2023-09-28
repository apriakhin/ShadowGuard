//
//  DisconnectVPN.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 08.09.2023.
//

import Foundation
import AppIntents
import SwiftData

struct DisconnectVPN: AppIntent {
    static var title: LocalizedStringResource = "DisconnectVPN"
    static var openAppWhenRun = false
    
    func perform() async throws -> some IntentResult {
        let databaseService = ShadowGuardApp.dependencyFactory.databaseService
        let tunnelService = ShadowGuardApp.dependencyFactory.tunnelService
        
        guard let defaultServer = databaseService.defaultServer else {
            return .result()
        }
        
        tunnelService.stop(tunnelId: defaultServer.id.uuidString)
        
        return .result()
    }
}
