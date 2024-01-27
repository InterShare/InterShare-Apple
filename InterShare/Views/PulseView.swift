//
//  PulseView.swift
//  InterShare
//
//  Created by Julian Baumann on 20.01.24.
//

import SwiftUI

struct PulseView: View {
    @State private var animate = false
    @State private var currentSize: CGSize?

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
            .frame(width: animate ? UIScreen.main.bounds.width : 0, height: animate ? UIScreen.main.bounds.width : 0)
            .position(x: UIScreen.main.bounds.width / 2, y: 0)
            .opacity(animate ? 0 : 1)
            .animation(Animation.easeInOut(duration: 6)
                        .repeatForever(autoreverses: false)
                        .delay(delay), value: animate)
    }
}


#Preview {
    NavigationStack {
        VStack {
            PulseView()
                .padding(.top)

            VStack {
                Text("Share")
                    .opacity(0.7)
                    .bold()
                    .padding(50)
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .navigationTitle("InterShare")
        }
    }
}
