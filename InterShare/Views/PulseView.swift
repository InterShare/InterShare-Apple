//
//  PulseView.swift
//  InterShare
//
//  Created by Julian Baumann on 20.01.24.
//

import SwiftUI

struct PulseView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<6) { index in
                pulseRing(delay: Double(index) * 1.0)
            }
        }
        .onAppear {
            animate = true
        }
    }

    private func pulseRing(delay: Double) -> some View {
        Circle()
            .stroke(lineWidth: 1.0)
            .foregroundColor(.gray)
            .frame(width: animate ? 500 : 0, height: animate ? 500 : 0) // Change the frame size instead of scale
            .opacity(animate ? 0 : 1)
            .animation(Animation.easeInOut(duration: 6)
                .repeatForever(autoreverses: false)
                .delay(delay), value: animate)
    }
}



#Preview {
    PulseView()
}
