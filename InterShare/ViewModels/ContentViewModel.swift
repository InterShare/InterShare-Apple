//
//  ContentViewModel.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import Foundation
import DataRCT

#if os(iOS)
import UIKit
#endif

class ContentViewModel: ObservableObject, DiscoveryDelegate {
    private var _discovery: Discovery?
    private var _incomingThread: Thread?
    private var _transmission: Transmission?

    @Published public var discoveredDevices: [DeviceInfo] = []
    @Published public var advertisementEnabled = false
    @Published public var deviceName: String = "Unknown";
    @Published public var sheetOpened: Bool = false;
    @Published public var clickedDevice: DeviceInfo?;
    
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
            
            var device = DeviceInfo(
                id: UUID().uuidString,
                name: deviceName,
                port: 4243,
                deviceType: deviceType,
                ipAddress: ipAddress
            )
            
            _transmission = try Transmission(myDevice: device)
            device.port = _transmission?.getPort() ?? 0
            
            _discovery = try Discovery(myDevice: device, method: DiscoveryMethod.mdns, delegate: self)
            _discovery?.startSearch()
            
            _incomingThread = Thread {
                let incoming = self._transmission?.getIncoming()
                
                if let incoming = incoming {
                    print(incoming.getSenderName())
                    do {
                        let stream = try incoming.accept()
                        var buffer = Array(repeating: UInt8(0), count: 13)
                        try stream.readBytes(buffer: buffer)
                        
                        print(buffer)
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
            
            _incomingThread?.start()
            
        } catch {
            print("Error! \(error)")
        }
    }
    
    func deviceAdded(value: DataRCT.DeviceInfo) {
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
        if advertisementEnabled {
            _discovery?.advertise()
        } else {
            _discovery?.stopAdvertising()
        }
    }
    
    public func connect(to device: DeviceInfo) {
        do {
            let connection = try _transmission?.connectToDevice(recipient: device)
            let result = try connection?.writeBytes(buffer: Array("Hello, World".utf8))
            print(result)
        } catch {
            print(error)
        }
    }
}
