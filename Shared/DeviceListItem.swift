//
//  DeviceInfoListView.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import Foundation
import SwiftUI
import DataRCT

struct DeviceInfoListView: View {
    @State public var deviceInfo: Device
    @StateObject public var progress: SendProgress
    
    func getDeviceType() -> String {
        if deviceInfo.deviceType == DeviceType.desktop.rawValue {
            return "PC"
        }
        
        if deviceInfo.deviceType == DeviceType.mobile.rawValue {
            return "Phone"
        }
        
        if deviceInfo.deviceType == DeviceType.tablet.rawValue {
            return "Tablet"
        }

        return "Unknown"
    }
    
    func getColor(_ progress: SendProgress) -> Color {
        switch(progress.state) {
        case .unknown:
            break
        case .connecting:
            break
        case .requesting:
            break
        case .connectionMediumUpdate(medium: _):
            break
        case .transferring(progress: _):
            return .purple
        case .cancelled:
            return .red
        case .finished:
            return .green
        case .declined:
            return .red
        }
        
        return Color(red: 0, green: 0, blue: 0, opacity: 0.0)
    }
    
    var body: some View {
        VStack() {
            ZStack {
                Circle()
                    .fill(.linearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                #if os(macOS)
                    .frame(width: 45, height: 45)
                #else
                    .frame(width: 60, height: 60)
                #endif

                CircularProgressView(
                    progress: {
                        if case .transferring(let progress) = progress.state {
                            progress
                        } else if progress.state == .finished {
                            1.0
                        } else if progress.state == .declined {
                            1.0
                        } else if progress.state == .cancelled {
                            1.0
                        } else {
                            0.0
                        }
                    }(),
                    color: getColor(progress)
                )
#if os(macOS)
                .frame(width: 55, height: 55)
            #else
                .frame(width: 70, height: 70)
            #endif
                
                .overlay(Group {
                    ZStack {
                        if let medium = progress.medium {
                            if medium == .wiFi {
                                Image(systemName: "wifi.circle.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .blue)
                                    .font(.system(size: 20))
                            } else if medium == .ble {
                                Image("Bluetooth")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                })
                
                if progress.state == .requesting || progress.state == .connecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    #if os(macOS)
                        .controlSize(.small)
                    #else
                        .controlSize(.regular)
                    #endif
                } else {
                    Text(deviceInfo.name.first?.uppercased() ?? "")
                        .foregroundStyle(.white)
                    #if os(macOS)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    #else
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    #endif
                }
            }
            .padding(.top, 5)
            
            Text(deviceInfo.name)
                .lineLimit(2)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .opacity(0.8)
                .foregroundColor(.primary)
                .frame(maxWidth: 90)
                .truncationMode(.tail)
            
//            Text(getDeviceType())
//                .lineLimit(1)
//                .font(.system(size: 13, weight: .regular, design: .rounded))
//                .opacity(0.5)
//                .foregroundColor(.primary)
//                .frame(maxWidth: 90)
//                .truncationMode(.tail)
        }
    }
}

struct DeviceInfoListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], alignment: .leading, spacing: 15) {
                Button(action: {}) {
                    DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Phone", deviceType: 0), progress: SendProgress())
                }
                .buttonStyle(.bordered)
                .frame(maxHeight: .infinity, alignment: .top)
                
                Button(action: {}) {
                    DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My PC", deviceType: 1), progress: SendProgress())
                }
                .buttonStyle(.bordered)
                .frame(maxHeight: .infinity, alignment: .top)
                
                Button(action: {}) {
                    DeviceInfoListView(deviceInfo: Device(id: UUID().uuidString, name: "My Android Device Here", deviceType: 2), progress: SendProgress())
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .buttonStyle(.bordered)
            }
            .buttonStyle(.plain)
            .padding()
        }
    }
}
