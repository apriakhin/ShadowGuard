//
//  StatusView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI

struct StatusView: View {
    var status: Status
    
    private var dotColor: Color {
        switch status {
        case .connected, .disconnecting:
            #if os(iOS)
            return Color(uiColor: .systemGreen)
            #else
            return Color(nsColor: .systemGreen)
            #endif
        default:
            #if os(iOS)
            return Color(uiColor: .systemRed)
            #else
            return Color(nsColor: .systemRed)
            #endif
        }
    }
    
    private var statusText: LocalizedStringResource {
        switch status {
        case .disconnected:
            "NotConnected"
        case .connecting:
            "Connecting"
        case .connected:
            "Connected"
        case .reasserting:
            "Reasserting"
        case .disconnecting:
            "Disconnecting"
        default:
            "NotConnected"
        }
    }

    var body: some View {
        Text(statusText)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                    .offset(x: -14)
            }
    }
}

#Preview {
    StatusView(status: .connected)
}
