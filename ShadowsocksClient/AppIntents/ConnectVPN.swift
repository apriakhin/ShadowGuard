//
//  ConnectVPN.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation
import AppIntents
import SwiftData
import ShadowsocksManager

struct ConnectVPN: AppIntent {
    static var title: LocalizedStringResource = "Connect VPN"
    static var openAppWhenRun = false
    
    private static let shadowsocksManager = ShadowsocksManager.shared
    
    func perform() async throws -> some IntentResult {
        
        guard let defaultConfig = try? DatabaseService.shared.getDefautConfig() else {
            return .result()
        }
        
        ConnectVPN.shadowsocksManager.start(
            defaultConfig.id.uuidString,
            configJson: [
                "method": defaultConfig.method,
                "password": defaultConfig.password,
                "host": defaultConfig.host,
                "port": defaultConfig.port
            ],
            { error in print(error.rawValue) }
        )
        
        return .result()
    }
}
