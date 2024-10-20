//
//  Helper.swift
//  InterShare
//
//  Created by Julian Baumann on 31.01.24.
//

import Foundation
import SwiftUI
import PhotosUI

var temporaryDirectory: URL = FileManager.default.temporaryDirectory

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

func getURL(photo item: PhotosPickerItem, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
    item.loadTransferable(type: Data.self) { result in
        switch result {
        case .success(let data):
            if let contentType = item.supportedContentTypes.first {

                if let data = data {
                    do {
                        let url = temporaryDirectory.appendingPathComponent("\(UUID().uuidString).\(contentType.preferredFilenameExtension ?? "")")

                        try data.write(to: url)
                        completionHandler(.success(url))
                    } catch {
                        completionHandler(.failure(error))
                    }
                }
            }
        case .failure(let failure):
            completionHandler(.failure(failure))
        }
    }
}

func getURL(item: NSItemProvider, completionHandler: @escaping (_ result: Result<URL, Error>) -> Void) {
    if item.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
        item.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (url, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }

            if let fileURL = url as? URL {
                // Use the original file name and extension
                completionHandler(.success(fileURL))
            } else if let fileURL = URL(dataRepresentation: url as! Data, relativeTo: nil) {
                completionHandler(.success(fileURL))
            } else {
                completionHandler(.failure(NSError(domain: "com.julian-baumann.InterShare", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load the file URL."])))
            }
        }
    } else {
        let contentType = item.registeredTypeIdentifiers.first
        let name = item.suggestedName ?? UUID().uuidString
        
        let _ = item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let contentType = contentType {
                    do {
                        let contentUTI = UTType(contentType)
                        let fileExtension = contentUTI?.preferredFilenameExtension ?? ""
                        let url = temporaryDirectory.appendingPathComponent("\(name).\(fileExtension)")

                        try data.write(to: url)
                        completionHandler(.success(url))
                    } catch {
                        completionHandler(.failure(error))
                    }
                }
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
}
