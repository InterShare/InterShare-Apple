//
//  DiscoveryService.swift
//  InterShare
//
//  Created by Julian Baumann on 26.01.24.
//

import Foundation
import InterShareKit
#if os(iOS)
import UIKit
#endif

class DiscoveryService: ObservableObject, DiscoveryDelegate {
    private var discovery: Discovery?
    private var shouldStartScan = false
    private var bluetoothAlreadyInitialized = false
    private var scanning = false
#if os(iOS)
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
#endif

    @Published public var discoveredDevices: [DiscoveredDevice] = []
    @Published public var bluetoothEnabled = true
    
    private func startInternalScan() {
        if (shouldStartScan && bluetoothAlreadyInitialized && !scanning) {
            do {
                try discovery?.startScan()
                scanning = true
            }
            catch {
                print(error)
            }
        }
    }
    
    func discoveryDidUpdateState(state: BluetoothState) {
        if state == .poweredOn {
            bluetoothEnabled = true
            bluetoothAlreadyInitialized = true
            startInternalScan()
        }
        else if (state == .poweredOff || state == .unauthorized || state == .unsupported) {
            bluetoothEnabled = false
        }
    }
    
    func startScan() {
        do {
            if let discovery = discovery {
                try discovery.stopScan()
            }

            discovery = try Discovery(delegate: self)
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.resetProgress()
            self.discoveredDevices.removeAll()
            self.shouldStartScan = true
            self.startInternalScan()

            let existingDevices = self.discovery?.getDevices() ?? []
            
            for device in existingDevices {
                self.discoveredDevices.append(DiscoveredDevice(device: device, progress: SendProgress()))
            }
        }
    }

    func resetProgress() {
        for device in discoveredDevices {
            print("Resetting progress for \(device.device.name)")
            device.resetProgress()
        }
    }

    func deviceAdded(value: Device) {
        DispatchQueue.main.async {
//            self.deviceSendProgress[value.id] = SendProgress()
            let indexOfExisting = self.discoveredDevices.firstIndex(where: { device in device.device.id == value.id }) ?? -1
            
            if (indexOfExisting >= 0) {
                self.discoveredDevices[indexOfExisting].device = value
                self.discoveredDevices[indexOfExisting].resetProgress()
            } else {
                self.discoveredDevices.append(DiscoveredDevice(device: value, progress: SendProgress()))
#if os(iOS)
                self.impactFeedback.impactOccurred()
#endif
            }
        }
    }
    
    func deviceRemoved(deviceId: String) {
        DispatchQueue.main.async {
            self.discoveredDevices.removeAll { $0.device.id == deviceId }
        }
    }
    
    public func close() {
        do {
            scanning = false
            shouldStartScan = false
            try discovery?.stopScan()
            discovery = nil
        } catch {
            print(error)
        }
    }
    
}
