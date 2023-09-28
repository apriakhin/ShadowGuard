//
//  TimerView.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI

struct TimerView: View {
    var connectedDate: Date?
    
    var body: some View {
        if let connectedDate {
            Text(connectedDate, style: .timer)
                .font(.largeTitle)

        } else {
            Text("0:00")
                .font(.largeTitle)
        }
    }
}

#Preview {
    TimerView()
}
