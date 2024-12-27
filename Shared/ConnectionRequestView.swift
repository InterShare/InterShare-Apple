//
//  ConnectionRequestView.swift
//  InterShare
//
//  Created by Julian Baumann on 20.10.24.
//

import SwiftUI
import InterShareKit
#if os(macOS)
import DynamicNotchKit

struct ConnectionRequestView: View {
    var close: () -> Void
    var connectionRequest: ConnectionRequest?
    @StateObject var receiveProgress: ReceiveProgress = ReceiveProgress()
    @State var showProgress: Bool = false
    @State private var dynamicWidth: CGFloat = 300
    
    init(connectionRequest: ConnectionRequest?, _ closeCompletion: @escaping () -> Void) {
        self.connectionRequest = connectionRequest
        self.close = closeCompletion
    }
    
    func getColor(_ progress: ReceiveProgress) -> Color {
        switch(progress.state) {
        case .unknown:
            break
        case .receiving(progress: _):
            return .purple
        case .cancelled:
            return .red
        case .finished:
            return .green
        case .handshake:
            return .purple
        case .extracting:
            return .purple
        }
        
        return Color(red: 0, green: 0, blue: 0, opacity: 0.0)
    }
    
    var body: some View {
        VStack {
            if (showProgress) {
                HStack {
                    ZStack {
                        CircularProgressView(
                            progress: {
                                if case .receiving(let progress) = receiveProgress.state {
                                    progress
                                } else if receiveProgress.state == .finished {
                                    1.0
                                } else if receiveProgress.state == .extracting {
                                    1.0
                                } else if receiveProgress.state == .cancelled {
                                    1.0
                                } else {
                                    0.1
                                }
                            }(),
                            color: getColor(receiveProgress),
                            thickness: 5
                        )
                        .frame(width: 45, height: 45)
                        
                        Text(receiveProgress.numericProgress, format: .percent.precision(.fractionLength(0)))
                            .bold()
                            .opacity(0.5)
                            .font(.system(size: 8))
                    }
                    .padding()
                    
                    VStack(alignment: .leading) {
                        if case .receiving(_) = receiveProgress.state {
                            Text("Receiving")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .bold()
                        } else if receiveProgress.state == .extracting {
                            Text("Extracting")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .bold()
                        } else if receiveProgress.state == .finished {
                            Text("Finished")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .foregroundStyle(.green)
                                .bold()
                        } else if receiveProgress.state == .cancelled {
                            Text("Cancelled")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .foregroundStyle(.red)
                                .bold()
                        }
                        
                        Button("Cancel") {
                            Task {
                                await connectionRequest?.cancel()
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
            } else {
                HStack {
                    Image("InterShareIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 5)
                    
                    VStack() {
                        if (connectionRequest?.getFileTransferIntent()?.fileCount == 1) {
                            Text("\(connectionRequest?.getSender().name ?? "Unknown") wants to send you \(connectionRequest?.getFileTransferIntent()?.fileName ?? "")")
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("\(connectionRequest?.getSender().name ?? "Unknown") wants to send you \(connectionRequest?.getFileTransferIntent()?.fileCount.description ?? "some") files")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                    }
                }
                
                HStack {
                    Button("Decline") {
                        connectionRequest?.decline()
                        close()
                    }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    
                    Button("Accept") {
                        connectionRequest?.setProgressDelegate(delegate: receiveProgress)
                        self.receiveProgress.completionHandler = {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                close()
                            }
                        }

                        Thread {
                            let _ = connectionRequest?.accept()
                        }.start()
                        
                        showProgress = true
                        
                        withAnimation(Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)) {
                            dynamicWidth = 190
                        }
                    }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }
            }
        }
        .frame(width: dynamicWidth)
        .animation(Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7), value: dynamicWidth)
    }
}

#Preview {
    ConnectionRequestView(connectionRequest: nil, {})
}
#endif
