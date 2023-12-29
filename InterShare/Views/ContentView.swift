//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

import SwiftUI
import DataRCT

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Discovered Devices")) {
                ForEach(viewModel.discoveredDevices, id: \.id) { device in
                    Button(action: {
                        viewModel.clickedDevice = device
                        viewModel.sheetOpened = true
                    }) {
                        DeviceInfoListView(deviceInfo: device)
                    }
                }
                
                if viewModel.discoveredDevices.count == 0 {
                    Text("No devices found")
                        .opacity(0.6)
                }
            }
            
            .sheet(isPresented: $viewModel.sheetOpened) {
                if let device = viewModel.clickedDevice {
                    List {
                        Section(header:
                            VStack {
                                Spacer(minLength: 10)
                                Text("Device Configuration")
                            }
                        ) {
                            Label(device.name, systemImage: "info")
                            Label(device.id, systemImage: "info")
                            Label(device.deviceType, systemImage: "info")
                            Label(device.ipAddress, systemImage: "globe")
                            Label(String(device.port), systemImage: "globe")
                        }
                        
                        Section {
                            Button(action: {
                                viewModel.connect(to: device)
                            }) {
                                Label("Connect to peer", systemImage: "person.line.dotted.person")
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                    .navigationTitle(device.name)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #elseif os(macOS)
                    .frame(width: 350, height: 300)
                    #endif
                }
            }
        }
        .navigationTitle("DataRCT")
        .toolbar {
            ToolbarItem() {
                VStack {
                    Picker("Advertisement", selection: $viewModel.advertisementEnabled) {
                        Image(systemName: "eye.fill")
                            .symbolRenderingMode(.multicolor)
                            .tag(true)
                        
                        Image(systemName: "eye.slash.fill")
                            .symbolRenderingMode(.multicolor)
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.advertisementEnabled, perform: { (value) in
                        viewModel.changeAdvertisementState()
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
