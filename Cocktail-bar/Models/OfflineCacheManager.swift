//
//  OfflineCacheManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation
import SwiftUI
import SystemConfiguration

// MARK: - Cache Status
enum CacheStatus {
    case cached
    case downloading
    case failed
    case notCached
}

// MARK: - Sync Status
enum SyncStatus {
    case synced
    case syncing
    case needsSync
    case offline
}

// MARK: - Cached Cocktail Data
struct CachedCocktail: Codable {
    let cocktail: DrinkDetails
    let cachedDate: Date
    let imageData: Data?
    
    var isStale: Bool {
        let daysSinceCache = Calendar.current.dateComponents([.day], from: cachedDate, to: Date()).day ?? 0
        return daysSinceCache > 30 // Consider stale after 30 days
    }
}

// MARK: - Offline Cache Manager
@MainActor
class OfflineCacheManager: ObservableObject {
    static let shared = OfflineCacheManager()
    
    @Published var syncStatus: SyncStatus = .synced
    @Published var isOfflineMode: Bool = false
    @Published var cachedCocktailsCount: Int = 0
    @Published var lastSyncDate: Date?
    
    private let cocktailsCacheKey = "cached_cocktails"
    private let ingredientsCacheKey = "cached_ingredients"
    private let lastSyncKey = "last_sync_date"
    private let offlineModeKey = "offline_mode_enabled"
    
    private var cachedCocktails: [String: CachedCocktail] = [:]
    private var cachedIngredients: [Ingredient] = []
    
    private init() {
        loadCache()
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        // Monitor network connectivity
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NetworkStatusChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkNetworkStatus()
        }
        checkNetworkStatus()
    }
    
    private func checkNetworkStatus() {
        // Simple connectivity check
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            isOfflineMode = true
            syncStatus = .offline
            return
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            isOfflineMode = true
            syncStatus = .offline
            return
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        isOfflineMode = !isReachable || needsConnection
        if !isOfflineMode && syncStatus == .needsSync {
            Task {
                await syncWithServer()
            }
        }
    }
    
    // MARK: - Cache Management
    
    func cacheCocktail(_ cocktail: DrinkDetails, imageURL: String? = nil) async {
        var imageData: Data?
        
        // Download and cache image if URL provided
        if let urlString = imageURL ?? cocktail.strDrinkThumb,
           let url = URL(string: urlString) {
            imageData = try? await URLSession.shared.data(from: url).0
        }
        
        let cached = CachedCocktail(
            cocktail: cocktail,
            cachedDate: Date(),
            imageData: imageData
        )
        
        cachedCocktails[cocktail.idDrink] = cached
        cachedCocktailsCount = cachedCocktails.count
        saveCache()
    }
    
    func getCachedCocktail(_ id: String) -> CachedCocktail? {
        return cachedCocktails[id]
    }
    
    func isCocktailCached(_ id: String) -> Bool {
        return cachedCocktails[id] != nil
    }
    
    func getCacheStatus(for id: String) -> CacheStatus {
        if let cached = cachedCocktails[id] {
            return cached.isStale ? .failed : .cached
        }
        return .notCached
    }
    
    func removeCachedCocktail(_ id: String) {
        cachedCocktails.removeValue(forKey: id)
        cachedCocktailsCount = cachedCocktails.count
        saveCache()
    }
    
    func clearCache() {
        cachedCocktails.removeAll()
        cachedIngredients.removeAll()
        cachedCocktailsCount = 0
        saveCache()
    }
    
    func cacheAllFavorites(_ favorites: [DrinkDetails]) async {
        syncStatus = .syncing
        
        for cocktail in favorites {
            await cacheCocktail(cocktail)
        }
        
        syncStatus = .synced
        lastSyncDate = Date()
        saveLastSyncDate()
    }
    
    func cacheIngredients(_ ingredients: [Ingredient]) {
        cachedIngredients = ingredients
        saveCache()
    }
    
    func getCachedIngredients() -> [Ingredient] {
        return cachedIngredients
    }
    
    // MARK: - Sync
    
    func syncWithServer() async {
        guard !isOfflineMode else {
            syncStatus = .offline
            return
        }
        
        syncStatus = .syncing
        
        // Refresh stale cocktails
        let staleCocktails = cachedCocktails.values.filter { $0.isStale }
        for cached in staleCocktails {
            // Re-download cocktail data
            if let freshCocktail = try? await fetchCocktailFromServer(cached.cocktail.idDrink) {
                await cacheCocktail(freshCocktail)
            }
        }
        
        syncStatus = .synced
        lastSyncDate = Date()
        saveLastSyncDate()
    }
    
    private func fetchCocktailFromServer(_ id: String) async throws -> DrinkDetails? {
        let urlString = API_URL + "lookup.php?i=\(id)"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DrinkResponse.self, from: data)
        return response.drinks?.first
    }
    
    // MARK: - Persistence
    
    private func saveCache() {
        // Save cocktails
        if let cocktailsData = try? JSONEncoder().encode(cachedCocktails) {
            UserDefaults.standard.set(cocktailsData, forKey: cocktailsCacheKey)
        }
        
        // Save ingredients
        if let ingredientsData = try? JSONEncoder().encode(cachedIngredients) {
            UserDefaults.standard.set(ingredientsData, forKey: ingredientsCacheKey)
        }
    }
    
    private func loadCache() {
        // Load cocktails
        if let cocktailsData = UserDefaults.standard.data(forKey: cocktailsCacheKey),
           let decoded = try? JSONDecoder().decode([String: CachedCocktail].self, from: cocktailsData) {
            cachedCocktails = decoded
            cachedCocktailsCount = decoded.count
        }
        
        // Load ingredients
        if let ingredientsData = UserDefaults.standard.data(forKey: ingredientsCacheKey),
           let decoded = try? JSONDecoder().decode([Ingredient].self, from: ingredientsData) {
            cachedIngredients = decoded
        }
        
        // Load last sync date
        if let syncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date {
            lastSyncDate = syncDate
        }
    }
    
    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
    }
    
    // MARK: - Cache Statistics
    
    func getCacheSize() -> String {
        let cocktailsSize = (try? JSONEncoder().encode(cachedCocktails))?.count ?? 0
        let ingredientsSize = (try? JSONEncoder().encode(cachedIngredients))?.count ?? 0
        let totalBytes = cocktailsSize + ingredientsSize
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalBytes))
    }
    
    func getStaleCount() -> Int {
        return cachedCocktails.values.filter { $0.isStale }.count
    }
    
    func getCachedImageCount() -> Int {
        return cachedCocktails.values.filter { $0.imageData != nil }.count
    }
}

// MARK: - DrinkResponse Helper
private struct DrinkResponse: Codable {
    let drinks: [DrinkDetails]?
}
