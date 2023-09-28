//
//  EditServerView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI

struct EditServerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var isShowingAlert = false
    
    var server: Server
    
    private var isValid: Bool {
        !title.isEmpty
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
                }
            }
            .navigationTitle("EditServer")
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
                    Button(action: save) {
                        Text("Save")
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                title = server.title
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
    
    private func save() {
        server.setValue(forKey: \.title, to: title)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            isShowingAlert = true
        }
    }
}
