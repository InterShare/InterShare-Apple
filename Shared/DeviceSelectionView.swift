//
//  DeviceSelectionView.swift
//  InterShare
//
//  Created by Julian Baumann on 24.01.24.
//

import SwiftUI
import InterShareKit

struct DeviceSelectionView: View {
    @ObservedObject var viewModel: DeviceInfoListViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var discoveryService: DiscoveryService
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 70))
    ]
    
    init(nearbyServer: NearbyServer, urls: [String]) {
        self.viewModel = DeviceInfoListViewModel(nearbyServer: nearbyServer, urls: urls)
    }
    
    var body: some View {
        ScrollView {
            if (discoveryService.bluetoothEnabled) {
                LazyVGrid(columns: adaptiveColumns, alignment: .leading, spacing: 15) {
                    ForEach(discoveryService.discoveredDevices, id: \.id) { device in
                        Button(action: {
                            viewModel.send(device: device, progress: discoveryService.deviceSendProgress[device.id]!)
                        }) {
                            DeviceInfoListView(deviceInfo: device, progress: discoveryService.deviceSendProgress[device.id]!)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
    #if os(macOS)
                        .buttonStyle(.plain)
    #endif
                    }
                }
                .padding()
            } else {
                BluetoothDisabledWarningView()
            }
        }
        .onAppear {
            discoveryService.startScan()
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            HStack() {
                ProgressView()
#if os(macOS)
                    .controlSize(.small)
#endif
                VStack {
                    Text("Looking for nearby devices")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .padding(.bottom, 0)
                        .opacity(0.7)
                    
                    Text("Make sure the receiver has the InterShare app open on their device.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 0)
                        .opacity(0.6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            .padding()
            
#if os(iOS)
            .safeAreaPadding(.vertical)
#endif
        }
        .onDisappear {
            discoveryService.close()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("InterShare a copy")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    if #available(macOS 13.3, *) {
        DeviceSelectionView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), urls: [""])
            .environmentObject(DiscoveryService())
    } else {
        DeviceSelectionView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), urls: [""])
            .environmentObject(DiscoveryService())
    }
}
