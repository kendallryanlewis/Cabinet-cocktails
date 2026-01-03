//
//  ShoppingList.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import Foundation

enum IngredientCategory: String, Codable, CaseIterable {
    case spirits = "Spirits"
    case liqueurs = "Liqueurs"
    case mixers = "Mixers"
    case garnishes = "Garnishes"
    case bitters = "Bitters"
    case other = "Other"
    
    static func categorize(_ ingredient: String) -> IngredientCategory {
        let lowercased = ingredient.lowercased()
        
        // Spirits
        if lowercased.contains("vodka") || lowercased.contains("gin") || 
           lowercased.contains("rum") || lowercased.contains("whiskey") || 
           lowercased.contains("tequila") || lowercased.contains("bourbon") ||
           lowercased.contains("scotch") || lowercased.contains("brandy") {
            return .spirits
        }
        
        // Liqueurs
        if lowercased.contains("liqueur") || lowercased.contains("schnapps") ||
           lowercased.contains("amaretto") || lowercased.contains("triple sec") ||
           lowercased.contains("cointreau") || lowercased.contains("baileys") ||
           lowercased.contains("kahlua") || lowercased.contains("vermouth") {
            return .liqueurs
        }
        
        // Mixers
        if lowercased.contains("juice") || lowercased.contains("soda") ||
           lowercased.contains("tonic") || lowercased.contains("water") ||
           lowercased.contains("syrup") || lowercased.contains("cola") ||
           lowercased.contains("ginger ale") || lowercased.contains("cream") {
            return .mixers
        }
        
        // Garnishes
        if lowercased.contains("cherry") || lowercased.contains("olive") ||
           lowercased.contains("lemon") || lowercased.contains("lime") ||
           lowercased.contains("orange") || lowercased.contains("mint") ||
           lowercased.contains("salt") || lowercased.contains("sugar") {
            return .garnishes
        }
        
        // Bitters
        if lowercased.contains("bitters") {
            return .bitters
        }
        
        return .other
    }
}

// MARK: - Shopping List Model
struct ShoppingList: Codable {
    let createdDate: Date
    let lastUpdated: Date
    let items: [ShoppingListItem]
    
    init(items: [ShoppingListItem], createdDate: Date = Date(), lastUpdated: Date = Date()) {
        self.items = items
        self.createdDate = createdDate
        self.lastUpdated = lastUpdated
    }
}

struct ShoppingListItem: Identifiable, Codable, Hashable {
    let id: UUID
    let ingredient: String
    let category: IngredientCategory
    var isChecked: Bool
    let cocktails: [String] // Cocktails that need this ingredient
    let dateAdded: Date
    
    init(ingredient: String, cocktails: [String] = []) {
        self.id = UUID()
        self.ingredient = ingredient
        self.category = IngredientCategory.categorize(ingredient)
        self.isChecked = false
        self.cocktails = cocktails
        self.dateAdded = Date()
    }
}

@MainActor
class ShoppingListManager: ObservableObject {
    static let shared = ShoppingListManager()
    
    @Published var items: [ShoppingListItem] = []
    
    private let storageKey = "ShoppingListItems"
    
    private init() {
        loadItems()
    }
    
    // MARK: - Export Helper
    
    var asShoppingList: ShoppingList {
        let createdDate = items.map { $0.dateAdded }.min() ?? Date()
        let lastUpdated = Date()
        return ShoppingList(items: items, createdDate: createdDate, lastUpdated: lastUpdated)
    }
    
    // MARK: - Core Functions
    
    func addItem(ingredient: String, fromCocktails cocktails: [String] = []) {
        // Check if ingredient already exists
        if let existingIndex = items.firstIndex(where: { $0.ingredient.lowercased() == ingredient.lowercased() }) {
            // Merge cocktails if item exists
            var updated = items[existingIndex]
            let allCocktails = Set(updated.cocktails + cocktails)
            items[existingIndex] = ShoppingListItem(
                ingredient: updated.ingredient,
                cocktails: Array(allCocktails)
            )
        } else {
            let newItem = ShoppingListItem(ingredient: ingredient, cocktails: cocktails)
            items.append(newItem)
        }
        saveItems()
    }
    
    func toggleChecked(item: ShoppingListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = ShoppingListItem(
                ingredient: item.ingredient,
                cocktails: item.cocktails
            )
            var updated = items[index]
            items[index] = ShoppingListItem(ingredient: updated.ingredient, cocktails: updated.cocktails)
            // Toggle manually
            if let idx = items.firstIndex(where: { $0.id == item.id }) {
                var modified = items[idx]
                items.remove(at: idx)
                let toggled = ShoppingListItem(ingredient: modified.ingredient, cocktails: modified.cocktails)
                items.insert(toggled, at: idx)
            }
            saveItems()
        }
    }
    
    func removeItem(item: ShoppingListItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func removeCheckedItems() {
        items.removeAll { $0.isChecked }
        saveItems()
    }
    
    func clearAll() {
        items.removeAll()
        saveItems()
    }
    
    // MARK: - Auto-Generate from Almost There Cocktails
    
    func generateFromAlmostThere() {
        guard let allDrinks = DrinkManager.shared.allDrinks else { return }
        
        let cabinetIngredients = Set(LocalStorageManager.shared.retrieveTopShelfItems().map { $0.lowercased() })
        let perfectMatches = DrinkManager.shared.myDrinkPossibilities ?? []
        
        // Find "Almost There" cocktails (missing 1-2 ingredients)
        let almostThere = allDrinks.filter { drink in
            let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            let missing = drinkIngredients.subtracting(cabinetIngredients)
            return missing.count >= 1 && missing.count <= 2 && !perfectMatches.contains(drink)
        }.prefix(15)
        
        // Group missing ingredients by cocktail
        var ingredientToCocktails: [String: [String]] = [:]
        
        for drink in almostThere {
            let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            let missing = drinkIngredients.subtracting(cabinetIngredients)
            
            for ingredient in missing {
                if ingredientToCocktails[ingredient] == nil {
                    ingredientToCocktails[ingredient] = []
                }
                ingredientToCocktails[ingredient]?.append(drink.strDrink)
            }
        }
        
        // Add to shopping list
        for (ingredient, cocktails) in ingredientToCocktails {
            addItem(ingredient: ingredient, fromCocktails: cocktails)
        }
    }
    
    // MARK: - Grouping
    
    func groupedItems() -> [(category: IngredientCategory, items: [ShoppingListItem])] {
        let grouped = Dictionary(grouping: items) { $0.category }
        return IngredientCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.ingredient < $1.ingredient })
        }
    }
    
    // MARK: - Sharing
    
    func shareText() -> String {
        var text = "🍸 Cabinet Cocktails Shopping List\n\n"
        
        for (category, items) in groupedItems() {
            text += "\(category.rawValue):\n"
            for item in items {
                let checkmark = item.isChecked ? "✓" : "○"
                text += "  \(checkmark) \(item.ingredient)"
                if !item.cocktails.isEmpty {
                    text += " (for \(item.cocktails.joined(separator: ", ")))"
                }
                text += "\n"
            }
            text += "\n"
        }
        
        return text
    }
    
    // MARK: - Persistence
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ShoppingListItem].self, from: data) {
            items = decoded
        }
    }
}
