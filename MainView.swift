//
//  MainView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var hasShowingAddServer = false
    @State private var hasShowingServerList = false
    @Query(filter: #Predicate<Server> { $0.isDefault }) private var servers: [Server]
    
    private var defaultServer: Server? { servers.first }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 40)
                
                if let defaultServer {
                    Text("Tap to connect to the server")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer(minLength: 24)
                    
                    Button(action: showServerList) {
                        Text(defaultServer.title)
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer(minLength: 96)
                    
                    Button(action: toggleConnection) {
                        Image(systemName: "power")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(40)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                    
                    Spacer(minLength: 96)
                    
                    Text("Disconnected")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer(minLength: 96)
                } else {
                    Text("Add new server to connect")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer(minLength: 96)
                }
                
                Button(action: showInfo) {
                    Image(systemName: "info")
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                
                Spacer(minLength: 40)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: showAddServer) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $hasShowingAddServer) {
                EditServerView()
            }
            .sheet(isPresented: $hasShowingServerList) {
                ServerListView()
            }
        }
    }
    
    private func showAddServer() {
        hasShowingAddServer = true
    }
    
    private func showServerList() {
        hasShowingServerList = true
    }
    
    private func toggleConnection() {
        
    }
    
    private func showInfo() {
        
    }
}

#Preview {
    MainView()
}
