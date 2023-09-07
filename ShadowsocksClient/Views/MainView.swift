//
//  MainView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import SwiftUI
import SwiftData
import ShadowsocksManager

struct MainView: View {
    @Query(filter: #Predicate<Config> { $0.isDefault }) private var configs: [Config]
    @Environment(VPNStatusObserver.self) private var vpnStatusObserver

    @State private var hasShowingAddConfig = false
    @State private var hasShowingConfigList = false
    @State private var openedAccessKey: String?
    
    private let shadowsocksManager = ShadowsocksManager()
    private var defaultConfig: Config? { configs.first }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 40)
                
                Text("Tap to connect to the server")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer(minLength: 24)
                
                Button(action: showConfigList) {
                    Text(defaultConfig?.title ?? "No select")
                }
                .buttonStyle(.bordered)
                .disabled(configs.isEmpty)
                
                Spacer(minLength: 96)
                
                Button(action: toggleConnection) {
                    Image(systemName: "power")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(40)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .disabled(defaultConfig == nil)
                
                Spacer(minLength: 96)
                
                Text(vpnStatusObserver.status.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer(minLength: 96)
                
                Button(action: showInfo) {
                    Image(systemName: "info")
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                
                Spacer(minLength: 40)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: showAddConfig) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: hasShowingAddConfig, initial: true, {})
            .sheet(isPresented: $hasShowingAddConfig) {
                EditConfigView(openedAccessKey: openedAccessKey)
                    .onAppear {
                        openedAccessKey = nil
                    }
            }
            .sheet(isPresented: $hasShowingConfigList) {
                ConfigListView()
            }
            .onOpenURL { incomingURL in
                openedAccessKey = incomingURL.absoluteString
                hasShowingAddConfig = true
            }
        }
    }
    
    private func showAddConfig() {
        hasShowingAddConfig = true
    }
    
    private func showConfigList() {
        hasShowingConfigList = true
    }
    
    private func toggleConnection() {
        guard let defaultConfig else { return }
        
        if vpnStatusObserver.status == .connected {
            shadowsocksManager.stop(defaultConfig.id.uuidString)

        } else {
            shadowsocksManager.start(
                defaultConfig.id.uuidString,
                configJson: [
                    "method": defaultConfig.method,
                    "password": defaultConfig.password,
                    "host": defaultConfig.host,
                    "port": defaultConfig.port
                ],
                { error in print(error.rawValue) }
            )
        }
    }
    
    private func showInfo() {
        
    }
}

#Preview {
    MainView()
}
