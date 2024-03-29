//
//  CircularProgressView.swift
//  InterShare
//
//  Created by Julian Baumann on 26.02.24.
//

import SwiftUI

struct CircularProgressView: View {
    public var progress: Double
    public var color: Color
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .animation(.easeOut, value: progress)
            .animation(.easeOut, value: color)
            .frame(width: 70, height: 70)
    }
}

#Preview {
    CircularProgressView(progress: 0.3, color: .purple)
}
