//
//  LocationStorageManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

// Define a class to manage local storage operations
class LocalStorageManager {
    static let shared = LocalStorageManager() // Singleton instance
    
    private let activeUser = "true" // Key for UserDefaults
    private let UserKey = "User" // Key for UserDefaults
    private let topShelfKey = "TopShelf" // Key for UserDefaults
    private let favoritesKey = "Favorites" // Key for UserDefaults
    
    // Function to retrieve items from local storage
    func retrieveTopShelfItems() -> [String] {
        // Retrieve Data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: topShelfKey) {
            // Decode Data to [Item]
            if let decodedItems = try? JSONDecoder().decode([String].self, from: data) {
                return decodedItems
            }
        }
        return [] // Return an empty array if no data found
    }
    
    // Function to save items to local storage
    func saveTopShelfItems(_ items: [String]) {
        // Convert items to Data
        if let encodedData = try? JSONEncoder().encode(items) {
            // Save Data to UserDefaults
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
        // Retrieve Data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            // Decode Data to [Item]
            if let decodedItems = try? JSONDecoder().decode([Ingredient].self, from: data) {
                return decodedItems
            }
        }
        return [] // Return an empty array if no data found
    }
    
    // Function to save items to local storage
    func saveFavoriteItems(_ items: [Ingredient]) {
        // Convert items to Data
        if let encodedData = try? JSONEncoder().encode(items) {
            // Save Data to UserDefaults
            UserDefaults.standard.set(encodedData, forKey: favoritesKey)
        }
        DrinkManager.shared.onlyYourIngredients() //reset drinks
        DrinkManager.shared.signatureCocktails = LocalStorageManager.shared.retrieveFavoriteItems()
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
    // Function to retrieve items from local storage
    func retrieveUser() -> User {
        // Retrieve Data from UserDefaults
        if let data = UserDefaults.standard.data(forKey: UserKey) {
            if let decodedItems = try? JSONDecoder().decode(User.self, from: data) {
                return decodedItems
            }
        }
        return User(uid: "", email: "", profileImageUrl: "", username: "", password: "", isLoggedIn: false)
    }
    
    // Function to save items to local storage
    func saveUser(_ user: User) {
        // Convert items to Data
        if let encodedData = try? JSONEncoder().encode(user) {
            // Save Data to UserDefaults
            UserDefaults.standard.set(encodedData, forKey: UserKey)
        }
    }
    
    func deleteUser() {
        // Remove a value for a specific key from UserDefaults
        UserDefaults.standard.removeObject(forKey: UserKey)

        // To remove all values from UserDefaults, you can reset it
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
