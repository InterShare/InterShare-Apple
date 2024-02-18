//
//  ReceiveProgress.swift
//  InterShare
//
//  Created by Julian Baumann on 31.01.24.
//

import Foundation
import DataRCT

class ReceiveProgress: ObservableObject, ReceiveProgressDelegate {
    @Published var state: ReceiveProgressState = .unknown
    
    func progressChanged(progress: ReceiveProgressState) {
        DispatchQueue.main.async {
            self.state = progress
        }
    }
}
