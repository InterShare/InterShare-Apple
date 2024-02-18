//
//  ReceiveContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 31.01.24.
//

import SwiftUI
import DataRCT

struct ReceiveContentView: View {
    @ObservedObject var progress: ReceiveProgress
    var connectionRequest: ConnectionRequest?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Receiving file")
                .bold()
                .padding(.vertical)
                .font(.system(size: 25))
            
            Text("File: \(connectionRequest?.getFileTransferIntent()?.fileName ?? "Unknown file")")
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            Text("Size: \(toHumanReadableSize(bytes: connectionRequest?.getFileTransferIntent()?.fileSize))")
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)

            switch(progress.state)
            {
            case .receiving(let progress):
                ProgressView(value: progress)
                    .padding(.top)
                    .padding()
                
            case .finished:
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.green)
                    .font(.system(size: 50))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                ProgressView()
                    .padding(.top)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

#Preview {
    VStack {
    }
    .sheet(isPresented: .constant(true)) {
        NavigationView {
            ReceiveContentView(progress: ReceiveProgress())
        }
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
    }
}
