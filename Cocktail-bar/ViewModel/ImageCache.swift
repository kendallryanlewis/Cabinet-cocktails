//
//  ImageCache.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import SwiftUI

/// Image cache manager using NSCache for efficient memory management
class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    
    private init() {
        // Configure cache limits
        cache.countLimit = 200 // Maximum 200 images in memory
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB memory limit
        
        // Set up disk cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDir.appendingPathComponent("ImageCache")
        
        // Create directory if needed
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Get cached image from memory or disk
    func get(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // Check disk cache
        let fileURL = diskCacheURL(for: key)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            // Store in memory for faster access next time
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    /// Store image in memory and disk cache
    func set(_ image: UIImage, forKey key: String) {
        // Store in memory cache
        cache.setObject(image, forKey: key as NSString)
        
        // Store in disk cache
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileURL = diskCacheURL(for: key)
            try? data.write(to: fileURL)
        }
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }
    
    private func diskCacheURL(for key: String) -> URL {
        let filename = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return diskCacheDirectory.appendingPathComponent(filename)
    }
}

/// Cached AsyncImage view with built-in caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = ImageCache.shared.get(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            
            guard let data = data,
                  let downloadedImage = UIImage(data: data) else {
                return
            }
            
            // Cache the image
            ImageCache.shared.set(downloadedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 0.2)) {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

// Convenience extension for simple usage
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { Color.gray.opacity(0.2) }
        )
    }
}
