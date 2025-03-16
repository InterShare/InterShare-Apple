//
//  InterShareAppClipApp.swift
//  InterShareAppClip
//
//  Created by Julian Baumann on 26.01.25.
//

import SwiftUI
import InterShareKit

@main
struct InterShareAppClipApp: App {
    let contentViewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contentViewModel)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)

        }
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else {
            return
        }
        
        print("URL: \(incomingURL.absoluteString)")

        Task {
            await contentViewModel.startServer(link: incomingURL.absoluteString)
        }
    }
}
