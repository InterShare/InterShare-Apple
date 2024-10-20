//
//  BluetoothDisabledWarningView.swift
//  InterShare
//
//  Created by Julian Baumann on 20.10.24.
//
import SwiftUI

struct BluetoothDisabledWarningView: View {
    var body: some View {
        HStack() {
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.red)
            VStack {
                Text("Enable Bluetooth to use InterShare")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bold()
                    .padding(.bottom, 0)
                    .font(.system(size: 14))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .padding()
    }
}

#Preview {
    BluetoothDisabledWarningView()
}
