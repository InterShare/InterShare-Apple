//
//  ContentViewModel.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import DataRCT
import PhotosUI
import SwiftUI
#if os(macOS)
import DynamicNotchKit
#endif

class ContentViewModel: ObservableObject, NearbyServerDelegate {
    private var incomingThread: Thread?
    private var myDevice: Device?

#if os(macOS)
    let userDefaults = UserDefaults(suiteName: "PBYG8F53RH.com.julian-baumann.InterShare")!
    public var documentsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
#else
    let userDefaults = UserDefaults(suiteName: "group.com.julian-baumann.InterShare")!
    public var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
#endif

    public var nearbyServer: NearbyServer?
    public var shouldDeleteSelectedFileAfterwards = false

    @Published public var advertisementEnabled = false
    @Published public var isPoweredOn = true
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
                getURL(photo: imageSelection) { result in
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
        let deviceName = userDefaults.string(forKey: "deviceName")

        guard let deviceName else {
            DispatchQueue.main.async {
#if os(macOS)
                self.showDeviceNamingAlertOnMac()
#else
                self.showDeviceNamingAlert = true
#endif
            }
            return
        }
        
        Task {
            await initializeServer(deviceName: deviceName)
        }
    }
    
#if os(macOS)
    func showDeviceNamingAlertOnMac() {
        let alert = NSAlert()
        alert.messageText = "Name this device"
        alert.informativeText = "Nearby devices will discover this device using this name, which must be at least three characters long."
        alert.alertStyle = .informational
        
        // Add a text field for the device name
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        textField.placeholderString = "Device name"
        textField.stringValue = deviceName
        alert.accessoryView = textField
        alert.addButton(withTitle: "Save")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            if (textField.stringValue.count < 3) {
                showDeviceNamingAlertOnMac()
                return
            }
            
            deviceName = textField.stringValue
            saveName()
        }
    }
#endif
    
    func initializeServer(deviceName: String) async {
        self.deviceName = deviceName
        var deviceId = userDefaults.string(forKey: "deviceIdentifier")
        let askedForLocalNetworkPermission = userDefaults.bool(forKey: "askedForLocalNetworkPermission")
        
        if (askedForLocalNetworkPermission == false) {
            let _ = await LocalNetworkAuthorization().requestAuthorization()
            userDefaults.set(true, forKey: "askedForLocalNetworkPermission")
        }
        
        if deviceId == nil {
            deviceId = UUID().uuidString
            userDefaults.set(deviceId, forKey: "deviceIdentifier")
        }

        var deviceType = DeviceType.unknown
        
#if os(iOS)
        let idiom = await UIDevice.current.userInterfaceIdiom

        if idiom == .pad {
            deviceType = .tablet
        } else if idiom == .phone {
            deviceType = .mobile
        } else if idiom == .mac {
            deviceType = .desktop
        }
#else
        deviceType = .desktop
#endif

        myDevice = Device(
            id: deviceId!,
            name: deviceName,
            deviceType: deviceType.rawValue
        )
        
        nearbyServer = NearbyServer(myDevice: myDevice!, storage: documentsDirectory.path, delegate: self)
    }
    
    public func saveName() {
        if deviceName.count < 3 {
            return
        }
        
        userDefaults.set(deviceName, forKey: "deviceName")

        if let nearbyServer, var myDevice {
            myDevice.name = deviceName
            nearbyServer.changeDevice(myDevice)
        } else {
            Task {
                await initializeServer(deviceName: deviceName)
            }
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
#if os(iOS)
            self.currentConnectionRequest = request
            self.showConnectionRequestDialog = true
#else
            var dynamicNotch: DynamicNotch<ConnectionRequestView>?
            
            dynamicNotch = DynamicNotch {
                ConnectionRequestView(connectionRequest: request, {
                    dynamicNotch?.hide(ignoreMouse: true)
                })
            }
            
            dynamicNotch?.toggle()
#endif
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
