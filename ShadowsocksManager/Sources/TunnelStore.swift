// Copyright 2018 The Outline Authors

import Foundation

@objcMembers
public class TunnelStore: NSObject {
    private static let kTunnelStoreKey = "connectionStore"
    private static let kTunnelStatusKey = "connectionStatus"
    private static let kUdpSupportKey = "udpSupport"
    
    private let defaults: UserDefaults?
    
    public required init(appGroup: String) {
        defaults = UserDefaults(suiteName: appGroup)
        super.init()
    }
    
    public func load() -> Tunnel? {
        if let encodedTunnel = defaults?.data(forKey: TunnelStore.kTunnelStoreKey) {
            return Tunnel.decode(encodedTunnel)
        }

        return nil
    }
    
    @discardableResult
    public func save(_ tunnel: Tunnel) -> Bool {
        if let encodedTunnel = tunnel.encode() {
            defaults?.set(encodedTunnel, forKey: TunnelStore.kTunnelStoreKey)
        }

        return true
    }
    
    public var status: Tunnel.TunnelStatus {
        get {
            let status = defaults?.integer(forKey: TunnelStore.kTunnelStatusKey) ?? Tunnel.TunnelStatus.disconnected.rawValue
            return Tunnel.TunnelStatus(rawValue:status) ?? Tunnel.TunnelStatus.disconnected
        }
        set(newStatus) {
            defaults?.set(newStatus.rawValue, forKey: TunnelStore.kTunnelStatusKey)
        }
    }
    
    public var isUdpSupported: Bool {
        get {
            return defaults?.bool(forKey: TunnelStore.kUdpSupportKey) ?? false
        }
        set(udpSupport) {
            defaults?.set(udpSupport, forKey: TunnelStore.kUdpSupportKey)
        }
    }
}
