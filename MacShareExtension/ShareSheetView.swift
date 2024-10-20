//
//  ShareSheetView.swift
//  MacShareExtension
//
//  Created by Julian Baumann on 20.10.24.
//

import SwiftUI
import DataRCT

struct ShareSheetView: View {
    @EnvironmentObject var discovery: DiscoveryService
    public var nearbyServer: NearbyServer
    public var imageURL: String
    public var close: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("InterShare a copy")
                .bold()
                .padding()
            
            Divider()
                .padding(0)
            
            DeviceSelectionView(nearbyServer: nearbyServer, imageURL: imageURL)
                .environmentObject(discovery)
            
            Divider()
                .padding(0)
            
            Button("Done") {
                close()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(10)
        }
    }
}
