//
//  CustomRecipeManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Custom Recipe
struct CustomRecipe: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: String
    var glass: String
    var instructions: String
    var ingredients: [RecipeIngredient]
    var imageData: Data?
    var difficulty: DifficultyLevel
    var prepTime: Int // minutes
    var createdDate: Date
    var lastModified: Date
    var tags: [String]
    var isPublic: Bool
    
    init(id: UUID = UUID(), name: String, category: String, glass: String, instructions: String, ingredients: [RecipeIngredient], imageData: Data? = nil, difficulty: DifficultyLevel = .beginner, prepTime: Int = 5, tags: [String] = [], isPublic: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.glass = glass
        self.instructions = instructions
        self.ingredients = ingredients
        self.imageData = imageData
        self.difficulty = difficulty
        self.prepTime = prepTime
        self.createdDate = Date()
        self.lastModified = Date()
        self.tags = tags
        self.isPublic = isPublic
    }
}

// MARK: - Recipe Ingredient
struct RecipeIngredient: Identifiable, Codable {
    let id: UUID
    var name: String
    var measurement: String
    
    init(id: UUID = UUID(), name: String, measurement: String) {
        self.id = id
        self.name = name
        self.measurement = measurement
    }
}

// MARK: - Custom Recipe Manager
@MainActor
class CustomRecipeManager: ObservableObject {
    static let shared = CustomRecipeManager()
    
    @Published var recipes: [CustomRecipe] = []
    
    private let storageKey = "custom_recipes"
    
    private init() {
        loadRecipes()
    }
    
    func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CustomRecipe].self, from: data) {
            recipes = decoded
        }
    }
    
    func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addRecipe(_ recipe: CustomRecipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: CustomRecipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            var updated = recipe
            updated.lastModified = Date()
            recipes[index] = updated
            saveRecipes()
        }
    }
    
    func deleteRecipe(_ recipe: CustomRecipe) {
        recipes.removeAll { $0.id == recipe.id }
        saveRecipes()
    }
    
    func searchRecipes(query: String) -> [CustomRecipe] {
        guard !query.isEmpty else { return recipes }
        return recipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(query) ||
            recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
}
