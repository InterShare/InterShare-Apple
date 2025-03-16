//
//  ViewExtensions.swift
//  InterShare
//
//  Created by Julian Baumann on 08.02.25.
//

import SwiftUI

extension View {
    public func applySafeAreaPadding() -> some View {
#if os(iOS)
        if #available(iOS 17.0, *) {
            return self.safeAreaPadding(.vertical)
        } else {
            return self.padding(.bottom, 20)
        }
#else
        return self
#endif
    }
}
