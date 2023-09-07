//
//  VPNStatusObserver.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Observation
import NetworkExtension

@Observable final class VPNStatusObserver {
    private(set) var status = VPNStatus.unknown
    
    private let vpnStatusMapper: VPNStatusMapping
    private var providerManager: NETunnelProviderManager!
    private var observer: NSObjectProtocol?
    
    init(vpnStatusMapper: VPNStatusMapping = VPNStatusMapper()) {
        self.vpnStatusMapper = vpnStatusMapper
        setupInitial()
        setupObserver()
    }
    
    private func loadProviderManager(completion: @escaping () -> Void) {
       NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
           if error == nil {
               self.providerManager = managers?.first ?? NETunnelProviderManager()
               completion()
           }
       }
    }
    
    private func setupInitial() {
        loadProviderManager { [weak self] in
            guard let self else { return }
            self.updateStatus(by: self.providerManager.connection)
        }
    }
    
    private func setupObserver() {
        observer = NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { [weak self] notification in
            guard let self, let connection = notification.object as? NEVPNConnection else { return }
            self.updateStatus(by: connection)
        }
    }
    
    private func updateStatus(by connection: NEVPNConnection) {
        status = vpnStatusMapper.map(status: connection.status)
    }
}
