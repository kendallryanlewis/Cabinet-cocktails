//
//  EducationalContentManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation

// MARK: - Bartending Tip
struct BartendingTip: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: TipCategory
    let difficulty: DifficultyLevel
    
    enum TipCategory: String, Codable, CaseIterable {
        case technique = "Technique"
        case equipment = "Equipment"
        case ingredient = "Ingredient"
        case presentation = "Presentation"
        case history = "History"
    }
    
    init(id: UUID = UUID(), title: String, description: String, category: TipCategory, difficulty: DifficultyLevel = .beginner) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#FFC107"
        case .advanced: return "#FF9800"
        case .expert: return "#F44336"
        }
    }
}

// MARK: - Ingredient Guide
struct IngredientGuide: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let type: String
    let flavor: String
    let uses: [String]
    let substitutes: [String]
    let storage: String
    
    init(id: UUID = UUID(), name: String, description: String, type: String, flavor: String, uses: [String], substitutes: [String], storage: String) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.flavor = flavor
        self.uses = uses
        self.substitutes = substitutes
        self.storage = storage
    }
}

// MARK: - Cocktail Story
struct CocktailStory: Identifiable, Codable {
    let id: UUID
    let cocktailId: String
    let cocktailName: String
    let origin: String
    let year: String
    let story: String
    let funFacts: [String]
    
    init(id: UUID = UUID(), cocktailId: String, cocktailName: String, origin: String, year: String, story: String, funFacts: [String]) {
        self.id = id
        self.cocktailId = cocktailId
        self.cocktailName = cocktailName
        self.origin = origin
        self.year = year
        self.story = story
        self.funFacts = funFacts
    }
}

// MARK: - Educational Content Manager
@MainActor
class EducationalContentManager: ObservableObject {
    static let shared = EducationalContentManager()
    
    @Published var tips: [BartendingTip] = []
    @Published var guides: [IngredientGuide] = []
    @Published var stories: [CocktailStory] = []
    
    private init() {
        loadDefaultContent()
    }
    
    func loadDefaultContent() {
        loadBartendingTips()
        loadIngredientGuides()
        loadCocktailStories()
    }
    
    private func loadBartendingTips() {
        tips = [
            BartendingTip(title: "Proper Shaking Technique", description: "Shake cocktails with ice for 10-15 seconds until the shaker frosts over. This properly dilutes and chills the drink.", category: .technique, difficulty: .beginner),
            BartendingTip(title: "Stirring vs Shaking", description: "Stir spirit-forward cocktails (Martini, Manhattan) and shake cocktails with citrus, cream, or egg. Stirring keeps the drink clear while shaking aerates it.", category: .technique, difficulty: .intermediate),
            BartendingTip(title: "Double Straining", description: "Use a fine mesh strainer along with your cocktail strainer to remove ice chips and fruit pulp for a smoother drink.", category: .technique, difficulty: .intermediate),
            BartendingTip(title: "Fresh Citrus Juice", description: "Always use fresh-squeezed citrus juice. Pre-made juice lacks the brightness and flavor of fresh. Juice can be stored for up to 24 hours.", category: .ingredient, difficulty: .beginner),
            BartendingTip(title: "Proper Muddling", description: "Muddle herbs gently by pressing and twisting, not smashing. Over-muddling releases bitter compounds. For fruits, muddle more firmly to extract juices.", category: .technique, difficulty: .beginner),
            BartendingTip(title: "Ice Quality Matters", description: "Use large, clear ice cubes for rocks drinks - they melt slower and dilute less. Small ice is better for shaking. Never reuse ice.", category: .ingredient, difficulty: .intermediate),
            BartendingTip(title: "Chill Your Glassware", description: "Keep glasses in the freezer or fill with ice water while you make the drink. A chilled glass keeps your cocktail colder longer.", category: .equipment, difficulty: .beginner),
            BartendingTip(title: "Express Citrus Oils", description: "Express oils from citrus peels by holding the peel over the drink and giving it a sharp twist. Rub the peel around the rim before dropping it in.", category: .presentation, difficulty: .intermediate),
            BartendingTip(title: "Measuring is Key", description: "Always measure your ingredients with a jigger. Even experienced bartenders measure for consistency.", category: .technique, difficulty: .beginner),
            BartendingTip(title: "Build Drinks in Order", description: "Add ingredients in order of cheapest to most expensive. This way, if you make a mistake, you haven't wasted your premium spirits.", category: .technique, difficulty: .intermediate)
        ]
    }
    
    private func loadIngredientGuides() {
        guides = [
            IngredientGuide(name: "Angostura Bitters", description: "Aromatic bitters with flavors of cinnamon, cloves, and nutmeg", type: "Bitters", flavor: "Spicy, aromatic, slightly bitter", uses: ["Old Fashioned", "Manhattan", "Champagne Cocktail"], substitutes: ["Orange bitters", "Peychaud's bitters"], storage: "Store at room temperature, away from light. Lasts indefinitely."),
            IngredientGuide(name: "Simple Syrup", description: "Equal parts sugar and water, dissolved", type: "Sweetener", flavor: "Sweet, neutral", uses: ["Daiquiri", "Mojito", "Tom Collins"], substitutes: ["Rich simple syrup (2:1)", "Honey syrup", "Agave nectar"], storage: "Refrigerate up to 1 month. Add 1 oz vodka to extend shelf life."),
            IngredientGuide(name: "Dry Vermouth", description: "Fortified wine with herbs and botanicals", type: "Vermouth", flavor: "Dry, herbal, slightly bitter", uses: ["Martini", "Gibson"], substitutes: ["White wine + herbs", "Lillet Blanc"], storage: "Refrigerate after opening. Lasts 1-2 months."),
            IngredientGuide(name: "Cointreau", description: "Premium triple sec orange liqueur", type: "Liqueur", flavor: "Sweet orange, clear", uses: ["Margarita", "Cosmopolitan", "Sidecar"], substitutes: ["Grand Marnier", "Triple sec"], storage: "Store at room temperature. Lasts indefinitely.")
        ]
    }
    
    private func loadCocktailStories() {
        stories = [
            CocktailStory(cocktailId: "11007", cocktailName: "Margarita", origin: "Mexico/USA Border", year: "1930s-1940s", story: "The Margarita's origin is disputed, with multiple bartenders claiming its invention. The most popular story credits Carlos 'Danny' Herrera at his restaurant Rancho La Gloria in Tijuana in 1938. He allegedly created it for dancer Marjorie King, who was allergic to all spirits except tequila.", funFacts: ["February 22 is National Margarita Day", "It's the most ordered cocktail in the US", "The name 'Margarita' means 'daisy' in Spanish"]),
            CocktailStory(cocktailId: "11000", cocktailName: "Mojito", origin: "Havana, Cuba", year: "1500s", story: "The Mojito has roots in a 16th-century drink called 'El Draque' named after Sir Francis Drake. Cuban slaves working in sugarcane fields would drink a mixture of aguardiente (crude rum), lime, sugarcane juice, and mint. The modern Mojito emerged in Havana in the 1800s when Bacardi refined the rum-making process.", funFacts: ["Ernest Hemingway's favorite drink", "Originally used as a medicinal tonic", "La Bodeguita del Medio in Havana claims to be its birthplace"]),
            CocktailStory(cocktailId: "11001", cocktailName: "Old Fashioned", origin: "Louisville, Kentucky", year: "1880s", story: "The Old Fashioned was invented at the Pendennis Club in Louisville, Kentucky for a prominent bourbon distiller, Colonel James E. Pepper. The drink was a variation on an earlier style of cocktail that included spirits, sugar, water, and bitters. The term 'old fashioned' came about because drinkers who wanted the original-style cocktail had to specify they wanted it made 'the old-fashioned way.'", funFacts: ["It's the official cocktail of Louisville", "Originally made with any spirit, not just bourbon", "The first documented definition of 'cocktail' (1806) describes what we'd call an Old Fashioned"])
        ]
    }
    
    func getTipsForCategory(_ category: BartendingTip.TipCategory) -> [BartendingTip] {
        return tips.filter { $0.category == category }
    }
    
    func getTipsForDifficulty(_ difficulty: DifficultyLevel) -> [BartendingTip] {
        return tips.filter { $0.difficulty == difficulty }
    }
    
    func getStoryFor(cocktailId: String) -> CocktailStory? {
        return stories.first { $0.cocktailId == cocktailId }
    }
    
    func getGuideFor(ingredient: String) -> IngredientGuide? {
        return guides.first { $0.name.lowercased().contains(ingredient.lowercased()) }
    }
}
