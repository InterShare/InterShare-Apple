//
//  InterShareApp.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

import SwiftUI

#if os(macOS)
import os

extension Notification.Name {
    static let receivedURLsNotification = Notification.Name("ReceivedURLsNotification")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        Task {
            let contentViewModel = await ContentViewModel()
            let discovery = DiscoveryService()
            var urlStrings: [String] = []
            
            for url in urls {
                urlStrings.append(url.path().removingPercentEncoding!)
                let _ = url.startAccessingSecurityScopedResource()
            }
            
            let popupWindow = ShareWindow(nearbyServer: contentViewModel.nearbyServer!, urls: urlStrings, clipboard: nil, discovery: discovery)
            popupWindow.showWindow()
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let app = notification.object as? NSApplication else {
            fatalError("no application object")
        }
        
        let window = app.windows.first
        window?.titlebarAppearsTransparent = true
    }
}
#endif

@main
struct InterShareApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif
    
    var body: some Scene {
#if os(macOS)
        MenuBarExtra("InterShare", image: "MenuIcon") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
#else
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
#endif
    }
}
