//
//  ContentViewModel.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import DataRCT
import PhotosUI
import SwiftUI

class ContentViewModel: ObservableObject, NearbyServerDelegate {
    private var incomingThread: Thread?
    private var myDevice: Device?
    private var temporaryDirectory: URL = FileManager.default.temporaryDirectory
#if os(macOS)
    public var documentsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
#else
    public var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
#endif
    public var nearbyServer: NearbyServer?
    public var shouldDeleteSelectedFileAfterwards = false

    @Published public var advertisementEnabled = false
    @Published public var isPoweredOn = false
    @Published public var selectedFileURL: String?
    @Published public var showDeviceSelectionSheet = false
    @Published public var showConnectionRequestDialog = false
    @Published public var currentConnectionRequest: ConnectionRequest?
    @Published public var showDeviceNamingAlert = false
    @Published public var namingSaveButtonDisabled = false
    @Published public var showReceivingDialog = false
    @Published public var receiveProgress: ReceiveProgress?
    
    
    @Published public var deviceName: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.namingSaveButtonDisabled = self.deviceName.count < 3
            }
        }
    }

    @Published public var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                getURL(item: imageSelection) { result in
                    switch result {
                    case .success(let data):
                        self.shouldDeleteSelectedFileAfterwards = true
                        self.selectedFileURL = data.path
                        self.showDeviceSelectionSheet = self.selectedFileURL != nil
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
    
    func initializeServer(deviceName: String) {
        self.deviceName = deviceName
        var deviceId = UserDefaults.standard.string(forKey: "deviceIdentifier")
        
        if deviceId == nil {
            deviceId = UUID().uuidString
            UserDefaults.standard.set(deviceId, forKey: "deviceIdentifier")
        }

        var deviceType = DeviceType.unknown
        
#if os(iOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        
        if idiom == .pad {
            deviceType = .tablet
        } else if idiom == .phone {
            deviceType = .mobile
        } else if idiom == .mac {
            deviceType = .mobile
        }
#else
        deviceType = .desktop
#endif

        myDevice = Device(
            id: deviceId!,
            name: deviceName,
            deviceType: deviceType.rawValue
        )
        
        let storageURL = documentsDirectory.path
        
        nearbyServer = NearbyServer(myDevice: myDevice!, storage: storageURL, delegate: self)
    }
    
    public func saveName() {
        if deviceName.count < 3 {
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
            try nearbyServer?.stop()
        } catch {
            print(error)
        }
    }
    
    func nearbyServerDidUpdateState(state: BluetoothState) {
        isPoweredOn = state == .poweredOn
        advertisementEnabled = isPoweredOn

        changeAdvertisementState()
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
                    try nearbyServer?.stop()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func receivedConnectionRequest(request: ConnectionRequest) {
        if self.showDeviceNamingAlert || self.showDeviceSelectionSheet || self.showConnectionRequestDialog || self.showConnectionRequestDialog {
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
                if shouldDeleteSelectedFileAfterwards, let selectedFileURL {
                    try FileManager.default.removeItem(atPath: selectedFileURL)
                }
                else if !shouldDeleteSelectedFileAfterwards, let selectedFileURL {
                    NSURL(string: selectedFileURL)?.stopAccessingSecurityScopedResource()
                }
            } catch {
                print(error)
            }
        }
    }
}
