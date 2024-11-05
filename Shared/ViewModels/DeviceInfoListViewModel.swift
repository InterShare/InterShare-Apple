//
//  DeviceInfoListView.swift
//  InterShare
//
//  Created by Julian Baumann on 25.01.24.
//

import Foundation
import InterShareKit

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

class DeviceInfoListViewModel: ObservableObject {
    private let nearbyServer: NearbyServer
    private let urls: [String]
    
    init(nearbyServer: NearbyServer, urls: [String]) {
        self.nearbyServer = nearbyServer
        self.urls = urls
    }

    public func send(device: Device, progress: SendProgress) {
        Task {
            do {
                try await self.nearbyServer.send(urls: urls, to: device, progress: progress)
            } catch {
                print(error)
            }
        }
    }
}
