//
//  GalleryService.swift
//  InterShare
//
//  Created by Julian Baumann on 28.12.24.
//
#if os(iOS)

import UIKit
import Photos

class MediaSaver {
    func isPhoto(filePath: String) -> Bool {
        let photoExtensions = ["jpg", "jpeg", "png", "heic", "heif", "bmp", "tiff", "tif", "webp"]
        return photoExtensions.contains { filePath.lowercased().hasSuffix(".\($0)") }
    }

    func isGIF(filePath: String) -> Bool {
        return filePath.lowercased().hasSuffix(".gif")
    }

    func isVideo(filePath: String) -> Bool {
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "wmv", "flv", "webm"]
        return videoExtensions.contains { filePath.lowercased().hasSuffix(".\($0)") }
    }
    
    public func save(files: [String], completion: @escaping (String?) -> Void) {
        for filePath in files {
            let fileURL = URL(fileURLWithPath: filePath)
            // Determine if the file is a photo, GIF, or video based on its extension
            if isPhoto(filePath: filePath) || isGIF(filePath: filePath) {
                saveImageFromFile(fileURL: fileURL) { id, error in
                    if id != nil {
                        print("Image saved successfully!")
                        
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                            print("File removed: \(fileURL.path)")
                        } catch {
                            print("Failed to remove file: \(fileURL.path), error: \(error.localizedDescription)")
                        }
                        
                        completion(id)
                    } else {
                        print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                        completion(nil)
                    }
                }
            } else if isVideo(filePath: filePath) {
                saveVideoFromFile(fileURL: fileURL) { id, error in
                    if id != nil {
                        print("Image saved successfully!")
                        
                        do {
                            try FileManager.default.removeItem(at: fileURL)
                            print("File removed: \(fileURL.path)")
                        } catch {
                            print("Failed to remove file: \(fileURL.path), error: \(error.localizedDescription)")
                        }
                        
                        completion(id)
                    } else {
                        print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                        completion(nil)
                    }
                }
            } else {
                print("Skipped unsupported file type: \(filePath)")
                completion(nil)
            }
        }
    }
    
    // Save an image to the Photos app
    func saveImageFromFile(fileURL: URL, completion: @escaping (String?, Error?) -> Void) {
        guard let image = UIImage(contentsOfFile: fileURL.path) else {
            completion(nil, NSError(domain: "InvalidImageData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to process image data"]))
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                completion(nil, NSError(domain: "PhotosPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"]))
                return
            }
            
            var localIdentifier: String?
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                localIdentifier = request.placeholderForCreatedAsset?.localIdentifier

            } completionHandler: { success, error in
                if success, let localIdentifier {
                    completion(localIdentifier, error)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    // Save a video to the Photos app
    func saveVideoFromFile(fileURL: URL, completion: @escaping (String?, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                completion(nil, NSError(domain: "PhotosPermission", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"]))
                return
            }
            
            var localIdentifier: String?
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
            } completionHandler: { success, error in
                if success, let localIdentifier {
                    completion(localIdentifier, error)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
}

#endif
