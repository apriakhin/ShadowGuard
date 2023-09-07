//
//  EditConfigView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import SwiftUI
import SwiftData

struct EditConfigView: View {
    var config: Config?
    var openedAccessKey: String?
    
    @Query() private var configs: [Config]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = "Proxy server"
    @State private var accessKey: String = ""
    
    private var isNew: Bool { config == nil }
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
                    if isNew {
                        HStack {
                            Text("Access Key")
                            Spacer()
                            TextField("ss://access-key", text: $accessKey)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle(Text(isNew ? "Add Server" : "Edit Server"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: isNew ? addConfig : saveConfig) {
                        Text(isNew ? "Add": "Save")
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let config {
                    title = config.title
                }
                
                if let openedAccessKey {
                    accessKey = openedAccessKey
                }
            }
        }
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func addConfig() {
        guard let shadowsocksConfig = ShadowsocksURIParser().parse(uri: accessKey) else { return }
        let config = ConfigMapper().map(title: title, shadowsocksConfig: shadowsocksConfig, isDefault: true)
        
        configs.forEach { config in
            config.setValue(forKey: \.isDefault, to: false)
        }
        
        do {
            try modelContext.save()
            modelContext.insert(config)
            dismiss()
        } catch {
            print(error)
        }
    }
    
    private func saveConfig() {
        config?.setValue(forKey: \.title, to: title)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error)
        }
    }
}

#Preview {
    EditConfigView(config: nil)
        .modelContainer(for: Config.self, inMemory: true)
}
