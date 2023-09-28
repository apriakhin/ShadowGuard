// Copyright 2018 The Outline Authors

import NetworkExtension
import os

protocol TunnelServicing {
    func start(tunnelId: String, config: Config, completion: @escaping (Callback))
    func startLastSuccessfulTunnel(completion: @escaping (Callback))
    func stop(tunnelId: String)
    func isActive(tunnelId: String?) -> Bool
}

enum ErrorCode: Int {
    case noError = 0
    case undefined = 1
    case vpnPermissionNotGranted = 2
    case invalidServerCredentials = 3
    case udpRelayNotEnabled = 4
    case serverUnreachable = 5
    case vpnStartFailure = 6
    case illegalServerConfiguration = 7
    case shadowsocksStartFailure = 8
    case configureSystemProxyFailure = 9
    case noAdminPermissions = 10
    case unsupportedRoutingTable = 11
    case systemMisconfigured = 12
    
    var message: LocalizedStringResource {
        switch self {
        case .noError:
            return ""
        case .undefined:
            return "Undefined"
        case .vpnPermissionNotGranted:
            return "VpnPermissionNotGranted"
        case .invalidServerCredentials:
            return "InvalidServerCredentials"
        case .udpRelayNotEnabled:
            return "UdpRelayNotEnabled"
        case .serverUnreachable:
            return "ServerUnreachable"
        case .vpnStartFailure:
            return "VpnStartFailure"
        case .illegalServerConfiguration:
            return "IllegalServerConfiguration"
        case .shadowsocksStartFailure:
            return "ShadowsocksStartFailure"
        case .configureSystemProxyFailure:
            return "ConfigureSystemProxyFailure"
        case .noAdminPermissions:
            return "NoAdminPermissions"
        case .unsupportedRoutingTable:
            return "UnsupportedRoutingTable"
        case .systemMisconfigured:
            return "SystemMisconfigured"
        }
    }
}

enum Action {
    static let start = "start"
    static let restart = "restart"
    static let stop = "stop"
    static let getTunnelId = "getTunnelId"
}

enum MessageKey {
    static let action = "action"
    static let tunnelId = "tunnelId"
    static let config = "config"
    static let errorCode = "errorCode"
    static let host = "host"
    static let port = "port"
    static let isOnDemand = "is-on-demand"
}

typealias Callback = (ErrorCode) -> Void
typealias VpnStatusObserver = (NEVPNStatus, String) -> Void

final class TunnelService: TunnelServicing {
    private static let kVpnExtensionBundleId = "\(Bundle.main.bundleIdentifier!).VpnExtension"

    public private(set) var activeTunnelId: String?
    private var tunnelProviderManager: NETunnelProviderManager?
    private var vpnStatusObserver: VpnStatusObserver?
    private let logger = Logger()

    init() {
        Task {
            tunnelProviderManager = try await NETunnelProviderManager.loadAllFromPreferences().first ?? NETunnelProviderManager()
            
            await MainActor.run {
                self.observeVpnStatusChange(self.tunnelProviderManager!)
                
                if self.isVpnConnected() {
                    self.retrieveActiveTunnelId()
                }
            }
        }
    }
    
    // MARK: Interface

    public func start(tunnelId: String, config: Config, completion: @escaping (Callback)) {
        guard !isActive(tunnelId: tunnelId) else {
            return completion(ErrorCode.noError)
        }
        
        if isVpnConnected() {
            return restartVpn(tunnelId: tunnelId, config: config, completion: completion)
        }
        
        startVpn(tunnelId: tunnelId, config: config, isAutoConnect: false, completion: completion)
    }

    public func startLastSuccessfulTunnel(completion: @escaping (Callback)) {
        startVpn(tunnelId: nil, config: nil, isAutoConnect: true, completion: completion)
    }

    public func stop(tunnelId: String) {
        if !isActive(tunnelId: tunnelId) {
            return logger.warning("Cannot stop VPN, tunnel ID \(tunnelId)")
        }

        stopVpn()
    }

    public func onVpnStatusChange(_ observer: @escaping(VpnStatusObserver)) {
        vpnStatusObserver = observer
    }

    public func isActive(tunnelId: String?) -> Bool {
        if self.activeTunnelId == nil {
            return false
        }
        return self.activeTunnelId == tunnelId && isVpnConnected()
    }

    // MARK: Helpers
    
    private func map(config: Config) -> [String: Any] {
        return [
            "method": config.method.rawValue as Any,
            "password": config.password as Any,
            "host": config.host as Any,
            "port": config.port as Any
        ]
    }

    private func startVpn(tunnelId: String?, config: Config?, isAutoConnect: Bool, completion: @escaping(Callback)) {
        setupVpn() { error in
            if error != nil {
                self.logger.error("Failed to setup VPN: \(String(describing: error))")
                return completion(ErrorCode.vpnPermissionNotGranted);
            }
            
            let message = [MessageKey.action: Action.start, MessageKey.tunnelId: tunnelId ?? ""];
            
            self.sendVpnExtensionMessage(message) { response in
                self.onStartVpnExtensionMessage(response, completion: completion)
            }
            
            var tunnelOptions: [String: Any]? = nil
            
            if !isAutoConnect {
                if let config {
                    tunnelOptions = self.map(config: config)
                } else {
                    tunnelOptions = [:]
                }
                tunnelOptions?[MessageKey.tunnelId] = tunnelId
            } else {
                tunnelOptions = [MessageKey.isOnDemand: "true"];
            }
            
            let session = self.tunnelProviderManager?.connection as! NETunnelProviderSession
            
            do {
                try session.startTunnel(options: tunnelOptions)
            } catch let error as NSError  {
                self.logger.error("Failed to start VPN: \(error)")
                completion(ErrorCode.vpnStartFailure)
            }
        }
    }
    
    private func stopVpn() {
        let session: NETunnelProviderSession = tunnelProviderManager?.connection as! NETunnelProviderSession
        session.stopTunnel()
        
        setConnectVpnOnDemand(false)
        activeTunnelId = nil
    }
    

    private func restartVpn(tunnelId: String, config: Config, completion: @escaping(Callback)) {
        if activeTunnelId != nil {
            vpnStatusObserver?(.disconnected, activeTunnelId!)
        }
        
        let message: [String : Any] = [
            MessageKey.action: Action.restart,
            MessageKey.tunnelId: tunnelId,
            MessageKey.config: map(config: config)
        ]
        
        self.sendVpnExtensionMessage(message) { response in
            self.onStartVpnExtensionMessage(response, completion: completion)
        }
    }

    private func setupVpn(completion: @escaping(Error?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences() { (managers, error) in
            if let error = error {
                self.logger.error("Failed to load VPN configuration: \(error)")
                return completion(error)
            }
            
            var manager: NETunnelProviderManager!
            
            if let managers = managers, managers.count > 0 {
                manager = managers.first
                let hasOnDemandRules = !(manager.onDemandRules?.isEmpty ?? true)
                
                if manager.isEnabled && hasOnDemandRules {
                    self.tunnelProviderManager = manager
                    return completion(nil)
                }
                
            } else {
                let config = NETunnelProviderProtocol()
                config.providerBundleIdentifier = TunnelService.kVpnExtensionBundleId
                config.serverAddress = "Outline"
                
                manager = NETunnelProviderManager()
                manager.protocolConfiguration = config
            }

            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = .any
            
            manager.onDemandRules = [connectRule]
            manager.isEnabled = true
            
            manager.saveToPreferences() { error in
                if let error = error {
                    self.logger.error("Failed to save VPN configuration: \(error)")
                    return completion(error)
                }
                
                self.observeVpnStatusChange(manager!)
                self.tunnelProviderManager = manager
                
                NotificationCenter.default.post(name: .NEVPNConfigurationChange, object: nil)

                self.tunnelProviderManager?.loadFromPreferences() { error in
                    completion(error)
                }
            }
        }
    }
    
    private func setConnectVpnOnDemand(_ enabled: Bool) {
        self.tunnelProviderManager?.isOnDemandEnabled = enabled
        
        self.tunnelProviderManager?.saveToPreferences { error  in
            if let error = error {
                return self.logger.error("Failed to set VPN on demand to \(enabled): \(error)")
            }
        }
    }
    
    private func getTunnelManager(_ completion: @escaping ((NETunnelProviderManager?) -> Void)) {
        NETunnelProviderManager.loadAllFromPreferences() { (managers, error) in
            guard error == nil, managers != nil else {
                completion(nil)
                return self.logger.error("Failed to get tunnel manager: \(String(describing: error))")
            }
            
            var manager: NETunnelProviderManager?
            
            if managers!.count > 0 {
                manager = managers!.first
            }
            
            completion(manager)
        }
    }
    
    private func retrieveActiveTunnelId() {
        if tunnelProviderManager == nil {
            return
        }
        
        self.sendVpnExtensionMessage([MessageKey.action: Action.getTunnelId]) { response in
            guard response != nil else {
                return self.logger.error("Failed to retrieve the active tunnel ID")
            }
            
            guard let activeTunnelId = response?[MessageKey.tunnelId] as? String else {
                return self.logger.error("Failed to retrieve the active tunnel ID")
            }
            
            self.logger.info("Got active tunnel ID: \(activeTunnelId)")
            
            self.activeTunnelId = activeTunnelId
            self.vpnStatusObserver?(.connected, self.activeTunnelId!)
        }
    }

    private func isVpnConnected() -> Bool {
        if tunnelProviderManager == nil {
            return false
        }
        
        let vpnStatus = tunnelProviderManager?.connection.status
        
        return vpnStatus == .connected || vpnStatus == .connecting || vpnStatus == .reasserting
    }
    
    private func observeVpnStatusChange(_ manager: NETunnelProviderManager) {
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: manager.connection)
        NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusChanged), name: .NEVPNStatusDidChange, object: manager.connection)
    }
    
    @objc func vpnStatusChanged() {
        if let vpnStatus = tunnelProviderManager?.connection.status {
            if let tunnelId = activeTunnelId {
                if (vpnStatus == .disconnected) {
                    activeTunnelId = nil
                }
                
                vpnStatusObserver?(vpnStatus, tunnelId)
                
            } else if vpnStatus == .connected {
                retrieveActiveTunnelId()
            }
        }
    }
    
    // MARK: VPN extension IPC
    
    private func sendVpnExtensionMessage(_ message: [String: Any], callback: @escaping (([String: Any]?) -> Void)) {
        if tunnelProviderManager == nil {
            return logger.error("Cannot set an extension callback without a tunnel manager")
        }
        
        var data: Data
        
        do {
            data = try JSONSerialization.data(withJSONObject: message, options: [])
        } catch {
            return logger.error("Failed to serialize message to VpnExtension as JSON")
        }
        
        let completionHandler: (Data?) -> Void = { data in
            guard let responseData = data else {
                return callback(nil)
            }
            
            do {
                if let response = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                    self.logger.info("Received extension message: \(String(describing: response))")
                    return callback(response)
                }
            } catch {
                self.logger.error("Failed to deserialize the VpnExtension response")
            }
            
            callback(nil)
        }
        
        let session: NETunnelProviderSession = tunnelProviderManager?.connection as! NETunnelProviderSession
        
        do {
            try session.sendProviderMessage(data, responseHandler: completionHandler)
        } catch {
            logger.error("Failed to send message to VpnExtension")
        }
    }
    
    private func onStartVpnExtensionMessage(_ message: [String:Any]?, completion: Callback) {
        guard let response = message else {
            return completion(ErrorCode.vpnStartFailure)
        }
        
        let rawErrorCode = response[MessageKey.errorCode] as? Int ?? ErrorCode.undefined.rawValue
        
        if rawErrorCode == ErrorCode.noError.rawValue, let tunnelId = response[MessageKey.tunnelId] as? String {
            self.activeTunnelId = tunnelId
            self.setConnectVpnOnDemand(true)
        }
        
        completion(ErrorCode(rawValue: rawErrorCode) ?? ErrorCode.noError)
    }
}
