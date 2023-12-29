//
//  DeviceInfoListView.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import Foundation
import SwiftUI
import DataRCT

struct DeviceInfoListView: View {
    @State public var deviceInfo: DeviceInfo
    
    func getSymbol() -> String {
        if deviceInfo.deviceType.contains("computer") {
            return "desktopcomputer"
        }
        
        if deviceInfo.deviceType.contains("phone") {
            return "iphone"
        }
        
        return "questionmark"
    }
    
    var body: some View {
        HStack {
            Label(deviceInfo.name, systemImage: getSymbol())
        }
    }
}

struct DeviceInfoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                DeviceInfoListView(deviceInfo: DeviceInfo(id: UUID().uuidString, name: "My Phone", port: 42, deviceType: "phone", ipAddress: "192.168.3"))
                
                DeviceInfoListView(deviceInfo: DeviceInfo(id: UUID().uuidString, name: "My PC", port: 42, deviceType: "computer", ipAddress: "192.168.3"))
                
                DeviceInfoListView(deviceInfo: DeviceInfo(id: UUID().uuidString, name: "My Android", port: 42, deviceType: "android", ipAddress: "192.168.3"))
            }
        }
    }
}