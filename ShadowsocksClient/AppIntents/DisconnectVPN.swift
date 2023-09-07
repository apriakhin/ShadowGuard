//
//  DisconnectVPN.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 08.09.2023.
//

import Foundation
import AppIntents
import SwiftData
import ShadowsocksManager

struct DisconnectVPN: AppIntent {
    static var title: LocalizedStringResource = "Disconnect VPN"
    static var openAppWhenRun = false
    
    private static let shadowsocksManager = ShadowsocksManager.shared
    
    func perform() async throws -> some IntentResult {
        guard let defaultConfig = try? DatabaseService.shared.getDefautConfig() else {
            return .result()
        }
        
        DisconnectVPN.shadowsocksManager.stop(defaultConfig.id.uuidString)
        
        return .result()
    }
}

