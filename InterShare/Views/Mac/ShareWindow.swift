#if os(macOS)
import SwiftUI
import AppKit
import InterShareKit

class ShareWindow: NSWindowController {
    init(nearbyServer: NearbyServer, urls: [String], clipboard: String?, discovery: DiscoveryService) {
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
        let windowSize = CGSize(width: 500, height: 400)

        let window = NSWindow(
            contentRect: NSRect(
                x: (screenSize.width - windowSize.width) / 2,
                y: (screenSize.height - windowSize.height) / 2,
                width: windowSize.width,
                height: windowSize.height
            ),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let visualEffectView = NSVisualEffectView()
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        window.contentView = visualEffectView

        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovable = false
        
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        window.level = .floating
        

        let view =
        ShareSheetView(nearbyServer: nearbyServer, urls: urls, clipboard: clipboard, close: {
                window.close()
                discovery.close()
            })
            .environmentObject(discovery)
        
        let hostingView = NSHostingView(rootView: view)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(hostingView)
//
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor)
        ])

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindow() {
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeWindow() {
        self.window?.close()
    }
}
#endif
