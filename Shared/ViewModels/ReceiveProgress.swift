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
    @Published var numericProgress: CGFloat = 0
    public var completionHandler: () -> Void = { }
    
    init(completionHandler: @escaping () -> Void = {}) {
        self.completionHandler = completionHandler
    }
    
    func progressChanged(progress: ReceiveProgressState) {
        DispatchQueue.main.async {
            self.state = progress
            
            if case .receiving(let currentProgress) = progress {
                self.numericProgress = CGFloat(currentProgress)
            } else if case .finished = progress {
                self.numericProgress = CGFloat(1.0)
                self.completionHandler()
            } else if case .cancelled = progress {
                self.completionHandler()
            }
        }
    }
}
