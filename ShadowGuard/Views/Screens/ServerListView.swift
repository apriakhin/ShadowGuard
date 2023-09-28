//
//  ServerListView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI
import SwiftData

struct ServerListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query() private var servers: [Server]
    @State private var selectedServer: Server?
    @State private var isShowingEditServer = false
    @State private var isShowingAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(servers) { server in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(server.title)
                                .foregroundColor(.primary)
                                .font(.headline)
                            
                            Text("\(server.config.host):\(String(server.config.port))")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        if server.isDefault {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .swipeActions {
                        Button(action: { delete(server: server) }) {
                            Image(systemName: "trash.fill")
                        }
                        .tint(.red)
                        
                        Button(action: { selectedServer = server }) {
                            Image(systemName: "gearshape.fill")
                        }
                        .tint(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        select(server: server)
                    }
                }
            }
            .navigationTitle("ServerList")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AddServerView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: selectedServer, initial: false) {
                if selectedServer != nil {
                    isShowingEditServer = true
                }
            }
            .sheet(isPresented: $isShowingEditServer) {
                selectedServer = nil
            } content: {
                if let selectedServer {
                    EditServerView(server: selectedServer)
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Error"),
                message: Text("SavingError"),
                dismissButton: .default(Text("OK"))
            )
        }
        #if os(macOS)
        .frame(width: 300, height: 300)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func select(server: Server) {
        servers.forEach { server in
            server.setValue(forKey: \.isDefault, to: false)
        }
        server.setValue(forKey: \.isDefault, to: true)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            isShowingAlert = true
        }
    }

    private func delete(server: Server) {
        withAnimation {
            modelContext.delete(server)
        }
    }
}
