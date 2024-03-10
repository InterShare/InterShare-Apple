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
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 70))
    ]
    
    init(nearbyServer: NearbyServer, imageURL: String) {
        self.viewModel = DeviceInfoListViewModel(nearbyServer: nearbyServer, imageURL: imageURL)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: adaptiveColumns, spacing: 15) {
                ForEach(discoveryService.discoveredDevices, id: \.id) { device in
                    Button(action: {
                        viewModel.send(device: device, progress: discoveryService.deviceSendProgress[device.id]!)
                    }) {
                        DeviceInfoListView(deviceInfo: device, progress: discoveryService.deviceSendProgress[device.id]!)
                    }
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                }
            }
            .padding()

            if discoveryService.discoveredDevices.count == 0 {
                VStack {
                    ProgressView()
                    Spacer()
                    Text("Looking for neaby devices")
                        .opacity(0.6)
                }
            }
        }
        .padding(.top, 10)
        .scrollContentBackground(.hidden)
        .navigationTitle("InterShare a copy")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
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
    VStack {
    }
    .sheet(isPresented: .constant(true), onDismiss: {}) {
        if #available(macOS 13.3, *) {
            DeviceSelectionView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), imageURL: "")
                .environmentObject(DiscoveryService())
                .presentationCornerRadius(20)
                .presentationBackground(.regularMaterial)
                .presentationDetents([ .medium, .large])
        } else {
            DeviceSelectionView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), imageURL: "")
                .environmentObject(DiscoveryService())
                .presentationDetents([ .medium, .large])
        }
    }
}
