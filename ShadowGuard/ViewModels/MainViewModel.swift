//
//  MainViewModel.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Observation
import NetworkExtension

@Observable final class MainViewModel {
    // MARK: Public properties
    
    private(set) var status = Status.unknown
    private(set) var connectedDate: Date?
    
    private(set) var accessKey: String = "" {
        didSet {
            if !accessKey.isEmpty {
                isShowingAddServer = true
            }
        }
    }
    
    private(set) var errorMessage: LocalizedStringResource = "" {
        didSet {
            if errorMessage != "" {
                isShowingAlert = true
            }
        }
    }
    
    var isShowingAddServer = false
    var isShowingServerList = false
    var isShowingAbout = false
    var isShowingAlert = false
    
    var selectButtonType: SelectButtonType {
        if let defaultServer = databaseService.defaultServer {
            return .selected(defaultServer.title)
        } else if databaseService.isNotExistServers {
            return .add
        } else {
            return .select
        }
    }
    
    var selectButtonDisabled: Bool {
        switch status {
        case .connecting, .connected, .reasserting, .disconnecting:
            return true
        default:
            return false
        }
    }
    
    var toggleButtonDisabled: Bool {
        switch selectButtonType {
        case .add, .select:
            return true
        default:
            return false
        }
    }
    
    // MARK: Private properties
    
    private let statusMapper: StatusMapping
    private let tunnelService: TunnelServicing
    private let databaseService: DatabaseServicing

    private var observer: NSObjectProtocol?
    
    // MARK: Init
    
    init(
        statusMapper: StatusMapping,
        tunnelService: TunnelServicing,
        databaseService: DatabaseServicing
    ) {
        self.statusMapper = statusMapper
        self.tunnelService = tunnelService
        self.databaseService = databaseService

        setup()
    }
}

// MARK: - Public methods

extension MainViewModel {    
    func didTapToggleButton() {
        guard let defaultServer = databaseService.defaultServer else { return }
        
        switch status {
        case .invalid, .disconnected:
            tunnelService.start(
                tunnelId: defaultServer.id.uuidString,
                config: defaultServer.config,
                completion: { [weak self] error in
                    self?.errorMessage = error.message
                }
            )
            
        case .connected:
            tunnelService.stop(tunnelId: defaultServer.id.uuidString)
            
        default:
            break
        }
    }
    
    func didTapSelectButton() {
        switch selectButtonType {
        case .add:
            isShowingAddServer = true
            
        case .select, .selected:
            isShowingServerList = true
        }
    }
    
    func didTapAboutButton() {
        isShowingAbout = true
    }
    
    func didDismissAddServer() {
        accessKey = ""
    }
    
    func didOpenURL(_ url: URL) {
        accessKey = url.absoluteString
    }
}

// MARK: - Private methods

private extension MainViewModel {
    func setup() {
        Task {
            let tunnelProviderManager = try await NETunnelProviderManager.loadAllFromPreferences().first ?? NETunnelProviderManager()
            
            await MainActor.run {
                self.update(by: tunnelProviderManager.connection)
            }
        }
        
        observer = NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: nil) { [weak self] notification in
            guard let self, let connection = notification.object as? NEVPNConnection else { return }
            
            self.update(by: connection)
        }
    }
    
    func update(by connection: NEVPNConnection) {
        status = statusMapper.map(status: connection.status)
        connectedDate = connection.connectedDate
    }
}
