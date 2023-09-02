//
//  ConfigListView.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 25.08.2023.
//

import SwiftUI
import SwiftData

struct ConfigListView: View {
    @State private var hasShowingEditConfig = false
    @State private var editableConfig: Config?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query() private var configs: [Config]

    var body: some View {
        NavigationStack {
            List {
                ForEach(configs) { config in
                    HStack {
                        Text(config.title)
                        
                        Spacer()
                        
                        if config.isDefault {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .swipeActions {
                        if !config.isDefault {
                            Button("Delete") {
                                deleteConfig(config)
                            }
                            .tint(.red)
                        }
                        
                        Button("Edit") {
                            editableConfig = config
                            hasShowingEditConfig = true
                        }
                        .tint(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectConfig(config)
                    }
                }
            }
            .navigationTitle(Text("Select Server"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: cancel) {
                        Text("Cancel")
                    }
                }
            }
            .onChange(of: hasShowingEditConfig, initial: true, {})
            .sheet(isPresented: $hasShowingEditConfig) {
                if let editableConfig {
                    EditConfigView(config: editableConfig)
                }
            }
        }
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func selectConfig(_ config: Config) {
        configs.forEach { config in
            config.setValue(forKey: \.isDefault, to: false)
        }
        config.setValue(forKey: \.isDefault, to: true)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print(error)
        }
    }

    private func deleteConfig(_ config: Config) {
        withAnimation {
            modelContext.delete(config)
        }
    }
}

#Preview {
    ConfigListView()
        .modelContainer(for: Config.self, inMemory: true)
}
