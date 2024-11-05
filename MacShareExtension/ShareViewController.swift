//
//  ShareViewController.swift
//  MacShareExtension
//
//  Created by Julian Baumann on 20.10.24.
//

import Cocoa
import InterShareKit
import SwiftUI

class ShareViewController: NSViewController, NearbyServerDelegate {
    @IBOutlet weak var containerView: NSView!
    
    private var discovery = DiscoveryService()
    
    func nearbyServerDidUpdateState(state: InterShareKit.BluetoothState) {
        
    }
    
    func receivedConnectionRequest(request: InterShareKit.ConnectionRequest) {
        fatalError("WTF did you do. It should be improssible to receive a connection request in Share Extension")
    }
    
    func initializeNearbyServer() -> NearbyServer? {
        let userDefaults = UserDefaults(suiteName: "PBYG8F53RH.com.julian-baumann.InterShare")!
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
    
    func buildView(urls: [String]) {
        self.view = NSView(frame: NSMakeRect(0, 0, 500, 400))
                
        guard let nearbyServer = initializeNearbyServer() else {
            print("Failed to initialize NearbyServer")
            return
        }

        DispatchQueue.main.async {
            let swiftUIView = ShareSheetView(nearbyServer: nearbyServer, urls: urls, close: { self.cancel() })
                .environmentObject(self.discovery)
            
            let hostingView = NSHostingView(rootView: swiftUIView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(hostingView)
            
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: self.view.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }

    override func loadView() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            return
        }
        
        Task {
            do {
                var urls: [String] = []
                
                guard let itemProvider = extensionItem.attachments else {
                    return
                }
                
                for item in itemProvider {
                    let url = try await getURL(item: item)
                    if let unescapedURLString = url.path().removingPercentEncoding {
                        urls.append(unescapedURLString)
                    } else {
                        print("Failed to unescape the URL.")
                    }
                }


                print("Urls \(urls)")
                self.buildView(urls: urls)
            } catch {
                print(error)
            }
        }
    }

    func cancel() {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
}
