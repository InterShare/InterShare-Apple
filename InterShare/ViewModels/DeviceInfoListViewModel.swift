//
//  DeviceInfoListView.swift
//  InterShare
//
//  Created by Julian Baumann on 25.01.24.
//

import Foundation
import DataRCT

class SendProgress: SendProgressDelegate, ObservableObject {
    @Published var state: SendProgressState = SendProgressState.unknown
    
    func progressChanged(progress: SendProgressState) {
        DispatchQueue.main.async {
            self.state = progress
        }
    }
}

class DeviceInfoListViewModel: ObservableObject {
    private let nearbyServer: NearbyServer
    private let imageURL: String
    
    init(nearbyServer: NearbyServer, imageURL: String) {
        self.nearbyServer = nearbyServer
        self.imageURL = imageURL
    }

    public func send(device: Device, progress: SendProgress) {
        Task {
            do {
                try await self.nearbyServer.sendFile(to: device, url: imageURL, progress: progress)
            } catch {
                print(error)
            }
        }
    }
}
