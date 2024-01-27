//
//  DeviceSelectionView.swift
//  InterShare
//
//  Created by Julian Baumann on 24.01.24.
//

import SwiftUI
import DataRCT

struct DeviceSelectionView: View {
    @ObservedObject var viewModel: DeviceInfoListViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var discoveryService: DiscoveryService
    
    init(nearbyServer: NearbyServer, imageURL: String) {
        self.viewModel = DeviceInfoListViewModel(nearbyServer: nearbyServer, imageURL: imageURL)
    }
    
    var body: some View {
        List {
//            Section {
//                HStack {
//                    ProgressView()
//                    Text("Looking for nearby devices")
//                        .padding(.leading)
//                        .opacity(0.8)
//                }
//            }
            
            ForEach(discoveryService.discoveredDevices, id: \.id) { device in
                Button(action: {
                    viewModel.send(device: device, progress: discoveryService.deviceSendProgress[device.id]!)
                }) {
                    DeviceInfoListView(deviceInfo: device, progress: discoveryService.deviceSendProgress[device.id]!)
                }
            }

            if discoveryService.discoveredDevices.count == 0 {
                Text("No devices found")
                    .opacity(0.6)
            }
        }
        .navigationTitle("InterShare a copy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        })
    }
}

#Preview {
    NavigationStack {
        DeviceSelectionView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), imageURL: "")
            .environmentObject(DiscoveryService())
    }
}
