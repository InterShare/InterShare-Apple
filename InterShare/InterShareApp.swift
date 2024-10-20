//
//  InterShareApp.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

import SwiftUI

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
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
        }.menuBarExtraStyle(.window)
#else
        WindowGroup {
            NavigationStack {
                ContentView()
                    .toolbar {
                        Color.clear
                    }
            }
        }
#endif
        
//        WindowGroup {
//            NavigationStack {
//                ContentView()
//                    .toolbar {
//                        Color.clear
//                    }
//            }
//        }
//#if os(macOS)
//        .windowToolbarStyle(UnifiedWindowToolbarStyle())
//        .windowResizability(.contentSize)
//        .windowStyle(.hiddenTitleBar)
//#endif
    }
}
