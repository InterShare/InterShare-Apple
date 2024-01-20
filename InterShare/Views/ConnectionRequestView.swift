//
//  ConnectionRequestView.swift
//  InterShare
//
//  Created by Julian Baumann on 16.01.24.
//

import SwiftUI

struct ConnectionRequestView: View {
    var body: some View {
        NavigationView {
            VStack {                
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.indigo)
                        .font(.system(size: 50))
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Julians Android Device wants to share")
                        Text("LargeFile.mov (42.34 GB)")
                            .bold()
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Decline")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .tint(Color.red)
                .buttonStyle(.bordered)
                
                Button(action: {}) {
                    Text("Accept")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .tint(Color.green)
                .buttonStyle(.bordered)
            }.padding()
        }.navigationTitle("Connection Request")
    }
}

#Preview {
    NavigationStack {
        ConnectionRequestView()
    }
}
