//
//  LocalStorageManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

// Define a class to manage local storage operations
class LocalStorageManager {
    static let shared = LocalStorageManager() // Singleton instance
    
    private let activeKey = "ActiveUser" // Key for UserDefaults
    private let UserKey = "User" // Key for UserDefaults
    private let topShelfKey = "TopShelf" // Key for UserDefaults
    private let favoritesKey = "Favorites" // Key for UserDefaults
    private let showHomeWeb = "ShowHomeWeb" // Key for UserDefaults
    
    // In-memory caches to reduce UserDefaults access
    private var topShelfCache: [String]?
    private var favoritesCache: [Ingredient]?
    private var userCache: User?
    private var activeUserCache: Bool?
    private var welcomeCache: Bool?
    
    func setActiveUser(isLoggedIn: Bool){
        activeUserCache = isLoggedIn
        UserDefaults.standard.set(isLoggedIn, forKey: activeKey)
    }
    
    func getActiveUser() -> Bool{
        if let cached = activeUserCache {
            return cached
        }
        if UserDefaults.standard.object(forKey: activeKey) != nil {
            let value = UserDefaults.standard.bool(forKey: activeKey)
            activeUserCache = value
            return value
        } else {
            activeUserCache = false
            return false
        }
    }
    
    func showWelcome(show: Bool) {
        welcomeCache = show
        UserDefaults.standard.set(show, forKey: showHomeWeb)
    }

    func getWelcome() -> Bool {
        if let cached = welcomeCache {
            return cached
        }
        if UserDefaults.standard.object(forKey: showHomeWeb) != nil {
            let value = UserDefaults.standard.bool(forKey: showHomeWeb)
            welcomeCache = value
            return value
        } else {
            welcomeCache = true
            return true
        }
    }
    
    // Function to retrieve items from local storage with caching
    func retrieveTopShelfItems() -> [String] {
        if let cached = topShelfCache {
            return cached
        }
        
        if let data = UserDefaults.standard.data(forKey: topShelfKey) {
            if let decodedItems = try? JSONDecoder().decode([String].self, from: data) {
                topShelfCache = decodedItems
                return decodedItems
            }
        }
        topShelfCache = []
        return []
    }
    
    // Function to save items to local storage
    func saveTopShelfItems(_ items: [String]) {
        topShelfCache = items
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: topShelfKey)
        }
    }
    
    func addTopShelfItem(newItem: String) {
        var items = retrieveTopShelfItems()
        items.append(newItem)
        saveTopShelfItems(items)
    }
    
    // Function to remove items from local storage
    func removeTopShelfItem(at index: Int) {
        var items = retrieveTopShelfItems()
        items.remove(at: index)
        saveTopShelfItems(items)
    }
    
    /* Drink Favorites*/
    func retrieveFavoriteItems() -> [Ingredient] {
        // Performance: Return cached value immediately if available
        if let cached = favoritesCache {
            return cached
        }
        
        // Performance: Decode in background if possible
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decodedItems = try? JSONDecoder().decode([Ingredient].self, from: data) {
                favoritesCache = decodedItems
                return decodedItems
            }
        }
        favoritesCache = []
        return []
    }
    
    // Function to save items to local storage
    func saveFavoriteItems(_ items: [Ingredient]) {
        favoritesCache = items
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
        Task { @MainActor in
            DrinkManager.shared.onlyYourIngredients() //reset drinks
            DrinkManager.shared.signatureCocktails = LocalStorageManager.shared.retrieveFavoriteItems()
        }
    }
    
    func addFavoriteItem(newItem: Ingredient) {
        var items = retrieveFavoriteItems()
        items.append(newItem)
        saveFavoriteItems(items)
    }
    
    // Function to remove items from local storage
    func removeFavoriteItem(at index: Int) {
        var items = retrieveFavoriteItems()
        items.remove(at: index)
        saveFavoriteItems(items)
    }
    
    /* Login system */
    // Function to retrieve items from local storage with caching
    func retrieveUser() -> User {
        if let cached = userCache {
            return cached
        }
        
        if let data = UserDefaults.standard.data(forKey: UserKey) {
            if let decodedItems = try? JSONDecoder().decode(User.self, from: data) {
                userCache = decodedItems
                return decodedItems
            }
        }
        let defaultUser = User(uid: "", email: "", profileImageUrl: "", username: "", password: "", isLoggedIn: false)
        userCache = defaultUser
        return defaultUser
    }
    
    // Function to save items to local storage
    func saveUser(_ user: User) {
        userCache = user
        if let encodedData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedData, forKey: UserKey)
            setActiveUser(isLoggedIn: true)
        }
    }
    
    func deleteUser() {
        userCache = nil
        topShelfCache = nil
        favoritesCache = nil
        activeUserCache = nil
        
        // Remove a value for a specific key from UserDefaults
        UserDefaults.standard.removeObject(forKey: UserKey)
        
        // To remove all values from UserDefaults, you can reset it
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        setActiveUser(isLoggedIn: false)
    }
}
