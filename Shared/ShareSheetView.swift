//
//  ShareSheetView.swift
//  MacShareExtension
//
//  Created by Julian Baumann on 20.10.24.
//

import SwiftUI
import InterShareKit

struct ShareSheetView: View {
    @EnvironmentObject var discovery: DiscoveryService
    public var nearbyServer: NearbyServer
    public var urls: [String]
    public var clipboard: String?
    public var close: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("InterShare a copy")
                .bold()
                .padding()
            
            Divider()
                .padding(0)
            
            ShareView(nearbyServer: nearbyServer, urls: urls, clipboard: clipboard)
                .environmentObject(discovery)
                .onAppear {
                    self.discovery.startScan()
                }
            
            Divider()
                .padding(0)
            
            Button("Done") {
                close()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(10)
        }
        .edgesIgnoringSafeArea(.top)
    }
}
