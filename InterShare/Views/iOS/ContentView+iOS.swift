//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

#if os(iOS)
import SwiftUI
import DataRCT
import PhotosUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var discoveryService: DiscoveryService
    @ObservedObject var viewModel = ContentViewModel()
    @State private var animateGradient = true
    @State private var showFileImporter = false
    
    init() {
        var titleFont = UIFont.preferredFont(forTextStyle: .largeTitle)

        titleFont = UIFont(
            descriptor:
                titleFont.fontDescriptor
                .withDesign(.rounded)?.withSymbolicTraits(.traitBold) ?? titleFont.fontDescriptor,
            size: titleFont.pointSize
        )

        UINavigationBar.appearance().largeTitleTextAttributes = [.font: titleFont]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(animateGradient ? 45 : 0))
                .ignoresSafeArea()
                .opacity(viewModel.advertisementEnabled ? 0.3 : 0.0)
                .animation(.easeInOut(duration: 2.0), value: viewModel.advertisementEnabled)
                .onAppear {
                    withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Device name:")
                    Button(viewModel.deviceName, action: {
                        viewModel.showDeviceNamingAlert = true
                    })
                    .lineLimit(1)
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
                        
                        Button(action: {
                            showFileImporter = true
                        }) {
                            Text("File")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(Color("ButtonTint"))
                        .foregroundStyle(Color("ButtonTextColor"))
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item], allowsMultipleSelection: false, onCompletion: { results in
                            switch results {
                            case .success(let fileUrls):
                                viewModel.shouldDeleteSelectedFileAfterwards = false
                                let fileUrl = fileUrls[0]
                                let _ = fileUrl.startAccessingSecurityScopedResource()
                                viewModel.selectedFileURL = fileUrl.path
                                discoveryService.resetProgress()
                                viewModel.showDeviceSelectionSheet = true
                            case .failure(let error):
                                print(error)
                            }
                        })
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "shareddocuments://\(viewModel.documentsDirectory.path)")!)
                    }) {
                        Text("Received files")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(Color("ReceivedFilesTint"))
                    .padding(.horizontal)
                    .animation(nil, value: UUID())
                }
                
            }
            
            .ignoresSafeArea(.keyboard)
            
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
                            .presentationCornerRadius(30)
                            .presentationBackground(.regularMaterial)
                            .presentationDetents([ .medium, .large])
                }
            }
            
            .sheet(isPresented: $viewModel.showReceivingDialog) {
                NavigationView {
                    ReceiveContentView(progress: viewModel.receiveProgress ?? ReceiveProgress(), connectionRequest: viewModel.currentConnectionRequest!)
                }
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            
            .toolbar {
                ToolbarItem {
                    Button(viewModel.advertisementEnabled ? "Visible" : "Not Visible") {
                        viewModel.advertisementEnabled.toggle()
                        viewModel.changeAdvertisementState()
                    }
                    .transition(.opacity)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 14))
                }
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
#endif
