//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Julian Baumann on 19.10.24.
//

import UIKit
import Social
import SwiftUI
import InterShareKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController, NearbyServerDelegate {
    private var discovery = DiscoveryService()
    let contentTypeURL = UTType.url.identifier
    let contentTypeText = UTType.text.identifier
    
    func nearbyServerDidUpdateState(state: InterShareKit.BluetoothState) {
        
    }
    
    func receivedConnectionRequest(request: InterShareKit.ConnectionRequest) {
        fatalError("WTF did you do. It should be improssible to receive a connection request in Share Extension")
    }
    
    func initializeNearbyServer() -> NearbyServer? {
        let userDefaults = UserDefaults(suiteName: "group.com.julian-baumann.InterShare")!
        let deviceName = userDefaults.string(forKey: "deviceName")
        let deviceId = userDefaults.string(forKey: "deviceIdentifier")
        
        var deviceType = DeviceType.unknown
        
#if os(iOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        
        if idiom == .pad {
            deviceType = .tablet
        } else if idiom == .phone {
            deviceType = .mobile
        } else if idiom == .mac {
            deviceType = .mobile
        }
#else
        deviceType = .desktop
#endif
        
        guard let deviceName, let deviceId else {
            close()

            return nil
        }
        
        let myDevice = Device(
            id: deviceId,
            name: deviceName,
            deviceType: deviceType.rawValue
        )
        
        let storageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
        return NearbyServer(myDevice: myDevice, storage: storageURL, delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    func buildView(nearbyServer: NearbyServer, urls: [String], clipboard: String? = nil) {
        DispatchQueue.main.async {

            let view = NavigationStack {
                ShareView(nearbyServer: nearbyServer, urls: urls, clipboard: clipboard)
                    .environmentObject(self.discovery)
                    .toolbar(content: {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                self.close()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    })
                    .onAppear {
                        self.discovery.startScan()
                    }
            }
            
            let contentView = UIHostingController(rootView: view)
            self.addChild(contentView)
            self.view.addSubview(contentView.view)

            contentView.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
            contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let nearbyServer = initializeNearbyServer() else {
            close()
            return
        }
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            close()
            return
        }
        
        Task {
            do {
                var urls: [String] = []
                
                guard let itemProvider = extensionItem.attachments else {
                    return
                }

                if itemProvider.first?.hasItemConformingToTypeIdentifier(contentTypeURL) == true {
                    let url = try await itemProvider.first!.loadItem(forTypeIdentifier: contentTypeURL) as! URL
                    self.buildView(nearbyServer: nearbyServer, urls: [], clipboard: url.absoluteString)
                }
                else if itemProvider.first?.hasItemConformingToTypeIdentifier(contentTypeText) == true {
                    let text = try await itemProvider.first!.loadItem(forTypeIdentifier: contentTypeText) as! String
                    self.buildView(nearbyServer: nearbyServer, urls: [], clipboard: text)
                }
                else {
                    for item in itemProvider {
                        let url = try await getURL(item: item)
                        if let unescapedURLString = url.path().removingPercentEncoding {
                            urls.append(unescapedURLString)
                        } else {
                            print("Failed to unescape the URL.")
                            self.close()
                        }
                    }
                    
                    print("Urls \(urls)")
                    self.buildView(nearbyServer: nearbyServer, urls: urls)
                }

            } catch {
                print(error)
            }
        }
    }
    
    func close() {
        self.extensionContext?.completeRequest(returningItems: []) { result in
            DispatchQueue.main.async {
                self.discovery.close()
            }
        }
    }

}
