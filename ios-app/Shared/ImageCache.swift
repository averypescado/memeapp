///
//  ImageCache.swift
//  Cache images locally for keyboard extension
//

import UIKit

class ImageCache {
    static let shared = ImageCache()

    private let cacheDirectory: URL?
    private let memoryCache = NSCache<NSString, UIImage>()

    init() {
        // Use App Group container for shared storage
        if let containerURL = AppGroup.containerURL {
            cacheDirectory = containerURL.appendingPathComponent("ImageCache", isDirectory: true)

            // Create cache directory if it doesn't exist
            try? FileManager.default.createDirectory(at: cacheDirectory!, withIntermediateDirectories: true)
        } else {
            cacheDirectory = nil
            print("Warning: Could not access App Group container")
        }

        // Configure memory cache
        memoryCache.countLimit = 50 // Keep 50 images in memory
    }

    // Save image to disk and memory cache
    func saveImage(_ image: UIImage, forKey key: String) {
        // Save to memory cache
        memoryCache.setObject(image, forKey: key as NSString)

        // Save to disk cache
        guard let cacheDirectory = cacheDirectory else { return }
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
        }
    }

    // Load image from memory or disk cache
    func loadImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }

        // Try loading from disk
        guard let cacheDirectory = cacheDirectory else { return nil }
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")

        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Add to memory cache
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }

        return nil
    }

    // Load image from base64 data URL
    func imageFromDataURL(_ dataURL: String) -> UIImage? {
        // Remove data URL prefix if present
        var base64String = dataURL
        if let range = dataURL.range(of: "base64,") {
            base64String = String(dataURL[range.upperBound...])
        }

        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return UIImage(data: data)
    }

    // Clear all cached images
    func clearCache() {
        memoryCache.removeAllObjects()

        guard let cacheDirectory = cacheDirectory else { return }
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // Get cache size in bytes
    func getCacheSize() -> Int64 {
        guard let cacheDirectory = cacheDirectory else { return 0 }

        var size: Int64 = 0
        if let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        return size
    }
}
