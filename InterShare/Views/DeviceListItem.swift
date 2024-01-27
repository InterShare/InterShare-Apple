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
    @StateObject public var progress: SendProgress
    
    func getSymbol() -> String {
        if deviceInfo.deviceType == DeviceType.desktop.rawValue {
            return "desktopcomputer"
        }
        
        if deviceInfo.deviceType == DeviceType.mobile.rawValue {
            return "iphone"
        }
        
        if deviceInfo.deviceType == DeviceType.tablet.rawValue {
            return "ipad.landscape"
        }

        return "iphone"
    }
    
    var body: some View {
        HStack {
            switch(progress.state)
            {
            case .connecting:
                HStack {
                    Label("Connecting...", systemImage: getSymbol())
                        .foregroundColor(.blue)
                    Spacer()
                    ProgressView()
                }
            
            case .requesting:
                HStack {
                    Label("Requesting...", systemImage: getSymbol())
                        .foregroundColor(.blue)
                    Spacer()
                    ProgressView()
                }
            
            case .transferring(let progress):
                HStack {
                    Label("Transferring", systemImage: getSymbol())
                        .foregroundColor(.blue)
                    Spacer()
                    ProgressView(value: progress)
                }
            case .declined:
                Label(deviceInfo.name, systemImage: getSymbol())
                    .foregroundColor(.red)
                
            case .finished:
                Label(deviceInfo.name, systemImage: getSymbol())
                    .foregroundColor(.green)
            default:
                Label(deviceInfo.name, systemImage: getSymbol())
            }
        }
    }
}

struct DeviceInfoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Phone", deviceType: 0), progress: SendProgress())
                
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My PC", deviceType: 1), progress: SendProgress())
                
                DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Android", deviceType: 2), progress: SendProgress())
            }
        }
    }
}
