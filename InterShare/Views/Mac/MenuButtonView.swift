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
    var icon: String?
    var hightlightColor: Color
    @State private var isHovered: Bool = false
    @Binding var isActivated: Bool
    
    init(_ label: String,
         icon: String? = nil,
         isActivated: Binding<Bool> = .constant(false),
         hightlightColor: Color = Color(NSColor.controlAccentColor).opacity(0.7),
         _ action: @escaping () -> Void) {
        self.label = label
        self.action = action
        self.icon = icon
        self._isActivated = isActivated
        self.hightlightColor = hightlightColor
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .frame(width: 5, height: 5)
                        .padding(10)
                        .background(isActivated ? Color(NSColor.controlAccentColor) : Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                }
                
                Text(label)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovered ? hightlightColor : Color.clear)
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
