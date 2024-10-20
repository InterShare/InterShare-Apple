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
import NetworkExtension

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel = ContentViewModel()
    @State private var animateGradient = true
    @State private var showFileImporter = false
    @StateObject var discovery = DiscoveryService()
    
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
        ZStack(alignment: .top) {
            LinearGradient(colors: [Color("StartGradientStart"), Color("StartGradientEnd"), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 300)
                .hueRotation(.degrees(animateGradient ? 10 : 0))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: viewModel.advertisementEnabled)
                .onAppear {
                    withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
            
            VStack(alignment: .center) {
                HStack {
                    Button(action: {
                        viewModel.showDeviceNamingAlert = true
                    }) {
                        ZStack {
                            Circle().frame(width: 22, height: 22)
                            Text(viewModel.deviceName.first?.uppercased() ?? "")
                                .foregroundStyle(.white)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        
                        Text(viewModel.deviceName)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                    .buttonBorderShape(.capsule)
                    .lineLimit(1)
                    .disabled(!viewModel.isPoweredOn)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                
                if (!viewModel.isPoweredOn) {
                    Spacer()
                    BluetoothDisabledWarningView()
                }
                
                Spacer()

                VStack {
                    if (viewModel.isPoweredOn) {
                        ReadyToReceiveView()
                    }
                    
                    Text("Share")
                        .opacity(0.7)
                        .bold()
                        .padding(.bottom)
                    
                    HStack {
                        PhotosPicker(
                            selection: $viewModel.imageSelection,
                            photoLibrary: .shared()) {
                            Text("Image or Video")
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                        }
                        .disabled(!viewModel.isPoweredOn)
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
                        .disabled(!viewModel.isPoweredOn)
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
//                                discoveryService.resetProgress()
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
                .ignoresSafeArea(.keyboard)
                
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
                            .padding(.top, 10)
                            .environmentObject(discovery)
                            .presentationCornerRadius(30)
                            .presentationBackground(.regularMaterial)
                            .presentationDetents([ .medium, .large])
                            .onDisappear {
                                discovery.close()
                            }
                }
            }
            
            .fullScreenCover(isPresented: $viewModel.showReceivingDialog) {
                NavigationView {
                    ReceiveContentView(
                        progress: viewModel.receiveProgress ?? ReceiveProgress(),
                        downloadsPath: viewModel.documentsDirectory.path,
                        connectionRequest: viewModel.currentConnectionRequest!)
                }
//                .presentationDetents([.height(200)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
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
