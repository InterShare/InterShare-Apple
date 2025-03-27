//
//  DiscoveredDevice.swift
//  InterShare
//
//  Created by Julian Baumann on 22.03.25.
//
import InterShareKit
import SwiftUI

struct DiscoveredDevice: Identifiable {
    public var id: UUID = UUID()
    public var device: Device
    public var progress: SendProgress
    
    public func resetProgress() {
        progress.progressChanged(progress: .unknown)
        progress.medium = nil
    }
    
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        lhs.device == rhs.device && lhs.progress.state == rhs.progress.state
    }
}
