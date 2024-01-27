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

class ContentViewModel: ObservableObject, NearbyServerDelegate {
    private var incomingThread: Thread?
    private var myDevice: Device?
    private var temporaryDirectory: URL = FileManager.default.temporaryDirectory
    public var nearbyServer: NearbyServer?

    @Published public var advertisementEnabled = false
    @Published public var isPoweredOn: Bool = false
    @Published public var selectedImageURL: String?
    @Published public var showDeviceSelectionSheet: Bool = false
    @Published public var showConnectionRequestDialog: Bool = false
    @Published public var currentConnectionRequest: ConnectionRequest?
    @Published public var showDeviceNamingAlert: Bool = false
    @Published public var namingSaveButtonDisabled: Bool = true
    
    @Published public var deviceName: String = ""

    @Published public var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                getURL(item: imageSelection) { result in
                    switch result {
                    case .success(let data):
                        self.selectedImageURL = data.path
                        self.showDeviceSelectionSheet = self.selectedImageURL != nil
                        DispatchQueue.main.async {
                            self.imageSelection = nil
                        }
                    case .failure(_):
                        print("Failed")
                    }
                }
            } else {
            }
        }
    }
    
    init() {
        let deviceName = UserDefaults.standard.string(forKey: "deviceName")

        guard let deviceName else {
            DispatchQueue.main.async {
                self.showDeviceNamingAlert = true
            }
            return
        }
        
        initializeServer(deviceName: deviceName)
    }
    
    func getURL(item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let contentType = item.supportedContentTypes.first {

                    if let data = data {
                        do {
                            let url = self.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")

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
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func initializeServer(deviceName: String) {
        self.deviceName = deviceName
        var deviceId = UserDefaults.standard.string(forKey: "deviceIdentifier")
        
        if deviceId == nil {
            deviceId = UUID().uuidString
            UserDefaults.standard.set(deviceId, forKey: "deviceIdentifier")
        }
        
        let idiom = UIDevice.current.userInterfaceIdiom
        var deviceType = DeviceType.unknown
        
        if idiom == .pad {
            deviceType = .tablet
        } else if idiom == .phone {
            deviceType = .mobile
        } else if idiom == .mac {
            deviceType = .mobile
        }

        myDevice = Device(
            id: deviceId!,
            name: deviceName,
            deviceType: deviceType.rawValue
        )
        
        let storageURL = ContentViewModel.getDocumentsDirectory().path
        
        nearbyServer = NearbyServer(myDevice: myDevice!, storage: storageURL, delegate: self)
    }
    
    public func saveName() {
        if deviceName.count < 3 {
            showDeviceNamingAlert = true
            return
        }
        
        UserDefaults.standard.set(deviceName, forKey: "deviceName")

        if let nearbyServer, var myDevice {
            myDevice.name = deviceName
            nearbyServer.changeDevice(myDevice)
        } else {
            initializeServer(deviceName: deviceName)
        }
    }

    func stopServer() async {
        do {
            try await nearbyServer?.stop()
        } catch {
            print(error)
        }
    }
    
    func nearbyServerDidUpdateState(state: BluetoothState) {
        isPoweredOn = state == .poweredOn
        advertisementEnabled = isPoweredOn
    }
    
    func changeAdvertisementState() {
        if nearbyServer?.state != .poweredOn {
            return
        }

        Task {
            do {
                if advertisementEnabled {
                    try await self.nearbyServer?.start()
                } else {
                    try await nearbyServer?.stop()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func receivedConnectionRequest(request: ConnectionRequest) {
        if self.showDeviceNamingAlert || self.showDeviceSelectionSheet || self.showConnectionRequestDialog {
            request.decline()
            return
        }

        DispatchQueue.main.async {
            self.currentConnectionRequest = request
            self.showConnectionRequestDialog = true
        }
    }
    
    public func onDeviceListSheetDismissed() {
        Task {
            do {
                if let selectedImageURL {
                    try FileManager.default.removeItem(atPath: selectedImageURL)
                }
            } catch {
                print(error)
            }
        }
    }
}
