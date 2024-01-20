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
    @State public var deviceInfo: Device
    
    func getSymbol() -> String {
//        if deviceInfo.deviceType.contains("computer") {
//            return "desktopcomputer"
//        }
//        
//        if deviceInfo.deviceType.contains("phone") {
//            return "iphone"
//        }
        
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
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Phone", deviceType: 0))
                
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My PC", deviceType: 1))
                
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Android", deviceType: 2))
            }
        }
    }
}
