//
//  ReadyToReceiveView.swift
//  InterShare
//
//  Created by Julian Baumann on 20.10.24.
//

import SwiftUI

struct ReadyToReceiveView: View {
    var body: some View {
        HStack() {
            Image(systemName: "checkmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.green)
            VStack {
                Text("Ready to receive")
                    .foregroundStyle(.green)
                    .bold()
                    .padding(.trailing, 5)
            }
        }
        .padding(5)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
#if os(iOS)
        .safeAreaPadding(.vertical)
#endif
    }
}

#Preview {
    ReadyToReceiveView()
}
