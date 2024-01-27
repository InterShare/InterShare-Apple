//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

import SwiftUI
import DataRCT
import PhotosUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var discoveryService: DiscoveryService
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Device name:")
                Button(viewModel.deviceName, action: {
                    viewModel.showDeviceNamingAlert = true
                })
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            
            Spacer()
            
            VStack {
                Text("Share")
                    .opacity(0.7)
                    .bold()
                    .padding()
                
                HStack {
                    PhotosPicker(
                        selection: $viewModel.imageSelection,
                        photoLibrary: .shared()) {
                        Text("Image or Video")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(Color("ButtonTint"))
                    .foregroundStyle(Color("ButtonTextColor"))
                    
                    Button(action: {}) {
                        Text("File")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(Color("ButtonTint"))
                    .foregroundStyle(Color("ButtonTextColor"))
                }
                .padding(.horizontal)
                
                Button(action: {}) {
                    Text("Received files")
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .tint(Color("ReceivedFilesTint"))
                .padding(.horizontal)
            }
            
        }
        
        .alert("Name this device",
               isPresented: $viewModel.showDeviceNamingAlert,
               actions: {
            TextField("Device name", text: $viewModel.deviceName)
            Button("Save", action: {
                viewModel.saveName()
            })
        }, message: {
            Text("Nearby devices will discover this device using this name, which must be at least three characters long.")
                .multilineTextAlignment(.center)
        })
        
        .alert(
            (viewModel.currentConnectionRequest?.getSender().name ?? "Unknown") + " wants to send you a file",
            isPresented: $viewModel.showConnectionRequestDialog,
            presenting: viewModel.currentConnectionRequest
        ) { request in
            Button("Accept") {
                request.accept()
            }
            Button(role: .cancel) {
                request.decline()
            } label: {
                Text("Decline")
            }
        } message: { request in
            Text(request.getSender().name + " wants to send you a file")
        }
        
        
        .sheet(isPresented: $viewModel.showDeviceSelectionSheet, onDismiss: viewModel.onDeviceListSheetDismissed) {
            if let nearbyServer = viewModel.nearbyServer,
               let selectedImageURL = viewModel.selectedImageURL {
                NavigationStack {
                    DeviceSelectionView(nearbyServer: nearbyServer, imageURL: selectedImageURL)
                        .environmentObject(discoveryService)
                }
            }
        }
        
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
            }
        }
        
        .toolbar {
            ToolbarItem {
                Picker("Discoverable", selection: $viewModel.advertisementEnabled) {
                    Text("Visible")
                        .tag(true)
                    
                    Text("Not Visible")
                        .tag(false)
                }
                .pickerStyle(.menu)
                .disabled(!viewModel.isPoweredOn)
                .onChange(of: viewModel.advertisementEnabled, perform: { (value) in
                    viewModel.changeAdvertisementState()
                })
            }
        }
        .navigationTitle("InterShare")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
                .environmentObject(DiscoveryService())
        }
    }
}
