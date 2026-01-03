//
//  RecommendationEngine.swift
//  Cocktail-bar
//
//  Created by GitHub Copilot on 12/30/25.
//

import Foundation

// MARK: - Recommendation Types
enum RecommendationMode: String, CaseIterable, Identifiable {
    case basedOnCabinet = "Based on What You Have"
    case youMightLike = "You Might Like"
    case trending = "Trending Now"
    case similar = "Similar Drinks"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .basedOnCabinet: return "cabinet.fill"
        case .youMightLike: return "star.fill"
        case .trending: return "chart.line.uptrend.xyaxis"
        case .similar: return "arrow.triangle.branch"
        }
    }
    
    var description: String {
        switch self {
        case .basedOnCabinet: return "Cocktails you can make right now"
        case .youMightLike: return "Personalized based on your taste"
        case .trending: return "Popular drinks in the community"
        case .similar: return "Similar to drinks you've enjoyed"
        }
    }
}

// MARK: - Recommendation Model
struct CocktailRecommendation: Identifiable, Equatable {
    let id = UUID()
    let drink: DrinkDetails
    let score: Double
    let reason: String
    let mode: RecommendationMode
    
    static func == (lhs: CocktailRecommendation, rhs: CocktailRecommendation) -> Bool {
        lhs.drink.idDrink == rhs.drink.idDrink
    }
}

// MARK: - Context Data
struct RecommendationContext {
    let timeOfDay: TimeOfDay
    let dayOfWeek: DayOfWeek
    let season: Season
    
    enum TimeOfDay: String {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        
        static func current() -> TimeOfDay {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 6..<12: return .morning
            case 12..<17: return .afternoon
            case 17..<21: return .evening
            default: return .night
            }
        }
    }
    
    enum DayOfWeek: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
        
        static func current() -> DayOfWeek {
            let weekday = Calendar.current.component(.weekday, from: Date())
            switch weekday {
            case 1: return .sunday
            case 2: return .monday
            case 3: return .tuesday
            case 4: return .wednesday
            case 5: return .thursday
            case 6: return .friday
            case 7: return .saturday
            default: return .monday
            }
        }
    }
    
    enum Season: String {
        case spring = "Spring"
        case summer = "Summer"
        case fall = "Fall"
        case winter = "Winter"
        
        static func current() -> Season {
            let month = Calendar.current.component(.month, from: Date())
            switch month {
            case 3...5: return .spring
            case 6...8: return .summer
            case 9...11: return .fall
            default: return .winter
            }
        }
    }
    
    static func current() -> RecommendationContext {
        return RecommendationContext(
            timeOfDay: TimeOfDay.current(),
            dayOfWeek: DayOfWeek.current(),
            season: Season.current()
        )
    }
}

// MARK: - Recommendation Engine
@MainActor
class RecommendationEngine: ObservableObject {
    static let shared = RecommendationEngine()
    
    @Published var recommendations: [RecommendationMode: [CocktailRecommendation]] = [:]
    @Published var lastRefreshDate: Date?
    @Published var isLoading = false
    
    private let maxRecommendationsPerMode = 10
    
    // Weights for scoring algorithm
    private let cabinetMatchWeight = 0.40      // 40%
    private let historyPatternWeight = 0.30    // 30%
    private let contextualWeight = 0.20        // 20%
    private let popularityWeight = 0.10        // 10%
    
    private init() {}
    
    // MARK: - Main Recommendation Generation
    func generateRecommendations(forceRefresh: Bool = false) async {
        // Check if we need to refresh (daily refresh or force)
        if !forceRefresh, let lastRefresh = lastRefreshDate {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastRefresh) {
                return // Already refreshed today
            }
        }
        
        isLoading = true
        defer { isLoading = false }
        
        guard let allDrinks = DrinkManager.shared.allDrinks else {
            return
        }
        
        let context = RecommendationContext.current()
        let cabinetIngredients = LocalStorageManager.shared.retrieveTopShelfItems()
        let historyManager = CocktailHistoryManager.shared
        
        var newRecommendations: [RecommendationMode: [CocktailRecommendation]] = [:]
        
        // Generate recommendations for each mode
        for mode in RecommendationMode.allCases {
            let recs = await generateRecommendations(
                mode: mode,
                drinks: allDrinks,
                context: context,
                cabinet: cabinetIngredients,
                history: historyManager
            )
            newRecommendations[mode] = recs
        }
        
        recommendations = newRecommendations
        lastRefreshDate = Date()
        saveRecommendations()
    }
    
    // MARK: - Mode-Specific Generation
    private func generateRecommendations(
        mode: RecommendationMode,
        drinks: [DrinkDetails],
        context: RecommendationContext,
        cabinet: [String],
        history: CocktailHistoryManager
    ) async -> [CocktailRecommendation] {
        
        var scoredDrinks: [(drink: DrinkDetails, score: Double, reason: String)] = []
        
        for drink in drinks {
            let score: Double
            let reason: String
            
            switch mode {
            case .basedOnCabinet:
                (score, reason) = calculateCabinetScore(drink: drink, cabinet: cabinet)
            case .youMightLike:
                (score, reason) = calculatePersonalizedScore(
                    drink: drink,
                    cabinet: cabinet,
                    history: history,
                    context: context
                )
            case .trending:
                (score, reason) = calculateTrendingScore(drink: drink, context: context)
            case .similar:
                (score, reason) = calculateSimilarScore(drink: drink, history: history)
            }
            
            if score > 0 {
                scoredDrinks.append((drink, score, reason))
            }
        }
        
        // Sort by score and take top recommendations
        let topDrinks = scoredDrinks
            .sorted { $0.score > $1.score }
            .prefix(maxRecommendationsPerMode)
        
        return topDrinks.map { CocktailRecommendation(drink: $0.drink, score: $0.score, reason: $0.reason, mode: mode) }
    }
    
    // MARK: - Scoring Algorithms
    
    // 1. Cabinet-Based Scoring
    private func calculateCabinetScore(drink: DrinkDetails, cabinet: [String]) -> (Double, String) {
        let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        let cabinetSet = Set(cabinet.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
        
        guard !drinkIngredients.isEmpty else { return (0, "") }
        
        let matchingIngredients = drinkIngredients.intersection(cabinetSet)
        let matchPercentage = Double(matchingIngredients.count) / Double(drinkIngredients.count)
        
        let missingCount = drinkIngredients.count - matchingIngredients.count
        
        let reason: String
        if matchPercentage == 1.0 {
            reason = "You have all ingredients!"
        } else if missingCount == 1 {
            reason = "Only missing 1 ingredient"
        } else {
            reason = "Missing \(missingCount) ingredients"
        }
        
        return (matchPercentage * 100, reason)
    }
    
    // 2. Personalized Score (combines cabinet, history, context)
    private func calculatePersonalizedScore(
        drink: DrinkDetails,
        cabinet: [String],
        history: CocktailHistoryManager,
        context: RecommendationContext
    ) -> (Double, String) {
        
        // Cabinet match component (40%)
        let (cabinetScore, _) = calculateCabinetScore(drink: drink, cabinet: cabinet)
        let cabinetComponent = (cabinetScore / 100) * cabinetMatchWeight
        
        // History pattern component (30%)
        let historyComponent = calculateHistoryComponent(drink: drink, history: history) * historyPatternWeight
        
        // Contextual component (20%)
        let contextComponent = calculateContextComponent(drink: drink, context: context) * contextualWeight
        
        // Popularity component (10%)
        let popularityComponent = calculatePopularityComponent(drink: drink) * popularityWeight
        
        let totalScore = (cabinetComponent + historyComponent + contextComponent + popularityComponent) * 100
        
        // Generate reason based on highest component
        let components = [
            (cabinetComponent, "Great match with your cabinet"),
            (historyComponent, "Based on your taste preferences"),
            (contextComponent, "Perfect for \(context.timeOfDay.rawValue.lowercased())"),
            (popularityComponent, "Highly rated classic")
        ]
        let topReason = components.max(by: { $0.0 < $1.0 })?.1 ?? "Recommended for you"
        
        return (totalScore, topReason)
    }
    
    // 3. Trending Score (context + popularity)
    private func calculateTrendingScore(drink: DrinkDetails, context: RecommendationContext) -> (Double, String) {
        let contextScore = calculateContextComponent(drink: drink, context: context)
        let popularityScore = calculatePopularityComponent(drink: drink)
        
        let totalScore = (contextScore * 0.6 + popularityScore * 0.4) * 100
        
        let reason: String
        if contextScore > 0.7 {
            reason = "Popular this \(context.season.rawValue.lowercased())"
        } else {
            reason = "Classic favorite"
        }
        
        return (totalScore, reason)
    }
    
    // 4. Similar Score (based on history)
    private func calculateSimilarScore(drink: DrinkDetails, history: CocktailHistoryManager) -> (Double, String) {
        let stats = history.getStatistics()
        
        guard !stats.favoriteCocktails.isEmpty else {
            return (0, "")
        }
        
        // Check if drink shares ingredients with favorites
        let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
        var maxSimilarity = 0.0
        var similarTo = ""
        
        for (favoriteName, _) in stats.favoriteCocktails {
            if let favoriteDrink = DrinkManager.shared.findDrinkByName(name: favoriteName) {
                let favoriteIngredients = Set(favoriteDrink.getIngredients().map { $0.lowercased() })
                let commonIngredients = drinkIngredients.intersection(favoriteIngredients)
                let similarity = Double(commonIngredients.count) / Double(max(drinkIngredients.count, favoriteIngredients.count))
                
                if similarity > maxSimilarity {
                    maxSimilarity = similarity
                    similarTo = favoriteName
                }
            }
        }
        
        // Also check category match
        if let drinkCategory = drink.strCategory {
            for (favoriteName, count) in stats.favoriteCocktails {
                if let favoriteDrink = DrinkManager.shared.findDrinkByName(name: favoriteName),
                   favoriteDrink.strCategory == drinkCategory {
                    maxSimilarity = max(maxSimilarity, 0.6 + (Double(count) * 0.05))
                    if similarTo.isEmpty {
                        similarTo = favoriteName
                    }
                }
            }
        }
        
        let score = maxSimilarity * 100
        let reason = similarTo.isEmpty ? "Matches your preferences" : "Similar to \(similarTo)"
        
        return (score, reason)
    }
    
    // MARK: - Component Calculators
    
    private func calculateHistoryComponent(drink: DrinkDetails, history: CocktailHistoryManager) -> Double {
        let stats = history.getStatistics()
        var score = 0.0
        
        // Check if user has made this drink before
        if history.hasMade(drink.strDrink) {
            if let lastMade = history.getLastMade(for: drink.strDrink),
               let rating = history.historyItems.first(where: { $0.cocktailName == drink.strDrink })?.rating {
                // Boost highly rated drinks
                score += Double(rating) * 0.15
            }
            // Slight penalty for recently made (encourage variety)
            score -= 0.1
        }
        
        // Boost drinks in favorite categories
        if let category = drink.strCategory {
            let categoryCount = stats.favoriteCocktails.filter { name, _ in
                DrinkManager.shared.findDrinkByName(name: name)?.strCategory == category
            }.count
            score += Double(categoryCount) * 0.05
        }
        
        // Boost drinks with user's top ingredients
        let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
        let topIngredients = Set(stats.mostUsedIngredients.prefix(5).map { $0.ingredient.lowercased() })
        let matchCount = drinkIngredients.intersection(topIngredients).count
        score += Double(matchCount) * 0.1
        
        return min(max(score, 0), 1.0)
    }
    
    private func calculateContextComponent(drink: DrinkDetails, context: RecommendationContext) -> Double {
        var score = 0.0
        
        // Time of day preferences
        let drinkName = drink.strDrink.lowercased()
        let category = drink.strCategory?.lowercased() ?? ""
        
        switch context.timeOfDay {
        case .morning:
            if category.contains("coffee") || drinkName.contains("mimosa") || drinkName.contains("bloody") {
                score += 0.4
            }
        case .afternoon:
            if category.contains("punch") || category.contains("shot") == false {
                score += 0.3
            }
        case .evening:
            if category.contains("cocktail") || category.contains("ordinary") {
                score += 0.35
            }
        case .night:
            if drinkName.contains("martini") || category.contains("cocktail") {
                score += 0.35
            }
        }
        
        // Season preferences
        switch context.season {
        case .summer:
            if drinkName.contains("frozen") || drinkName.contains("ice") || 
               drinkName.contains("mojito") || drinkName.contains("daiquiri") ||
               category.contains("tropical") {
                score += 0.3
            }
        case .winter:
            if drinkName.contains("hot") || drinkName.contains("toddy") ||
               drinkName.contains("coffee") || drinkName.contains("irish") {
                score += 0.3
            }
        case .spring, .fall:
            score += 0.2 // Neutral seasons
        }
        
        // Weekend boost for complex drinks
        if context.dayOfWeek == .friday || context.dayOfWeek == .saturday {
            let ingredientCount = drink.getIngredients().count
            if ingredientCount > 5 {
                score += 0.15
            }
        }
        
        return min(score, 1.0)
    }
    
    private func calculatePopularityComponent(drink: DrinkDetails) -> Double {
        // Base popularity on IBA status and category
        var score = 0.5 // Base score
        
        if drink.strIBA != nil && !drink.strIBA!.isEmpty {
            score += 0.3 // IBA cocktails are classics
        }
        
        // Popular categories
        let category = drink.strCategory?.lowercased() ?? ""
        if category.contains("cocktail") || category.contains("ordinary") {
            score += 0.2
        }
        
        return min(score, 1.0)
    }
    
    // MARK: - Persistence
    private func saveRecommendations() {
        let encoder = JSONEncoder()
        if let lastRefresh = lastRefreshDate,
           let data = try? encoder.encode(lastRefresh) {
            UserDefaults.standard.set(data, forKey: "lastRecommendationRefresh")
        }
    }
    
    func loadLastRefreshDate() {
        if let data = UserDefaults.standard.data(forKey: "lastRecommendationRefresh"),
           let date = try? JSONDecoder().decode(Date.self, from: data) {
            lastRefreshDate = date
        }
    }
    
    // MARK: - Utilities
    func getRecommendations(for mode: RecommendationMode) -> [CocktailRecommendation] {
        return recommendations[mode] ?? []
    }
    
    func refreshRecommendations() async {
        await generateRecommendations(forceRefresh: true)
    }
}
