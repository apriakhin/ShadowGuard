//
//  VPNStatusMapper.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation
import NetworkExtension

protocol VPNStatusMapping {
    func map(status: NEVPNStatus) -> VPNStatus
}

struct VPNStatusMapper: VPNStatusMapping {
    func map(status: NEVPNStatus) -> VPNStatus {
        switch status {
        case .invalid: return .invalid
        case .disconnected: return .disconnected
        case .connecting: return .connecting
        case .connected: return .connected
        case .reasserting: return .reasserting
        case .disconnecting: return .disconnecting
        @unknown default: return .unknown
        }
    }
}
