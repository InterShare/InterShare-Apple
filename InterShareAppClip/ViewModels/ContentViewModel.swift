//
//  ContentViewModel.swift
//  InterShareAppClip
//
//  Created by Julian Baumann on 26.01.25.
//

import Foundation
import InterShareKit

public class ContentViewModel: ObservableObject, NearbyServerDelegate {
    public var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var nearbyServer: NearbyServer?
    
    public func nearbyServerDidUpdateState(state: InterShareKit.BluetoothState) {
        
    }
    
    public func receivedConnectionRequest(request: InterShareKit.ConnectionRequest) {
        Task {
            let _ = request.accept()
        }
    }
    
    public func startServer(link: String) async {
        do {
            var device = Device(id: UUID().uuidString, name: "", deviceType: 0)
            self.nearbyServer = NearbyServer(myDevice: device, storage: documentsDirectory.path, delegate: self)
            try await nearbyServer?.requestDownload(link: link)
        } catch {
            print(error)
        }
    }
}
