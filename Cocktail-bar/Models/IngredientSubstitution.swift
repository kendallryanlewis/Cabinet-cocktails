//
//  IngredientSubstitution.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import Foundation
import SwiftUI

// MARK: - Substitution Category
enum SubstitutionCategory: String, Codable, CaseIterable {
    case spirits = "Spirits"
    case liqueurs = "Liqueurs"
    case sweeteners = "Sweeteners"
    case bitters = "Bitters"
    case citrus = "Citrus"
    case dairy = "Dairy & Cream"
    case mixers = "Mixers"
    case garnish = "Garnish"
    case other = "Other"
}

// MARK: - Substitution Alternative
struct SubstitutionAlternative: Identifiable, Codable {
    let id: UUID
    let name: String
    let ratio: Double // Conversion ratio (1.0 = equal parts)
    let notes: String?
    let flavorProfile: String?
    
    init(id: UUID = UUID(), name: String, ratio: Double = 1.0, notes: String? = nil, flavorProfile: String? = nil) {
        self.id = id
        self.name = name
        self.ratio = ratio
        self.notes = notes
        self.flavorProfile = flavorProfile
    }
    
    func displayRatio() -> String {
        if ratio == 1.0 {
            return "Equal parts"
        } else if ratio < 1.0 {
            return "Use \(Int(ratio * 100))% of original amount"
        } else {
            return "Use \(String(format: "%.1f", ratio))x the amount"
        }
    }
}

// MARK: - Substitution
struct IngredientSubstitution: Identifiable, Codable {
    let id: UUID
    let originalIngredient: String
    let category: SubstitutionCategory
    let alternatives: [SubstitutionAlternative]
    let difficulty: SubstitutionDifficulty
    let preservesOriginalFlavor: Bool
    
    init(id: UUID = UUID(),
         originalIngredient: String,
         category: SubstitutionCategory,
         alternatives: [SubstitutionAlternative],
         difficulty: SubstitutionDifficulty = .easy,
         preservesOriginalFlavor: Bool = true) {
        self.id = id
        self.originalIngredient = originalIngredient
        self.category = category
        self.alternatives = alternatives
        self.difficulty = difficulty
        self.preservesOriginalFlavor = preservesOriginalFlavor
    }
}

// MARK: - Substitution Difficulty
enum SubstitutionDifficulty: String, Codable {
    case easy = "Easy" // Close substitutes, minimal flavor impact
    case moderate = "Moderate" // Similar flavor profile, some differences
    case challenging = "Challenging" // Noticeable flavor change
}

// MARK: - Substitution Suggestion
struct SubstitutionSuggestion: Identifiable {
    let id: UUID
    let missingIngredient: String
    let substitution: IngredientSubstitution
    let availableAlternatives: [SubstitutionAlternative] // Filtered by user's inventory
    let recommendedAlternative: SubstitutionAlternative? // Best match from inventory
    
    init(missingIngredient: String,
         substitution: IngredientSubstitution,
         availableAlternatives: [SubstitutionAlternative],
         recommendedAlternative: SubstitutionAlternative? = nil) {
        self.id = UUID()
        self.missingIngredient = missingIngredient
        self.substitution = substitution
        self.availableAlternatives = availableAlternatives
        self.recommendedAlternative = recommendedAlternative
    }
}

// MARK: - Substitution Manager
@MainActor
class SubstitutionManager: ObservableObject {
    static let shared = SubstitutionManager()
    
    @Published private(set) var substitutionDatabase: [IngredientSubstitution] = []
    
    private init() {
        loadSubstitutionDatabase()
    }
    
    // MARK: - Database Loading
    private func loadSubstitutionDatabase() {
        substitutionDatabase = [
            // SPIRITS - Vodka
            IngredientSubstitution(
                originalIngredient: "Vodka",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Gin", ratio: 1.0, notes: "More botanical flavor", flavorProfile: "Herbal, juniper-forward"),
                    SubstitutionAlternative(name: "White rum", ratio: 1.0, notes: "Slightly sweeter", flavorProfile: "Light, subtle sweetness"),
                    SubstitutionAlternative(name: "Tequila blanco", ratio: 1.0, notes: "Agave notes", flavorProfile: "Earthy, vegetal"),
                    SubstitutionAlternative(name: "Sake", ratio: 1.2, notes: "Lower ABV, umami notes", flavorProfile: "Delicate, rice-based")
                ],
                difficulty: .easy
            ),
            
            // SPIRITS - Gin
            IngredientSubstitution(
                originalIngredient: "Gin",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Vodka", ratio: 1.0, notes: "Loss of botanical complexity", flavorProfile: "Neutral, clean"),
                    SubstitutionAlternative(name: "Aquavit", ratio: 1.0, notes: "Caraway and dill notes", flavorProfile: "Herbal, Scandinavian spices"),
                    SubstitutionAlternative(name: "White rum", ratio: 1.0, notes: "Sweeter, less herbal", flavorProfile: "Light, sugarcane-based")
                ],
                difficulty: .moderate
            ),
            
            // SPIRITS - Rum
            IngredientSubstitution(
                originalIngredient: "White rum",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Vodka", ratio: 1.0, notes: "Less sweetness", flavorProfile: "Neutral, clean"),
                    SubstitutionAlternative(name: "Cachaça", ratio: 1.0, notes: "Grassy, more complex", flavorProfile: "Sugarcane, vegetal"),
                    SubstitutionAlternative(name: "Tequila blanco", ratio: 1.0, notes: "Agave character", flavorProfile: "Earthy, peppery")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Dark rum",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Bourbon", ratio: 1.0, notes: "Oakier, less molasses", flavorProfile: "Caramel, vanilla, oak"),
                    SubstitutionAlternative(name: "Brandy", ratio: 1.0, notes: "Fruitier notes", flavorProfile: "Grape, dried fruit"),
                    SubstitutionAlternative(name: "Añejo tequila", ratio: 1.0, notes: "Agave with oak", flavorProfile: "Smooth, aged complexity")
                ],
                difficulty: .moderate
            ),
            
            // SPIRITS - Whiskey
            IngredientSubstitution(
                originalIngredient: "Bourbon",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Rye whiskey", ratio: 1.0, notes: "Spicier, less sweet", flavorProfile: "Peppery, bold"),
                    SubstitutionAlternative(name: "Tennessee whiskey", ratio: 1.0, notes: "Similar profile", flavorProfile: "Smooth, charcoal-filtered"),
                    SubstitutionAlternative(name: "Dark rum", ratio: 1.0, notes: "Sweeter, molasses notes", flavorProfile: "Rich, tropical"),
                    SubstitutionAlternative(name: "Scotch", ratio: 1.0, notes: "Smokier, less sweet", flavorProfile: "Peaty, complex")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Rye whiskey",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Bourbon", ratio: 1.0, notes: "Sweeter, less spicy", flavorProfile: "Corn-forward, vanilla"),
                    SubstitutionAlternative(name: "Canadian whisky", ratio: 1.0, notes: "Lighter, smoother", flavorProfile: "Mild, blended")
                ],
                difficulty: .easy
            ),
            
            // SPIRITS - Tequila
            IngredientSubstitution(
                originalIngredient: "Tequila",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Mezcal", ratio: 0.75, notes: "Smokier, more complex", flavorProfile: "Smoky, earthy"),
                    SubstitutionAlternative(name: "Vodka", ratio: 1.0, notes: "Loss of agave character", flavorProfile: "Neutral, clean"),
                    SubstitutionAlternative(name: "White rum", ratio: 1.0, notes: "Sweeter, tropical", flavorProfile: "Light, sugarcane")
                ],
                difficulty: .moderate
            ),
            
            // SPIRITS - Brandy
            IngredientSubstitution(
                originalIngredient: "Brandy",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Cognac", ratio: 1.0, notes: "More refined", flavorProfile: "Elegant, grape-forward"),
                    SubstitutionAlternative(name: "Dark rum", ratio: 1.0, notes: "Molasses instead of fruit", flavorProfile: "Rich, sweet"),
                    SubstitutionAlternative(name: "Bourbon", ratio: 1.0, notes: "Grain-based, oakier", flavorProfile: "Caramel, vanilla")
                ],
                difficulty: .moderate
            ),
            
            // LIQUEURS - Orange
            IngredientSubstitution(
                originalIngredient: "Triple sec",
                category: .liqueurs,
                alternatives: [
                    SubstitutionAlternative(name: "Cointreau", ratio: 1.0, notes: "Higher quality, more refined", flavorProfile: "Premium orange, balanced"),
                    SubstitutionAlternative(name: "Grand Marnier", ratio: 0.9, notes: "Cognac base, richer", flavorProfile: "Orange with brandy depth"),
                    SubstitutionAlternative(name: "Curaçao", ratio: 1.0, notes: "Similar orange flavor", flavorProfile: "Sweet, citrus"),
                    SubstitutionAlternative(name: "Orange juice + simple syrup", ratio: 1.5, notes: "Non-alcoholic option", flavorProfile: "Fresh, fruity")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Cointreau",
                category: .liqueurs,
                alternatives: [
                    SubstitutionAlternative(name: "Triple sec", ratio: 1.0, notes: "Less refined", flavorProfile: "Basic orange, sweet"),
                    SubstitutionAlternative(name: "Grand Marnier", ratio: 0.9, notes: "Adds cognac depth", flavorProfile: "Complex, brandy-orange")
                ],
                difficulty: .easy
            ),
            
            // LIQUEURS - Coffee
            IngredientSubstitution(
                originalIngredient: "Kahlúa",
                category: .liqueurs,
                alternatives: [
                    SubstitutionAlternative(name: "Tia Maria", ratio: 1.0, notes: "Similar coffee flavor", flavorProfile: "Coffee, vanilla"),
                    SubstitutionAlternative(name: "Espresso + simple syrup + vodka", ratio: 1.0, notes: "DIY option", flavorProfile: "Fresh coffee, customizable"),
                    SubstitutionAlternative(name: "Mr. Black", ratio: 0.9, notes: "Less sweet, more coffee-forward", flavorProfile: "Bold coffee, modern")
                ],
                difficulty: .easy
            ),
            
            // LIQUEURS - Amaretto
            IngredientSubstitution(
                originalIngredient: "Amaretto",
                category: .liqueurs,
                alternatives: [
                    SubstitutionAlternative(name: "Orgeat syrup", ratio: 0.75, notes: "Non-alcoholic, almond flavor", flavorProfile: "Almond, sweet"),
                    SubstitutionAlternative(name: "Almond extract + simple syrup", ratio: 0.5, notes: "Very strong almond flavor", flavorProfile: "Intense almond"),
                    SubstitutionAlternative(name: "Frangelico", ratio: 1.0, notes: "Hazelnut instead of almond", flavorProfile: "Nutty, slightly different")
                ],
                difficulty: .moderate
            ),
            
            // SWEETENERS
            IngredientSubstitution(
                originalIngredient: "Simple syrup",
                category: .sweeteners,
                alternatives: [
                    SubstitutionAlternative(name: "Agave nectar", ratio: 0.75, notes: "More complex sweetness", flavorProfile: "Smooth, mild"),
                    SubstitutionAlternative(name: "Honey syrup", ratio: 0.75, notes: "Floral notes", flavorProfile: "Rich, aromatic"),
                    SubstitutionAlternative(name: "Maple syrup", ratio: 0.75, notes: "Distinct maple flavor", flavorProfile: "Earthy, woody"),
                    SubstitutionAlternative(name: "Demerara syrup", ratio: 1.0, notes: "Richer, molasses notes", flavorProfile: "Caramelized, deep"),
                    SubstitutionAlternative(name: "Sugar", ratio: 0.5, notes: "Granulated, needs dissolving", flavorProfile: "Pure sweetness")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Honey",
                category: .sweeteners,
                alternatives: [
                    SubstitutionAlternative(name: "Honey syrup", ratio: 1.0, notes: "Pre-diluted honey", flavorProfile: "Floral, smooth"),
                    SubstitutionAlternative(name: "Agave syrup", ratio: 1.0, notes: "Milder flavor", flavorProfile: "Neutral sweet"),
                    SubstitutionAlternative(name: "Maple syrup", ratio: 1.0, notes: "Different flavor profile", flavorProfile: "Woody, distinct")
                ],
                difficulty: .easy
            ),
            
            // BITTERS
            IngredientSubstitution(
                originalIngredient: "Angostura bitters",
                category: .bitters,
                alternatives: [
                    SubstitutionAlternative(name: "Peychaud's bitters", ratio: 1.0, notes: "More floral, less spicy", flavorProfile: "Anise, cherry"),
                    SubstitutionAlternative(name: "Orange bitters", ratio: 1.0, notes: "Citrus-forward", flavorProfile: "Bright, aromatic"),
                    SubstitutionAlternative(name: "Fee Brothers bitters", ratio: 1.0, notes: "Various flavors available", flavorProfile: "Varies by type")
                ],
                difficulty: .moderate
            ),
            
            // CITRUS
            IngredientSubstitution(
                originalIngredient: "Lime juice",
                category: .citrus,
                alternatives: [
                    SubstitutionAlternative(name: "Lemon juice", ratio: 1.0, notes: "Less tart, different acidity", flavorProfile: "Bright, tart"),
                    SubstitutionAlternative(name: "Grapefruit juice", ratio: 1.2, notes: "Bitter notes", flavorProfile: "Tart, slightly bitter"),
                    SubstitutionAlternative(name: "Yuzu juice", ratio: 0.9, notes: "More aromatic", flavorProfile: "Floral, complex citrus")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Lemon juice",
                category: .citrus,
                alternatives: [
                    SubstitutionAlternative(name: "Lime juice", ratio: 1.0, notes: "More tart", flavorProfile: "Sharp, acidic"),
                    SubstitutionAlternative(name: "White wine vinegar + water", ratio: 0.5, notes: "Emergency substitute", flavorProfile: "Acidic, not fruity")
                ],
                difficulty: .easy
            ),
            
            // DAIRY
            IngredientSubstitution(
                originalIngredient: "Heavy cream",
                category: .dairy,
                alternatives: [
                    SubstitutionAlternative(name: "Half-and-half", ratio: 1.0, notes: "Less rich", flavorProfile: "Lighter, creamy"),
                    SubstitutionAlternative(name: "Coconut cream", ratio: 1.0, notes: "Dairy-free, coconut flavor", flavorProfile: "Tropical, rich"),
                    SubstitutionAlternative(name: "Evaporated milk", ratio: 1.0, notes: "Slightly caramelized", flavorProfile: "Creamy, cooked milk")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Milk",
                category: .dairy,
                alternatives: [
                    SubstitutionAlternative(name: "Oat milk", ratio: 1.0, notes: "Dairy-free, creamy", flavorProfile: "Neutral, slightly sweet"),
                    SubstitutionAlternative(name: "Almond milk", ratio: 1.0, notes: "Dairy-free, nutty", flavorProfile: "Light, almond notes"),
                    SubstitutionAlternative(name: "Half-and-half", ratio: 0.75, notes: "Richer", flavorProfile: "Creamy, indulgent")
                ],
                difficulty: .easy
            ),
            
            // VERMOUTH
            IngredientSubstitution(
                originalIngredient: "Sweet vermouth",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "Dry vermouth + simple syrup", ratio: 1.0, notes: "Add sweetness", flavorProfile: "Herbal with added sugar"),
                    SubstitutionAlternative(name: "Port wine", ratio: 0.9, notes: "Sweeter, fruitier", flavorProfile: "Rich, fortified"),
                    SubstitutionAlternative(name: "Sherry", ratio: 1.0, notes: "Nutty notes", flavorProfile: "Complex, oxidized")
                ],
                difficulty: .moderate
            ),
            
            IngredientSubstitution(
                originalIngredient: "Dry vermouth",
                category: .spirits,
                alternatives: [
                    SubstitutionAlternative(name: "White wine", ratio: 1.0, notes: "Less herbal", flavorProfile: "Fruity, acidic"),
                    SubstitutionAlternative(name: "Fino sherry", ratio: 0.9, notes: "Drier, nuttier", flavorProfile: "Crisp, saline")
                ],
                difficulty: .moderate
            ),
            
            // MIXERS
            IngredientSubstitution(
                originalIngredient: "Club soda",
                category: .mixers,
                alternatives: [
                    SubstitutionAlternative(name: "Sparkling water", ratio: 1.0, notes: "Same carbonation", flavorProfile: "Neutral, bubbly"),
                    SubstitutionAlternative(name: "Tonic water", ratio: 1.0, notes: "Adds quinine bitterness", flavorProfile: "Bitter, sweet"),
                    SubstitutionAlternative(name: "Ginger ale", ratio: 1.0, notes: "Adds sweetness and ginger", flavorProfile: "Spicy, sweet")
                ],
                difficulty: .easy
            ),
            
            IngredientSubstitution(
                originalIngredient: "Ginger beer",
                category: .mixers,
                alternatives: [
                    SubstitutionAlternative(name: "Ginger ale", ratio: 1.0, notes: "Less spicy", flavorProfile: "Mild ginger, sweet"),
                    SubstitutionAlternative(name: "Club soda + ginger syrup", ratio: 1.0, notes: "DIY option", flavorProfile: "Customizable spice")
                ],
                difficulty: .easy
            )
        ]
    }
    
    // MARK: - Substitution Finding
    func findSubstitutions(for ingredient: String) -> IngredientSubstitution? {
        // Normalize ingredient name for matching
        let normalizedIngredient = ingredient.lowercased().trimmingCharacters(in: .whitespaces)
        
        return substitutionDatabase.first { substitution in
            let normalizedOriginal = substitution.originalIngredient.lowercased()
            return normalizedOriginal == normalizedIngredient ||
                   normalizedOriginal.contains(normalizedIngredient) ||
                   normalizedIngredient.contains(normalizedOriginal)
        }
    }
    
    func findSuggestions(for missingIngredients: [String], userInventory: [String]) -> [SubstitutionSuggestion] {
        var suggestions: [SubstitutionSuggestion] = []
        
        for ingredient in missingIngredients {
            if let substitution = findSubstitutions(for: ingredient) {
                // Filter alternatives that user has in inventory
                let availableAlternatives = substitution.alternatives.filter { alternative in
                    userInventory.contains { inventoryItem in
                        inventoryItem.lowercased().contains(alternative.name.lowercased()) ||
                        alternative.name.lowercased().contains(inventoryItem.lowercased())
                    }
                }
                
                // Find recommended alternative (first available, or first if none available)
                let recommended = availableAlternatives.first ?? substitution.alternatives.first
                
                let suggestion = SubstitutionSuggestion(
                    missingIngredient: ingredient,
                    substitution: substitution,
                    availableAlternatives: availableAlternatives,
                    recommendedAlternative: recommended
                )
                
                suggestions.append(suggestion)
            }
        }
        
        return suggestions
    }
    
    // MARK: - Helper Methods
    func allCategories() -> [SubstitutionCategory] {
        return SubstitutionCategory.allCases
    }
    
    func substitutions(in category: SubstitutionCategory) -> [IngredientSubstitution] {
        return substitutionDatabase.filter { $0.category == category }
    }
    
    func searchSubstitutions(query: String) -> [IngredientSubstitution] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !normalizedQuery.isEmpty else { return substitutionDatabase }
        
        return substitutionDatabase.filter { substitution in
            substitution.originalIngredient.lowercased().contains(normalizedQuery) ||
            substitution.alternatives.contains { $0.name.lowercased().contains(normalizedQuery) }
        }
    }
}
