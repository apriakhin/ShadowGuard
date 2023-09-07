//
//  VPNStatus.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation

enum VPNStatus: String {
    case invalid = "Invalid"
    case disconnected = "Disconnected"
    case connecting = "Connecting..."
    case connected = "Connected"
    case reasserting = "Reasserting"
    case disconnecting = "Disconnecting..."
    case unknown = "Unknown"
}
