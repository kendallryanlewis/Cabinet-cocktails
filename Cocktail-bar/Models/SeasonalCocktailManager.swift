//
//  SeasonalCocktailManager.swift  
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation

// MARK: - Season
enum Season: String, Codable, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    
    var icon: String {
        switch self {
        case .spring: return "leaf"
        case .summer: return "sun.max"
        case .fall: return "sparkles"
        case .winter: return "snowflake"
        }
    }
    
    var months: [Int] {
        switch self {
        case .spring: return [3, 4, 5]
        case .summer: return [6, 7, 8]
        case .fall: return [9, 10, 11]
        case .winter: return [12, 1, 2]
        }
    }
}

// MARK: - Holiday
enum Holiday: String, Codable, CaseIterable {
    case newYear = "New Year's"
    case valentines = "Valentine's Day"
    case stPatricks = "St. Patrick's Day"
    case easter = "Easter"
    case cincoMayo = "Cinco de Mayo"
    case july4th = "Independence Day"
    case halloween = "Halloween"
    case thanksgiving = "Thanksgiving"
    case christmas = "Christmas"
    case newYearsEve = "New Year's Eve"
    
    var icon: String {
        switch self {
        case .newYear: return "sparkles"
        case .valentines: return "heart.fill"
        case .stPatricks: return "leaf.fill"
        case .easter: return "hare"
        case .cincoMayo: return "party.popper"
        case .july4th: return "flag.fill"
        case .halloween: return "moon.stars"
        case .thanksgiving: return "leaf"
        case .christmas: return "gift.fill"
        case .newYearsEve: return "party.popper.fill"
        }
    }
    
    var month: Int {
        switch self {
        case .newYear: return 1
        case .valentines: return 2
        case .stPatricks: return 3
        case .easter: return 4
        case .cincoMayo: return 5
        case .july4th: return 7
        case .halloween: return 10
        case .thanksgiving: return 11
        case .christmas: return 12
        case .newYearsEve: return 12
        }
    }
}

// MARK: - Seasonal Recommendation
struct SeasonalRecommendation: Identifiable {
    let id = UUID()
    let season: Season
    let categories: [String]
    let flavors: [String]
    let description: String
}

// MARK: - Seasonal Cocktail Manager
@MainActor
class SeasonalCocktailManager: ObservableObject {
    static let shared = SeasonalCocktailManager()
    
    @Published var currentSeason: Season
    @Published var upcomingHolidays: [Holiday] = []
    
    let seasonalRecommendations: [Season: SeasonalRecommendation] = [
        .spring: SeasonalRecommendation(
            season: .spring,
            categories: ["Cocktail", "Shot"],
            flavors: ["floral", "citrus", "elderflower", "gin"],
            description: "Light, refreshing cocktails with floral notes"
        ),
        .summer: SeasonalRecommendation(
            season: .summer,
            categories: ["Cocktail", "Shot"],
            flavors: ["tropical", "citrus", "rum", "tequila", "mint"],
            description: "Bright, tropical drinks perfect for warm weather"
        ),
        .fall: SeasonalRecommendation(
            season: .fall,
            categories: ["Cocktail", "Punch"],
            flavors: ["whiskey", "bourbon", "apple", "cinnamon", "maple"],
            description: "Warm, spiced cocktails with autumn flavors"
        ),
        .winter: SeasonalRecommendation(
            season: .winter,
            categories: ["Cocktail", "Coffee / Tea", "Cocoa"],
            flavors: ["whiskey", "brandy", "chocolate", "cream", "coffee"],
            description: "Rich, warming drinks for cold weather"
        )
    ]
    
    private let holidayCocktails: [Holiday: [String]] = [
        .stPatricks: ["Irish Coffee", "Whiskey", "Guinness"],
        .cincoMayo: ["Margarita", "Tequila", "Paloma"],
        .july4th: ["Blue cocktails", "Red cocktails", "White cocktails"],
        .halloween: ["Black cocktails", "Orange cocktails", "Spooky"],
        .christmas: ["Eggnog", "Hot Toddy", "Mulled Wine"],
        .newYearsEve: ["Champagne", "Prosecco", "Sparkling"]
    ]
    
    private init() {
        self.currentSeason = Self.getCurrentSeason()
        self.upcomingHolidays = Self.getUpcomingHolidays()
    }
    
    static func getCurrentSeason() -> Season {
        let month = Calendar.current.component(.month, from: Date())
        return Season.allCases.first { $0.months.contains(month) } ?? .spring
    }
    
    static func getUpcomingHolidays() -> [Holiday] {
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        return Holiday.allCases.filter { holiday in
            let monthDiff = holiday.month - currentMonth
            return monthDiff >= 0 && monthDiff <= 2
        }
    }
    
    func filterCocktailsBySeason(_ cocktails: [DrinkDetails]) -> [DrinkDetails] {
        guard let recommendation = seasonalRecommendations[currentSeason] else {
            return cocktails
        }
        
        return cocktails.filter { drink in
            // Check category
            if let category = drink.strCategory,
               recommendation.categories.contains(where: { $0.lowercased() == category.lowercased() }) {
                return true
            }
            
            // Check flavors in ingredients
            let ingredients = drink.getIngredients().joined(separator: " ").lowercased()
            return recommendation.flavors.contains { ingredients.contains($0.lowercased()) }
        }
    }
    
    func filterCocktailsByHoliday(_ cocktails: [DrinkDetails], holiday: Holiday) -> [DrinkDetails] {
        guard let keywords = holidayCocktails[holiday] else { return cocktails }
        
        return cocktails.filter { drink in
            let searchString = "\(drink.strDrink) \(drink.strCategory ?? "") \(drink.getIngredients().joined(separator: " "))".lowercased()
            return keywords.contains { searchString.contains($0.lowercased()) }
        }
    }
    
    func getSeasonalDescription() -> String {
        return seasonalRecommendations[currentSeason]?.description ?? ""
    }
}
