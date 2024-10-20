//
//  MenuButtonView.swift
//  InterShare
//
//  Created by Julian Baumann on 21.10.24.
//

#if os(macOS)

import SwiftUI

struct MenuButtonView: View {
    var label: String
    var action: () -> Void
    @State private var isHovered: Bool = false
    
    init(_ label: String, _ action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(label)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovered ? Color(NSColor.controlAccentColor) : Color.clear)
            .foregroundColor(isHovered ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {}

#endif
