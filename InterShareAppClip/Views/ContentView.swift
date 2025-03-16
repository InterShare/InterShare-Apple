//
//  ContentView.swift
//  InterShareAppClip
//
//  Created by Julian Baumann on 26.01.25.
//

import SwiftUI
import FluidGradient

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            FluidGradient(blobs: [.red, .green, .blue],
                          highlights: [.purple, .cyan, .blue],
                          speed: 0.3,
                          blur: 0.75)

            VStack(alignment: .center) {
                Text("Conneting to device...")
                    .bold()
                    .font(.largeTitle)
                    .opacity(0.5)
                
                Text("Make sure the device is still running the InterShare App and is close by.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .opacity(0.5)
            }
            .padding()
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
