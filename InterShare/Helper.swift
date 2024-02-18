//
//  Helper.swift
//  InterShare
//
//  Created by Julian Baumann on 31.01.24.
//

import Foundation

func toHumanReadableSize(bytes: UInt64?) -> String {
    guard let bytes = bytes, bytes != 0 else {
        return "0 B"
    }

    let units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"]
    let digitGroups = Int(log10(Double(bytes)) / log10(1024.0))

    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.numberStyle = .decimal

    let size = Double(bytes) / pow(1024.0, Double(digitGroups))
    let formattedSize = numberFormatter.string(from: NSNumber(value: size)) ?? "N/A"

    return "\(formattedSize) \(units[digitGroups])"
}
