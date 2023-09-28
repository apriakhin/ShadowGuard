//
//  ToggleButton.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.09.2023.
//

import SwiftUI

struct ToggleButton: View {
    var status: Status
    var action: () -> Void
    
    private var isAnimating: Bool {
        status == .connected || status == .disconnecting
    }
    
    var body: some View {
        ZStack {
            PulsationView(isAnimating: isAnimating)
            
            Button(action: action) {
                VStack {
                    Image(systemName: "power")
                        .resizable()
                        .frame(width: 32, height: 32)
                        #if os(iOS)
                        .foregroundColor(Color(uiColor: .systemGray6))
                        #else
                        .foregroundColor(Color(nsColor: .windowBackgroundColor))
                        #endif
                }
                .frame(width: LocalConstants.width, height: LocalConstants.height)
                .background(LocalConstants.color)
                .cornerRadius(LocalConstants.width / 2)
                
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ToggleButton(status: .connected, action: {})
}

// MARK: - Private

private enum LocalConstants {
    static var duration: Double { 6.0 }
    static var width: Double { 140.0 }
    static var height: Double { 140.0 }
    static var color: Color { .accentColor }
}

private struct PulsationView: View {
    var isAnimating: Bool

    @State private var animationProcess1 = false
    @State private var animationProcess2 = false
    @State private var animationProcess3 = false
    
    @State private var timer1: Timer?
    @State private var timer2: Timer?

    internal init(isAnimating: Bool) {
        self.isAnimating = isAnimating
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(LocalConstants.color)
                .frame(width: LocalConstants.width, height: LocalConstants.height)
                .pulsation(isAnimating: animationProcess1, duration: LocalConstants.duration)
            
            Circle()
                .fill(LocalConstants.color)
                .frame(width: LocalConstants.width, height: LocalConstants.height)
                .pulsation(isAnimating: animationProcess2, duration: LocalConstants.duration)
            
            Circle()
                .fill(LocalConstants.color)
                .frame(width: LocalConstants.width, height: LocalConstants.height)
                .pulsation(isAnimating: animationProcess3, duration: LocalConstants.duration)
        }
        .onChange(of: isAnimating, initial: false) {
            if isAnimating {
                startRepeating()
            } else {
                stopRepeating()
            }
        }
    }
    
    private func startRepeating() {
        animationProcess1 = true
        
        timer1 = Timer.scheduledTimer(withTimeInterval: LocalConstants.duration / 3, repeats: false) { _ in
            animationProcess2 = true
        }
        
        timer2 = Timer.scheduledTimer(withTimeInterval: LocalConstants.duration * 2/3, repeats: false) { _ in
            animationProcess3 = true
        }
    }
    
    private func stopRepeating() {
        animationProcess1 = false
        animationProcess2 = false
        animationProcess3 = false
        
        timer1?.invalidate()
        timer2?.invalidate()
    }
}

private struct PulsationValue {
    var scale = 1.0
    var opacity = 1.0
}

private struct PulsationModifier: ViewModifier {
    var isAnimating: Bool
    var duration: Double
    
    func body(content: Content) -> some View {
        if isAnimating {
            content
                .keyframeAnimator(initialValue: PulsationValue(), repeating: true) { view, value in
                    view
                        .scaleEffect(x: value.scale, y: value.scale)
                        .opacity(value.opacity)
                    
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        LinearKeyframe(1.5, duration: duration, timingCurve: .circularEaseOut)
                    }
                    
                    KeyframeTrack(\.opacity) {
                        LinearKeyframe(0, duration: duration, timingCurve: .circularEaseOut)
                    }
                }
        } else {
            content
        }
    }
}

fileprivate extension View {
    func pulsation(isAnimating: Bool, duration: Double) -> some View {
        self.modifier(PulsationModifier(isAnimating: isAnimating, duration: duration))
    }
}
