//
//  DeviceSelectionView.swift
//  InterShare
//
//  Created by Julian Baumann on 24.01.24.
//

import SwiftUI
import InterShareKit

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var discoveryService: DiscoveryService
    @Environment(\.colorScheme) var colorScheme
    static var canExecuteOnDisappear = false
    
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 70))
    ]
    
    init(nearbyServer: NearbyServer, urls: [String], clipboard: String?) {
        if (clipboard?.isEmpty == false) {
            self.viewModel = ShareViewModel(nearbyServer: nearbyServer, text: clipboard!)
        } else {
            self.viewModel = ShareViewModel(nearbyServer: nearbyServer, urls: urls)
        }
    }
    
    var body: some View {
        ScrollView {
            if (discoveryService.bluetoothEnabled) {
                if discoveryService.discoveredDevices.count == 0 {
                    VStack(alignment: .center) {
                        ProgressView()
#if os(macOS)
                            .controlSize(.small)
#endif
                        Text("Looking for nearby devices")
                            .bold()
                            .padding(.bottom, 0)
                            .opacity(0.7)
                        
                        Text("Make sure the receiver has the InterShare app open on their device.")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300, alignment: .center)
                            .padding(.top, 0)
                            .opacity(0.6)
                    }
                    .padding()
                    .padding(.top, 50)
                }
                
                LazyVGrid(columns: adaptiveColumns, alignment: .leading, spacing: 15) {
                    ForEach(discoveryService.discoveredDevices, id: \.id) { device in
                        Button(action: {
                            viewModel.send(device: device, progress: discoveryService.deviceSendProgress[device.id]!)
                        }) {
                            DeviceInfoListView(deviceInfo: device, progress: discoveryService.deviceSendProgress[device.id]!)
                        }
                        .disabled(!viewModel.isReady)
                        .opacity(viewModel.isReady ? 1.0 : 0.4)
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
//        .onAppear {
//            Self.canExecuteOnDisappear = true
//            print("Starting scan")
//            discoveryService.startScan()
//        }
//        .onDisappear {
//            if Self.canExecuteOnDisappear {
//                print("onDisappear")
//                discoveryService.close()
//            }
//        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            HStack() {
                if case .compressing(let compressionProgress) = viewModel.state {
                    ProgressView()
#if os(macOS)
                        .controlSize(.small)
#endif
                    VStack {
                        Text("Preparing files...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .padding(.bottom, 0)
                            .opacity(0.7)
                        
                        Text(String(format: "Compressing: %.1f%%", compressionProgress * 100))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 0)
                            .opacity(0.6)
                    }
                    
                } else {
                    VStack {
                        Text("Scan to receive")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .padding(.bottom, 0)
                            .opacity(0.7)
                        
                        Text("No InterShare installation required. Just scan and receive.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 0)
                            .opacity(0.6)
                    }

                    if let imageData = viewModel.getQRCode(darkMode: colorScheme == .dark) {
#if os(iOS)
                        Image(uiImage: imageData)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
#elseif os(macOS)
                        Image(nsImage: imageData)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
#endif
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(15)
            .padding()
            .applySafeAreaPadding()
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("InterShare a copy")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif

        .alert("Cannot share due to incompatible Versions.", isPresented: $viewModel.showIncompatibleMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.incompatibleVersionMessage ?? "")
        }
    }
}

#Preview {
    if #available(macOS 13.3, *) {
        ShareView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), urls: [""], clipboard: nil)
            .environmentObject(DiscoveryService())
    } else {
        ShareView(nearbyServer: NearbyServer(myDevice: Device(id: "", name: "", deviceType: 0), storage: "", delegate: ContentViewModel()), urls: [""], clipboard: nil)
            .environmentObject(DiscoveryService())
    }
}
