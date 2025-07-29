//
//  ReceiveContentView.swift
//  InterShare
//
//  Created by Julian Baumann on 31.01.24.
//

import SwiftUI
import InterShareKit

struct ReceiveContentView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var progress: ReceiveProgress
    var downloadsPath: String
    var galleryLinkId: String?
    
    var connectionRequest: ConnectionRequest?
    @State private var gradientHeight: CGFloat = 0.0
    
    private func updateGradientHeight(for progressValue: Double) {
        withAnimation {
            gradientHeight = CGFloat(progressValue)
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                LinearGradient(colors: [Color("StartGradientStart"), Color("StartGradientEnd"), .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: gradientHeight * (geo.size.height + (geo.size.height / 2)))
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: gradientHeight)
            }
            
            
            VStack(alignment: .leading) {
                Text("From \(connectionRequest?.getSender().name ?? "Unknown")")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .bold()
                    .font(.system(size: 22))
                    .opacity(0.6)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(connectionRequest?.getFileTransferIntent()?.fileName ?? "\(connectionRequest?.getFileTransferIntent()?.fileCount ?? 1) files")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                    
                    Text("Size: \(toHumanReadableSize(bytes: connectionRequest?.getFileTransferIntent()?.fileSize))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .glassEffectRectCard()
                .padding()
                
                switch(progress.state)
                {
                case .receiving(let progressValue):
                    Text(progressValue, format: .percent.precision(.fractionLength(0)))
                        .font(.system(size: 40))
                        .monospaced()
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            connectionRequest?.cancel()
                        }
                        dismiss()
                    }) {
                        Text("Cancel")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .destructiveButtonStyle()
                    .padding(.horizontal)
                    
                    .onAppear {
                        updateGradientHeight(for: progressValue)
                    }
                    .onChange(of: progressValue) { newState in
                        updateGradientHeight(for: newState)
                    }
    
                case .finished:
                    Text(1.0, format: .percent.precision(.fractionLength(0)))
                        .font(.system(size: 40))
                        .monospaced()
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)

                    Spacer()
                    
#if os(iOS)
                    Button(action: {
                        if galleryLinkId != nil {
                            if let url = URL(string: "photos-redirect://"), UIApplication.shared.canOpenURL(url) {
                                print(url)
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                print("Unable to open Photos app.")
                            }
                        } else {
                            UIApplication.shared.open(URL(string: "shareddocuments://\(downloadsPath)")!)
                        }
                    }) {
                        Text(galleryLinkId == nil ? "View in Files" : "Open Photos App")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .prominentButtonStyle()
                    .padding(.horizontal)
#endif
                    
                    Button(action: { dismiss() }) {
                        Text("Done")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .secondaryButtonStyle()
                    .padding(.horizontal)
                    
                    .onAppear {
                        updateGradientHeight(for: 1.0)
                    }
    
                case .cancelled:
                    Text("Cancelled")
                        .font(.system(size: 40))
                        .monospaced()
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Back")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .secondaryButtonStyle()
                    .padding(.horizontal)
    
                default:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            connectionRequest?.cancel()
                        }
                        
                        dismiss()
                    }) {
                        Text("Back")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .secondaryButtonStyle()
                    .padding(.horizontal)
                }
            }
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.background)
        .navigationTitle("Receiving")
    }
}

#Preview {
    NavigationView {
        ReceiveContentView(progress: ReceiveProgress(), downloadsPath: "")
    }
}
