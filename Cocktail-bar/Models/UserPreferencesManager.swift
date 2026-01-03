//
//  UserPreferencesManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation

// MARK: - User Preferences
struct UserPreferences: Codable {
    var favoriteSpirits: [String]
    var dislikedIngredients: [String]
    var allergies: [String]
    var preferredStrength: DrinkStrength
    var preferredGlasses: [String]
    var dietaryRestrictions: [DietaryRestriction]
    var experienceLevel: DifficultyLevel
    
    enum DrinkStrength: String, Codable, CaseIterable {
        case light = "Light"
        case medium = "Medium"
        case strong = "Strong"
        case veryStrong = "Very Strong"
    }
    
    enum DietaryRestriction: String, Codable, CaseIterable {
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case sugarFree = "Sugar-Free"
        case lowCalorie = "Low Calorie"
    }
    
    static let `default` = UserPreferences(
        favoriteSpirits: [],
        dislikedIngredients: [],
        allergies: [],
        preferredStrength: .medium,
        preferredGlasses: [],
        dietaryRestrictions: [],
        experienceLevel: .beginner
    )
}

// MARK: - User Preferences Manager
@MainActor
class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    @Published var preferences: UserPreferences
    
    private let storageKey = "user_preferences"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = .default
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addFavoriteSpirit(_ spirit: String) {
        if !preferences.favoriteSpirits.contains(spirit) {
            preferences.favoriteSpirits.append(spirit)
            save()
        }
    }
    
    func removeFavoriteSpirit(_ spirit: String) {
        preferences.favoriteSpirits.removeAll { $0 == spirit }
        save()
    }
    
    func addAllergy(_ ingredient: String) {
        if !preferences.allergies.contains(ingredient) {
            preferences.allergies.append(ingredient)
            save()
        }
    }
    
    func filterCocktailsByPreferences(_ cocktails: [DrinkDetails]) -> [DrinkDetails] {
        return cocktails.filter { drink in
            let ingredients = drink.getIngredients().map { $0.lowercased() }
            
            // Filter out allergies
            for allergy in preferences.allergies {
                if ingredients.contains(where: { $0.contains(allergy.lowercased()) }) {
                    return false
                }
            }
            
            // Filter out disliked ingredients
            for disliked in preferences.dislikedIngredients {
                if ingredients.contains(where: { $0.contains(disliked.lowercased()) }) {
                    return false
                }
            }
            
            return true
        }
    }
}
