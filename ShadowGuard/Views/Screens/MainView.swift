//
//  MainView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(MainViewModel.self) var viewModel: MainViewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack {
                VStack(spacing: 0) {
                    TimerView(connectedDate: viewModel.connectedDate)
                    
                    StatusView(status: viewModel.status)
                        .padding(.top, 16)
                }
                .frame(maxHeight: .infinity)
                
                ToggleButton(
                    status: viewModel.status,
                    action: viewModel.didTapToggleButton
                )
                .disabled(viewModel.toggleButtonDisabled)
                
                VStack {
                    SelectButton(
                        type: viewModel.selectButtonType,
                        action: viewModel.didTapSelectButton
                    )
                    .disabled(viewModel.selectButtonDisabled)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("AppName")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: .systemGray6))
            #else
            .background(Color(nsColor: .windowBackgroundColor))
            #endif
            .toolbar {
                ToolbarItem {
                    Button(action: viewModel.didTapAboutButton) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddServer, onDismiss: viewModel.didDismissAddServer) {
                AddServerView(accessKey: viewModel.accessKey, isModal: true)
            }
            .sheet(isPresented: $viewModel.isShowingServerList) {
                ServerListView()
            }
            .sheet(isPresented: $viewModel.isShowingAbout) {
                AboutView()
            }
            .onOpenURL(perform: viewModel.didOpenURL)
        }
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        #if os(macOS)
        .frame(width: 320, height: 480)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
}
