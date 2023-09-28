//
//  AddServerView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI
import SwiftData

struct AddServerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query() private var configs: [Server]
    @State private var title: String = ""
    @State var accessKey: String = ""
    @State private var isShowingAlert = false
    @State private var errorMessage: LocalizedStringResource = ""
    
    var isModal = false

    private var isValid: Bool {
        !title.isEmpty && !accessKey.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        TextField("MyServer", text: $title)
                    } label: {
                        Text("Title")
                            .frame(minWidth: 100, alignment: .leading)
                    }

                    LabeledContent {
                        TextField("ss://access-key", text: $accessKey)
                    } label: {
                        Text("AccessKey")
                            .frame(minWidth: 100, alignment: .leading)
                    }
                }
            }
            .navigationTitle("AddServer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: cancel) {
                            Text("Cancel")
                        }
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: add) {
                        Text("Add")
                    }
                    .disabled(!isValid)
                }
            }
            .onChange(of: errorMessage, initial: false) {
                if errorMessage != "" {
                    isShowingAlert = true
                }
            }
            .onChange(of: isShowingAlert, initial: false) {
                if isShowingAlert == false {
                    errorMessage = ""
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        #if os(macOS)
        .frame(width: 300, height: 260)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
    
    private func cancel() {
        dismiss()
    }
    
    private func add() {
        guard let config = URIParser().parse(uri: accessKey) else {
            errorMessage = "IncorrectAccessKey"
            return
        }

        let server = Server(
            title: title,
            config: config,
            isDefault: true
        )
        
        configs.forEach { config in
            config.setValue(forKey: \.isDefault, to: false)
        }
        
        do {
            try modelContext.save()
            modelContext.insert(server)
            dismiss()
        } catch {
            errorMessage = "SavingError"
        }
    }
}
