//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 07.03.24.
//
#if os(macOS)

import SwiftUI
import AppKit

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color("MacButton"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 0.2)
                    .opacity(0.5)
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct ContentView: View {
    private var dropZonePrimaryColor = Color(red: 1, green: 1, blue: 1).opacity(0.05)
    private var dropZoneSelectedColor = Color.blue.opacity(0.5)

    @Environment(\.scenePhase) var scenePhase
    @StateObject var discoveryService = DiscoveryService()
    @ObservedObject var viewModel = ContentViewModel()
    @State private var animateGradient = true
    @State private var showFileImporter = false
    @State private var dragOver = false
    @State var isHovered = false
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("InterShare")
                .bold()
                .opacity(0.5)
            
            Divider()
            
            VStack(spacing: 0) {
                MenuButtonView("Visible to Everyone", icon: "eye.fill", isActivated: $viewModel.advertisementEnabled, hightlightColor: .gray.opacity(0.2)) {
                    viewModel.advertisementEnabled = true
                    viewModel.changeAdvertisementState()
                }
                
                MenuButtonView("Receiving Off", icon: "eye.slash.fill", isActivated: !$viewModel.advertisementEnabled, hightlightColor: .gray.opacity(0.2)) {
                    viewModel.advertisementEnabled = false
                    viewModel.changeAdvertisementState()
                }
            }
            
            Divider()
            
            HStack {
                Text("Device name:")
                    .opacity(0.5)
                
                Button(action: { viewModel.showDeviceNamingAlertOnMac() }) {
                    Text(viewModel.deviceName)
                        .lineLimit(1)
                }
                .buttonStyle(.link)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            
            Divider()
            
            MenuButtonView("Quit InterShare") {
                NSApplication.shared.terminate(nil)
            }
            
        }
        .padding(8)

        .alert("Name this device",
               isPresented: $viewModel.showDeviceNamingAlert,
               actions: {
            TextField("Device name", text: $viewModel.deviceName)
            Button("Save", action: {
                viewModel.saveName()
            })
            .disabled(viewModel.namingSaveButtonDisabled)
        }, message: {
            Text("Nearby devices will discover this device using this name, which must be at least three characters long.")
                .multilineTextAlignment(.center)
        })
    }
}

#Preview {
    ContentView()
}
#endif
