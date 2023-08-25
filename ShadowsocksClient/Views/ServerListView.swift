//
//  ServerListView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 25.08.2023.
//

import SwiftUI
import SwiftData

struct ServerListView: View {
    @State private var hasShowingEditServer = false
    @State private var editableServer: Server?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query() private var servers: [Server]

    var body: some View {
        NavigationStack {
            List {
                ForEach(servers) { server in
                    HStack {
                        Text(server.title)
                        
                        Spacer()
                        
                        if server.isDefault {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .swipeActions {
                        if !server.isDefault {
                            Button("Delete") {
                                deleteServer(server)
                            }
                            .tint(.red)
                        }
                        
                        Button("Edit") {
                            editableServer = server
                            hasShowingEditServer = true
                        }
                        .tint(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectServer(server)
                    }
                }
            }
            .navigationTitle(Text("Select Server"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
            }
            .onChange(of: hasShowingEditServer, initial: true, {})
            .sheet(isPresented: $hasShowingEditServer) {
                if let editableServer {
                    EditServerView(server: editableServer)
                }
            }
        }
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func selectServer(_ server: Server) {
        servers.forEach { server in
            server.setValue(forKey: \.isDefault, to: false)
        }
        server.setValue(forKey: \.isDefault, to: true)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error)
        }
    }

    private func deleteServer(_ server: Server) {
        withAnimation {
            modelContext.delete(server)
        }
    }
}

#Preview {
    ServerListView()
        .modelContainer(for: Server.self, inMemory: true)
}
