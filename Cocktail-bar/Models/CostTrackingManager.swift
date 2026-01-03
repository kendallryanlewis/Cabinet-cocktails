//
//  CostTrackingManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Ingredient Cost
struct IngredientCost: Identifiable, Codable {
    let id: UUID
    var ingredientName: String
    var cost: Double
    var quantity: Double
    var unit: MeasurementUnit
    var purchaseDate: Date
    var expirationDate: Date?
    var storeName: String?
    
    var costPerUnit: Double {
        return cost / quantity
    }
    
    init(id: UUID = UUID(), ingredientName: String, cost: Double, quantity: Double, unit: MeasurementUnit, purchaseDate: Date = Date(), expirationDate: Date? = nil, storeName: String? = nil) {
        self.id = id
        self.ingredientName = ingredientName
        self.cost = cost
        self.quantity = quantity
        self.unit = unit
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.storeName = storeName
    }
}

// MARK: - Measurement Unit
enum MeasurementUnit: String, Codable, CaseIterable {
    case oz = "oz"
    case ml = "ml"
    case liter = "L"
    case bottle = "bottle"
    case cup = "cup"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case piece = "piece"
    case pound = "lb"
    case gram = "g"
    
    var displayName: String {
        switch self {
        case .oz: return "Ounces"
        case .ml: return "Milliliters"
        case .liter: return "Liters"
        case .bottle: return "Bottle"
        case .cup: return "Cups"
        case .tablespoon: return "Tablespoons"
        case .teaspoon: return "Teaspoons"
        case .piece: return "Piece"
        case .pound: return "Pounds"
        case .gram: return "Grams"
        }
    }
}

// MARK: - Budget Period
enum BudgetPeriod: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - Budget
struct Budget: Codable {
    var amount: Double
    var period: BudgetPeriod
    var startDate: Date
    
    var endDate: Date {
        let calendar = Calendar.current
        switch period {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        }
    }
    
    init(amount: Double, period: BudgetPeriod, startDate: Date = Date()) {
        self.amount = amount
        self.period = period
        self.startDate = startDate
    }
}

// MARK: - Cost Tracking Manager
@MainActor
class CostTrackingManager: ObservableObject {
    static let shared = CostTrackingManager()
    
    @Published var ingredientCosts: [IngredientCost] = []
    @Published var budget: Budget?
    
    private let costsStorageKey = "ingredient_costs"
    private let budgetStorageKey = "budget"
    
    private init() {
        loadCosts()
        loadBudget()
    }
    
    func loadCosts() {
        if let data = UserDefaults.standard.data(forKey: costsStorageKey),
           let decoded = try? JSONDecoder().decode([IngredientCost].self, from: data) {
            ingredientCosts = decoded
        }
    }
    
    func saveCosts() {
        if let encoded = try? JSONEncoder().encode(ingredientCosts) {
            UserDefaults.standard.set(encoded, forKey: costsStorageKey)
        }
    }
    
    func loadBudget() {
        if let data = UserDefaults.standard.data(forKey: budgetStorageKey),
           let decoded = try? JSONDecoder().decode(Budget.self, from: data) {
            budget = decoded
        }
    }
    
    func saveBudget() {
        if let encoded = try? JSONEncoder().encode(budget) {
            UserDefaults.standard.set(encoded, forKey: budgetStorageKey)
        }
    }
    
    func addIngredientCost(_ cost: IngredientCost) {
        ingredientCosts.append(cost)
        saveCosts()
    }
    
    func updateIngredientCost(_ cost: IngredientCost) {
        if let index = ingredientCosts.firstIndex(where: { $0.id == cost.id }) {
            ingredientCosts[index] = cost
            saveCosts()
        }
    }
    
    func deleteIngredientCost(_ cost: IngredientCost) {
        ingredientCosts.removeAll { $0.id == cost.id }
        saveCosts()
    }
    
    func getCostForIngredient(_ ingredientName: String) -> IngredientCost? {
        return ingredientCosts.first { $0.ingredientName.localizedCaseInsensitiveCompare(ingredientName) == .orderedSame }
    }
    
    func calculateCocktailCost(_ cocktail: DrinkDetails) -> Double {
        let ingredients = cocktail.getIngredients()
        var totalCost: Double = 0.0
        
        for ingredient in ingredients {
            if let cost = getCostForIngredient(ingredient) {
                // Estimate cost per serving (rough calculation)
                totalCost += cost.costPerUnit * 1.5 // Assuming 1.5 oz average per ingredient
            }
        }
        
        return totalCost
    }
    
    func getTotalSpending(for period: BudgetPeriod) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredCosts = ingredientCosts.filter { cost in
            switch period {
            case .weekly:
                return calendar.dateComponents([.day], from: cost.purchaseDate, to: now).day ?? 0 <= 7
            case .monthly:
                return calendar.dateComponents([.month], from: cost.purchaseDate, to: now).month ?? 0 == 0
            case .yearly:
                return calendar.dateComponents([.year], from: cost.purchaseDate, to: now).year ?? 0 == 0
            }
        }
        
        return filteredCosts.reduce(0) { $0 + $1.cost }
    }
    
    func getRemainingBudget() -> Double? {
        guard let budget = budget else { return nil }
        let spent = getTotalSpending(for: budget.period)
        return budget.amount - spent
    }
    
    func getBudgetProgress() -> Double {
        guard let budget = budget else { return 0 }
        let spent = getTotalSpending(for: budget.period)
        return min(spent / budget.amount, 1.0)
    }
    
    func isOverBudget() -> Bool {
        guard let remaining = getRemainingBudget() else { return false }
        return remaining < 0
    }
}
