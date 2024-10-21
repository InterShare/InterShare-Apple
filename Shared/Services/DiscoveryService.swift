//
//  DiscoveryService.swift
//  InterShare
//
//  Created by Julian Baumann on 26.01.24.
//

import Foundation
import DataRCT
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

    @Published public var discoveredDevices: [Device] = []
    @Published public var deviceSendProgress: [String: SendProgress] = [:]
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
            discovery = try Discovery(delegate: self)
        } catch {
            print(error)
        }
        
        DispatchQueue.main.async {
            self.discoveredDevices.removeAll()
            self.resetProgress()
            self.shouldStartScan = true
            self.startInternalScan()
        }
    }
    
    func resetProgress() {
        for key in deviceSendProgress.keys {
            deviceSendProgress[key] = SendProgress()
        }
    }

    func deviceAdded(value: Device) {

        DispatchQueue.main.async {
            self.deviceSendProgress[value.id] = SendProgress()
            let indexOfExisting = self.discoveredDevices.firstIndex(where: { device in device.id == value.id }) ?? -1
            
            if (indexOfExisting >= 0) {
                self.discoveredDevices[indexOfExisting] = value
            } else {
                self.discoveredDevices.append(value)
                
#if os(iOS)
                self.impactFeedback.impactOccurred()
#endif
            }
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
            scanning = false
            shouldStartScan = false
            try discovery?.stopScan()
            discovery = nil
        } catch {
            print(error)
        }
    }
    
}
