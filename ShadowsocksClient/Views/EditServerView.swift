//
//  EditServerView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import SwiftUI
import SwiftData

struct EditServerView: View {
    var server: Server?
    
    @State private var title: String = "Proxy server"
    @State private var accessKey: String = ""
    @Query() private var servers: [Server]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var isNew: Bool { server == nil }
    private var isValid: Bool { !title.isEmpty && !accessKey.isEmpty }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Title")
                        Spacer()
                        TextField("Title", text: $title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Access Key")
                        Spacer()
                        TextField("ss://access-key", text: $accessKey)
                            .multilineTextAlignment(.trailing)
                            .disabled(!isNew)
                    }
                }
            }
            .navigationTitle(Text(isNew ? "Add Server" : "Edit Server"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: isNew ? addServer : saveServer) {
                        Text(isNew ? "Add": "Save")
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                guard let server else { return }
                
                title = server.title
                accessKey = server.accessKey
            }
        }
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func addServer() {
        servers.forEach { server in
            server.setValue(forKey: \.isDefault, to: false)
        }
        
        do {
            try modelContext.save()
            modelContext.insert(Server(title: title, accessKey: accessKey, isDefault: true))
            dismiss()
        } catch {
            print(error)
        }
    }
    
    private func saveServer() {
        server?.setValue(forKey: \.title, to: title)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error)
        }
    }
}

#Preview {
    EditServerView(server: Server(title: "Test", accessKey: "Test", isDefault: true))
        .modelContainer(for: Server.self, inMemory: true)
}
