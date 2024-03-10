//
//  VisualEffectView.swift
//  InterShare
//
//  Created by Julian Baumann on 07.03.24.
//
#if os(macOS)

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()

        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .underWindowBackground

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

#endif
