//
//  ViewExtension.swift
//  InterShare
//
//  Created by Julian Baumann on 15.02.23.
//

import Foundation
import SwiftUI

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
