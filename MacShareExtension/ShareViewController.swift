//
//  ShareViewController.swift
//  MacShareExtension
//
//  Created by Julian Baumann on 20.10.24.
//

import Cocoa
import DataRCT
import SwiftUI

class ShareViewController: NSViewController, NearbyServerDelegate {
    @IBOutlet weak var containerView: NSView!
    
    private var discovery = DiscoveryService()
    
    func nearbyServerDidUpdateState(state: DataRCT.BluetoothState) {
        
    }
    
    func receivedConnectionRequest(request: DataRCT.ConnectionRequest) {
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
    
    func buildView(url: String) {
        self.view = NSView(frame: NSMakeRect(0, 0, 500, 400))
                
        guard let nearbyServer = initializeNearbyServer() else {
            print("Failed to initialize NearbyServer")
            return
        }

        DispatchQueue.main.async {
            print(url)
            let swiftUIView = ShareSheetView(nearbyServer: nearbyServer, imageURL: url, close: { self.cancel() })
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
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        
        guard let attachment = item.attachments?.first else {
            return
        }
        
        getURL(item: attachment) { result in
            switch result {
            case .success(let data):
                if let unescapedURLString = data.path().removingPercentEncoding {
                    self.buildView(url: unescapedURLString)
                } else {
                    print("Failed to unescape the URL.")
                }
            case .failure(let error):
                print("Failed \(error)")
                self.cancel()
                return
            }
        }
    }

    func cancel() {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
}
