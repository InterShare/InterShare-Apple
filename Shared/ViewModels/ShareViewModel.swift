//
//  DeviceInfoListView.swift
//  InterShare
//
//  Created by Julian Baumann on 25.01.24.
//

import Foundation
import InterShareKit
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class SendProgress: SendProgressDelegate, ObservableObject {
    @Published var state: SendProgressState = SendProgressState.unknown
    @Published var medium: ConnectionMedium?
    
    func progressChanged(progress: SendProgressState) {
        DispatchQueue.main.async {
            if case .connectionMediumUpdate(let medium) = progress {
                print("Updated to \(medium)")
                self.medium = medium
            }
            
            self.state = progress
        }
    }
}

class ShareProgress: ShareProgressDelegate, ObservableObject {
    @Published var state: ShareProgressState = ShareProgressState.unknown
    @Published var isReady: Bool = false
    
    func progressChanged(progress: ShareProgressState) {
        DispatchQueue.main.async {
            self.state = progress
            self.isReady = (progress == .finished)
            
            print("Progress Updated: \(progress), Ready: \(self.isReady)")
        }
    }
}

class ShareViewModel: ObservableObject, ShareProgressDelegate {
    private let nearbyServer: NearbyServer
    private let urls: [String]
    private var text: String = ""
    private var shareStore: ShareStore? = nil
    @Published public var showIncompatibleMessage: Bool = false
    @Published public var incompatibleVersionMessage: String?
    @Published var state: ShareProgressState = ShareProgressState.unknown
    @Published var isReady: Bool = false
    
    func progressChanged(progress: ShareProgressState) {
        DispatchQueue.main.async {
            self.state = progress
            self.isReady = (progress == .finished)

            print("Progress Updated: \(progress), Ready: \(self.isReady)")
        }
    }
    
    init(nearbyServer: NearbyServer, urls: [String]) {
        self.nearbyServer = nearbyServer
        self.urls = urls
        self.state = .unknown
        self.isReady = false
        
        Task {
            self.shareStore = await self.nearbyServer.share(urls: urls, allowConvenienceShare: false, progress: self)
        }
    }
    
    init(nearbyServer: NearbyServer, text: String) {
        self.nearbyServer = nearbyServer
        self.urls = []
        self.text = text
        self.state = .unknown
        self.isReady = true
        
        Task {
            self.shareStore = await self.nearbyServer.share(text: text, allowConvenienceShare: false)
        }
    }

    public func send(device: Device, progress: SendProgress) {
        let versionCompatibility = isCompatible(device: device)
        
        if versionCompatibility != .compatible {
            
            if versionCompatibility == .outdatedVersion {
                incompatibleVersionMessage = "\"\(device.name)\" is using an outdated version of InterShare. \"\(device.name)\" needs to update to the latest InterShare version."
            } else {
                incompatibleVersionMessage = "Your version of InterShare is outdated. Please update to the latest version."
            }
            
            showIncompatibleMessage = true
            
            return
        }
        
        
        Task {
            do {
                try await self.shareStore?.sendTo(receiver: device, progressDelegate: progress)
            } catch {
                print(error)
            }
        }
    }
#if os(iOS)
    public func getQRCode(darkMode: Bool) -> UIImage? {
        let rawData = shareStore?.generateQrCode(darkMode: darkMode)
        
        guard let rawData = rawData else {
            return nil
        }
        

        let data = Data(rawData)
        
        return UIImage(data: data)
    }
#elseif os(macOS)
    public func getQRCode(darkMode: Bool) -> NSImage? {
        let rawData = shareStore?.generateQrCode(darkMode: darkMode)
        
        guard let rawData = rawData else {
            return nil
        }
        
        
        let data = Data(rawData)

        return NSImage(data: data)
    }
#endif
}
