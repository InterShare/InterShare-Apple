//
//  ContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 14.02.23.
//

#if os(iOS)
import SwiftUI
import InterShareKit
import PhotosUI
import NetworkExtension

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel = ContentViewModel()
    @State private var animateGradient = true
    @State private var showFileImporter = false
    
    let discovery = DiscoveryService()
    
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
    
    func getRequestText() -> String {
        if viewModel.currentConnectionRequest?.getIntentType() == .clipboard {
            return (viewModel.currentConnectionRequest?.getSender().name ?? "Unknown") + " wants to send you a text"
        }
        
        if (viewModel.currentConnectionRequest?.getFileTransferIntent()?.fileCount == 1) {
            return (viewModel.currentConnectionRequest?.getSender().name ?? "Unknown") + " wants to send you a file (\(toHumanReadableSize(bytes: viewModel.currentConnectionRequest?.getFileTransferIntent()?.fileSize)))"
        }
        
        return (viewModel.currentConnectionRequest?.getSender().name ?? "Unknown") + " wants to send you \(viewModel.currentConnectionRequest?.getFileTransferIntent()?.fileCount ?? 0) files."
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }

    func shareFile() {
        guard let filePath = getLogFilePathStr() else {
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("File does not exist")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        // Get the current root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
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
                        .padding(.top, 0)
                        .padding(.bottom, 5)
                    
                    HStack {
                        PhotosPicker(
                            selection: $viewModel.imageSelection,
                            preferredItemEncoding: .current,
                            photoLibrary: .shared()
                        ) {
                            VStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                
                                Text("Photos")
                                    .padding(.top, 1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                        }
                        .disabled(!viewModel.isPoweredOn)
                        .buttonStyle(.borderedProminent)
//                        .buttonBorderShape(.roundedRectangle)
                        .buttonBorderShape(.roundedRectangle(radius: 25))
                        .tint(Color("ButtonTint"))
                        .foregroundStyle(Color("ButtonTextColor"))
                        
                        Button(action: {
                            showFileImporter = true
                        }) {
                            VStack {
                                Image(systemName: "folder")
                                
                                Text("Files")
                                    .padding(.top, 1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                        }
                        .disabled(!viewModel.isPoweredOn)
                        .buttonStyle(.borderedProminent)
//                        .buttonBorderShape(.roundedRectangle)
                        .buttonBorderShape(.roundedRectangle(radius: 25))
                        .tint(Color("ButtonTint"))
                        .foregroundStyle(Color("ButtonTextColor"))
                        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.item], allowsMultipleSelection: true, onCompletion: { results in
                            switch results {
                            case .success(let fileUrls):
                                viewModel.clipboard = nil
                                viewModel.selectedFileURLs = []

                                for fileUrl in fileUrls {
                                    viewModel.selectedFileURLs.append(fileUrl.path)
                                    let _ = fileUrl.startAccessingSecurityScopedResource()
                                }
                                
                                viewModel.shouldDeleteSelectedFileAfterwards = false
                                viewModel.showDeviceSelectionSheet = true
                            case .failure(let error):
                                print(error)
                            }
                        })
                        

                        Button(action: {
                            viewModel.shareClipboard()
                        }) {
                            VStack {
                                Image(systemName: "clipboard")
                                Text("Clipboard")
                                    .padding(.top, 1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                        }
                        .disabled(!viewModel.isPoweredOn)
                        .buttonStyle(.borderedProminent)
//                        .buttonBorderShape(.roundedRectangle)
                        .buttonBorderShape(.roundedRectangle(radius: 25))
                        .tint(Color("ButtonTint"))
                        .foregroundStyle(Color("ButtonTextColor"))
                        .animation(nil, value: UUID())
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        UIApplication.shared.open(URL(string: "shareddocuments://\(viewModel.documentsDirectory.path)")!)
                    }) {
                        Text("Received Files")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(Color("ReceivedFilesTint"))
                    .padding(.horizontal)
                    .animation(nil, value: UUID())
                }
                .frame(maxWidth: 600)
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
                Text("Others will discover this device by this name")
                    .multilineTextAlignment(.center)
            })
            
            .alert(
                getRequestText(),
                isPresented: $viewModel.showConnectionRequestDialog,
                presenting: viewModel.currentConnectionRequest
            ) { request in
                Button("Accept") {
                    viewModel.receiveProgress = ReceiveProgress()
                    request.setProgressDelegate(delegate: viewModel.receiveProgress!)
                    viewModel.galleryLocalLink = nil
                    
                    Thread {
                        if let filePaths = request.accept() {
                            MediaSaver().save(files: filePaths) { localId in
                                if localId != nil {
                                    viewModel.galleryLocalLink = localId
                                }
                            }
                        }
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
                if (request.getFileTransferIntent()?.fileCount == 1) {
                    Text("\"\(request.getFileTransferIntent()?.fileName ?? "")\"")
                } else {
                    Text(toHumanReadableSize(bytes: viewModel.currentConnectionRequest?.getFileTransferIntent()?.fileSize))
                }
            }
            
            .alert(
                getRequestText(),
                isPresented: $viewModel.showClipboardActionsDialog,
                presenting: viewModel.currentConnectionRequest
            ) { request in
                Button("Copy") {
                    viewModel.copySharedTextToClipboard(request: request)
                }
                Button(role: .cancel) {
                    request.decline()
                } label: {
                    Text("Cancel")
                }
            } message: { request in
                Text("\"\(request.getClipboardIntent()?.clipboardContent ?? "")\"")
            }
            
            .sheet(isPresented: $viewModel.showDeviceSelectionSheet, onDismiss: viewModel.onDeviceListSheetDismissed) {
                if let nearbyServer = viewModel.nearbyServer {

                    ShareView(nearbyServer: nearbyServer, urls: viewModel.selectedFileURLs, clipboard: viewModel.clipboard)
                        .padding(.top, 10)
                        .environmentObject(discovery)
                        .presentationCornerRadius(30)
                        .presentationBackground(.regularMaterial)
//                        .interactiveDismissDisabled()
//                        .onDisappear {
//                            print("Discovery closed")
//                            discovery.close()
//                        }
                }
            }
            .onChange(of: viewModel.showDeviceSelectionSheet) { isPresented in
                if isPresented {
                    print("Starting scan")
                    discovery.startScan()
                } else {
                    print("Stopping scan")
                    discovery.close()
                }
            }
            
            .fullScreenCover(isPresented: $viewModel.showReceivingDialog) {
                NavigationView {
                    ReceiveContentView(
                        progress: viewModel.receiveProgress ?? ReceiveProgress(),
                        downloadsPath: viewModel.documentsDirectory.path,
                        galleryLinkId: viewModel.galleryLocalLink,
                        connectionRequest: viewModel.currentConnectionRequest!)
                }
//                .presentationDetents([.height(200)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(true)
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .active:
                    print("App is active")
                    
                    Task {
                        await viewModel.startServer()
                    }
                case .background:
                    print("App is in the background")
                    Task {
                        await viewModel.stopServer()
                    }
                default:
                    break
                }
            }
        }
        
        .toolbar {
            Menu {
                Button(action: {}) {
                    Label("App Version: \(getAppVersion())", systemImage: "info")
                }.disabled(true)

                Link(destination: URL(string: "https://buymeacoffee.com/julianbaumann")!) {
                    Label("Buy me a coffee", systemImage: "cup.and.heat.waves")
                }

                Button(action: shareFile) {
                    Label("Share Logs", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "questionmark.circle")
            }
        }
        .navigationTitle("InterShare")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
#endif
