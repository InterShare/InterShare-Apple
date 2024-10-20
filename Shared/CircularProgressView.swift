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
    public var thickness: CGFloat = 3
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: thickness,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .animation(.easeOut, value: progress)
            .animation(.easeOut, value: color)
    }
}

#Preview {
    CircularProgressView(progress: 0.3, color: .purple)
}
