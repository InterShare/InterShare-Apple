//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 07.03.24.
//
#if os(macOS)

import SwiftUI

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
    @EnvironmentObject var discoveryService: DiscoveryService
    @ObservedObject var viewModel = ContentViewModel()
    @State private var animateGradient = true
    @State private var showFileImporter = false
    @State private var dragOver = false
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(dragOver ? dropZoneSelectedColor : dropZonePrimaryColor)
                
                Text("Drop files here")
                    .opacity(0.8)
            }
            .padding([.bottom, .trailing, .leading])
            .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                providers.first?.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                    if let data = data,
                       let path = NSString(data: data, encoding: 4),
                       let url = URL(string: path as String) {
                        print(url.path)
                        viewModel.shouldDeleteSelectedFileAfterwards = false
                        let _ = url.startAccessingSecurityScopedResource()
                        viewModel.selectedFileURL = url.path
                        
                        discoveryService.resetProgress()
                        viewModel.showDeviceSelectionSheet = true
                    }
                })

                return true
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.top, 0)
        .frame(minWidth: 330, maxWidth: 330, minHeight: 150, maxHeight: 150)
        .background(VisualEffectView().ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Share Clipboard") {
                    print("Pressed")
                }
            }
            
            ToolbarItem {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Settings", systemImage: "gear") {
                    print("Pressed")
                }
            }
        }
        
        .alert(
            (viewModel.currentConnectionRequest?.getSender().name ?? "Unknown") + " wants to send you a file (\(toHumanReadableSize(bytes: viewModel.currentConnectionRequest?.getFileTransferIntent()?.fileSize)))",
            isPresented: $viewModel.showConnectionRequestDialog,
            presenting: viewModel.currentConnectionRequest
        ) { request in
            Button("Accept") {
                viewModel.receiveProgress = ReceiveProgress()
                request.setProgressDelegate(delegate: viewModel.receiveProgress!)
                

                Thread {
                    request.accept()
                }.start()
                
                DispatchQueue.main.async {
                    print("show dialog")
                    viewModel.showReceivingDialog = true
                }
            }
            Button(role: .cancel) {
                request.decline()
            } label: {
                Text("Decline")
            }
        } message: { request in
            Text("\"\(request.getFileTransferIntent()?.fileName ?? "")\"")
        }

        .sheet(isPresented: $viewModel.showDeviceSelectionSheet, onDismiss: viewModel.onDeviceListSheetDismissed) {
            if let nearbyServer = viewModel.nearbyServer,
               let selectedImageURL = viewModel.selectedFileURL {
                DeviceSelectionView(nearbyServer: nearbyServer, imageURL: selectedImageURL)
                    .environmentObject(discoveryService)
                    .frame(width: 500, height: 300)
                    .background(VisualEffectView().ignoresSafeArea())
            }
        }
        
        .sheet(isPresented: $viewModel.showReceivingDialog) {
            ReceiveContentView(progress: viewModel.receiveProgress ?? ReceiveProgress(), connectionRequest: viewModel.currentConnectionRequest!)
                .frame(width: 300, height: 200)
                .background(VisualEffectView().ignoresSafeArea())
        }
    }
}

#Preview {
    ContentView()
}
#endif
