//
//  DiscoveryService.swift
//  InterShare
//
//  Created by Julian Baumann on 26.01.24.
//

import Foundation
import DataRCT

class DiscoveryService: ObservableObject, DiscoveryDelegate {
    private var discovery: Discovery?

    @Published public var discoveredDevices: [Device] = []
    @Published public var deviceSendProgress: [String: SendProgress] = [:]
    
    init() {
        do {
            discovery = try Discovery(delegate: self)
        } catch {
            print(error)
        }
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
    
    func resetProgress() {
        for key in deviceSendProgress.keys {
            deviceSendProgress[key] = SendProgress()
        }
    }

    func deviceAdded(value: Device) {
        DispatchQueue.main.async {
            self.discoveredDevices.append(value)
            self.deviceSendProgress[value.id] = SendProgress()
        }
    }
    
    func deviceRemoved(deviceId: String) {
        DispatchQueue.main.async {
            self.discoveredDevices.removeAll { $0.id == deviceId }
            self.deviceSendProgress.removeValue(forKey: deviceId)
        }
    }
    
    public func close() {
        do {
            try discovery?.stopScan()
        } catch {
            print(error)
        }
    }
    
}
