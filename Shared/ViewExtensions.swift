//
//  ViewExtensions.swift
//  InterShare
//
//  Created by Julian Baumann on 08.02.25.
//

import SwiftUI

struct CustomGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content.glassEffect()
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.glassEffect()
        }
#endif
        
        return content
    }
}

struct CustomRoundedGlassCardEffect: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content.glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.glassEffect(in: .rect(cornerRadius: 16))
        }
#endif
        
        return content
            .background(.thinMaterial)
            .cornerRadius(15)
    }
}

struct CustomGlassCardEffect: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content.glassEffect()
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.glassEffect()
        }
#endif
        
        return content
            .background(.regularMaterial)
            .cornerRadius(15)
    }
}

struct CustomGlassButtonEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#endif
        
        return content.buttonStyle(.bordered)
    }
}

struct CustomGlassButtonWithBorderEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#endif
        
        return content.buttonStyle(.bordered)
    }
}

struct ShareButtonGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content
                .padding(10)
                .glassEffect(.regular.tint(Color("ButtonTint").opacity(0.9)).interactive(), in: .rect(cornerRadius: 25))
                .foregroundStyle(Color("ButtonTextColor"))
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#endif

        return content
            .buttonStyle(.borderedProminent)
#if os(iOS)
            .buttonBorderShape(.roundedRectangle(radius: 25))
#endif
            .tint(Color("ButtonTint"))
            .foregroundStyle(Color("ButtonTextColor"))
    }
}

struct SecondaryButtonGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content
                .buttonStyle(.glass)
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glass)
        }
#endif

        return content
            .buttonStyle(.bordered)
#if os(iOS)
            .buttonBorderShape(.capsule)
#endif
            .tint(Color("ReceivedFilesTint"))
    }
}

struct ProminentButtonGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content
                .buttonStyle(.glassProminent)
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glassProminent)
        }
#endif

        return content
            .buttonStyle(.borderedProminent)
#if os(iOS)
            .buttonBorderShape(.capsule)
#endif
            .tint(Color("ButtonTint"))
            .foregroundStyle(Color("ButtonTextColor"))
    }
}

struct DestructiveButtonGlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        
#if os(iOS)
        if #available(iOS 26.0, *) {
            return content
                .padding(10)
                .glassEffect(.regular.tint(.red.opacity(0.6)).interactive(), in: .capsule)
                .foregroundStyle(.white)
        }
#elseif os(macOS)
        if #available(macOS 26.0, *) {
            return content.buttonStyle(.glassProminent)
        }
#endif

        return content
            .buttonStyle(.bordered)
#if os(iOS)
            .buttonBorderShape(.capsule)
#endif
            .tint(.red)
    }
}


extension View {
    public func applySafeAreaPadding() -> some View {
#if os(iOS)
        if #available(iOS 17.0, *) {
            return self.safeAreaPadding(.vertical)
        } else {
            return self.padding(.bottom, 20)
        }
#else
        return self
#endif
    }
    
    func glassEffectIfCompatible() -> some View {
        modifier(CustomGlassEffect())
    }
    
    func glassEffectCard() -> some View {
        modifier(CustomGlassCardEffect())
    }
    
    func glassEffectRectCard() -> some View {
        modifier(CustomRoundedGlassCardEffect())
    }
    
    func glassButtonStyle() -> some View {
        modifier(CustomGlassButtonEffect())
    }
    
    func shareButtonStyle() -> some View {
        modifier(ShareButtonGlassEffect())
    }
    
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonGlassEffect())
    }
    
    func prominentButtonStyle() -> some View {
        modifier(ProminentButtonGlassEffect())
    }
    
    func destructiveButtonStyle() -> some View {
        modifier(DestructiveButtonGlassEffect())
    }
}
