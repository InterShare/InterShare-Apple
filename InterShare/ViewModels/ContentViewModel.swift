//
//  ContentViewModel.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import Foundation
import DataRCT
import PhotosUI
import SwiftUI

#if os(iOS)
import UIKit
#endif

class ContentViewModel: ObservableObject, NearbyServerDelegate, DiscoveryDelegate {
    private var incomingThread: Thread?
    private var nearbyServer: NearbyServer?
    private var discovery: Discovery?

    @Published public var discoveredDevices: [Device] = []
    @Published public var advertisementEnabled = false
    @Published public var sheetOpened: Bool = false
    @Published public var fakeSheetOpened: Bool = true
    @Published public var clickedDevice: Device?
    @Published public var isPoweredOn: Bool = false
    @Published public var deviceName: String = "iPhone"

    @Published public var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                getURL(item: imageSelection) { result in
                    switch result {
                    case .success(let data):
                        print(result)
                        Task {
                            do {
                                try await self.nearbyServer?.sendFile(to: self.clickedDevice!, url: data.path)
                            } catch {
                                print(error)
                            }
                        }
                    case .failure(_):
                        print("Failed")
                    }
                }
            } else {
            }
        }
    }
    
    func getURL(item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
       // Step 1: Load as Data object.
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let contentType = item.supportedContentTypes.first {
                   // Step 2: make the URL file name and a get a file extention.
                    let url = ContentViewModel.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")
                    if let data = data {
                        do {
                           // Step 3: write to temp App file directory and return in completionHandler
                            try data.write(to: url)
                            completionHandler(.success(url))
                        } catch {
                            completionHandler(.failure(error))
                        }
                    }
                }
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }

    /// from: https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
    static func getDocumentsDirectory() -> URL {
       // find all possible documents directories for this user
       let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

       // just send back the first one, which ought to be the only one
       return paths[0]
    }
    
    init() {
        var deviceName = "Swift DataRCT"
        var deviceType = ""

#if os(iOS)
        deviceName = UIDevice.current.name
        deviceType = "phone, apple"
#elseif os(macOS)
        deviceType = "computer, apple"
#endif
        do {
            
            let ipAddress = getIpAddress() ?? ""
            print("IP: \(ipAddress)")
            
            var device = Device(
                id: UUID().uuidString,
                name: deviceName,
                deviceType: 0
            )
            
            let storageURL = ContentViewModel.getDocumentsDirectory().path
            
            nearbyServer = NearbyServer(myDevice: device, storage: storageURL, delegate: self)
            discovery = try Discovery(delegate: self)
        } catch {
            print("Error! \(error)")
        }
    }
    
    func nearbyServerDidUpdateState(state: BluetoothState) {
        isPoweredOn = state == .poweredOn
    }
    
    func discoveryDidUpdateState(state: BluetoothState) {
        if state == .poweredOn {
            do {
                try discovery?.startScan()
            }
            catch {
                print(error)
            }
        }
    }
    
    func deviceAdded(value: DataRCT.Device) {
        DispatchQueue.main.async {
            self.discoveredDevices.append(value)
        }
    }
    
    func deviceRemoved(deviceId: String) {
        DispatchQueue.main.async {
            self.discoveredDevices.removeAll { $0.id == deviceId }
        }
    }
    
    func changeAdvertisementState() {
        if nearbyServer?.state != .poweredOn {
            return
        }
        
        do {
            if advertisementEnabled {
                let device = Device(
                    id: UUID().uuidString,
                    name: deviceName,
                    deviceType: 0
                )
                
                nearbyServer?.changeDevice(device)
//                    try await nearbyServer?.start()
                
                Task {
                    try await self.nearbyServer?.start()
                }
            } else {
                Task {
                    try await nearbyServer?.stop()
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    public func connect(to device: Device) {
        Task {
//            await nearbyServer?.connect(device)
        }
//        do {
//            let connection = try _transmission?.connectToDevice(recipient: device)
//            let result = try connection?.writeBytes(buffer: Array("Hello, World".utf8))
//            print(result)
//        } catch {
//            print(error)
//        }
    }
    
    func receivedConnectionRequest(request: DataRCT.ConnectionRequest) {
        request.accept()
    }
}
