//
//  SelectButton.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI

enum SelectButtonType {
    case add
    case select
    case selected(String)
}

struct SelectButton: View {
    var type: SelectButtonType
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                switch type {
                case .add:
                    Image(systemName: "plus")
                    
                    Text("AddServer")
                    
                case .select:
                    Text("SelectServer")
                    
                    Image(systemName: "chevron.right")
                    
                case let .selected(serverTitle):
                    Text(serverTitle)
                    
                    Image(systemName: "chevron.down")
                }
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}

#Preview {
    SelectButton(type: .selected("My server"), action: {})
}
