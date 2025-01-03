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
                        .frame(width: 7, height: 7)
                        .padding(10)
                        .foregroundStyle(isActivated ? .white : Color(NSColor.textColor).opacity(0.8))
                        .background(
                            ZStack {
                                if isActivated {
                                    Color(NSColor.controlAccentColor)
                                } else {
                                    RoundedRectangle(cornerRadius: 5)
                                        .background(Material.ultraThinMaterial)
                                        .opacity(0.2)
                                }
                            }
                        )
                        .clipShape(Capsule())
                }
                
                Text(label)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(isHovered ? Material.thinMaterial : Color.clear)
            .background(
                ZStack {
                    if isHovered {
                        RoundedRectangle(cornerRadius: 5)
                            .background(Material.ultraThinMaterial)
                            .opacity(0.2)
                    } else {
                        Color.clear
                    }
                }
            )
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
