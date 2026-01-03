//
//  BatchCalculator.swift
//  Cocktail-bar
//
//  Created by GitHub Copilot on 12/30/25.
//

import Foundation

// MARK: - Batch Preset
struct BatchPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var multiplier: Double
    var drinkId: String
    var drinkName: String
    var createdDate: Date
    
    init(id: UUID = UUID(), name: String, multiplier: Double, drinkId: String, drinkName: String, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.multiplier = multiplier
        self.drinkId = drinkId
        self.drinkName = drinkName
        self.createdDate = createdDate
    }
}

// MARK: - Unit Types
enum VolumeUnit: String, CaseIterable, Codable {
    case oz = "oz"
    case ml = "ml"
    case cups = "cups"
    case tbsp = "tbsp"
    case tsp = "tsp"
    case shots = "shots"
    
    var displayName: String {
        switch self {
        case .oz: return "Ounces"
        case .ml: return "Milliliters"
        case .cups: return "Cups"
        case .tbsp: return "Tablespoons"
        case .tsp: return "Teaspoons"
        case .shots: return "Shots"
        }
    }
    
    // Convert to oz (base unit)
    func toOz(_ value: Double) -> Double {
        switch self {
        case .oz: return value
        case .ml: return value * 0.033814
        case .cups: return value * 8
        case .tbsp: return value * 0.5
        case .tsp: return value * 0.166667
        case .shots: return value * 1.5
        }
    }
    
    // Convert from oz to this unit
    func fromOz(_ oz: Double) -> Double {
        switch self {
        case .oz: return oz
        case .ml: return oz * 29.5735
        case .cups: return oz / 8
        case .tbsp: return oz * 2
        case .tsp: return oz * 6
        case .shots: return oz / 1.5
        }
    }
}

// MARK: - Scaled Ingredient
struct ScaledIngredient: Identifiable {
    let id = UUID()
    let name: String
    let originalAmount: String
    let scaledAmount: Double
    let unit: VolumeUnit
    let parsedOriginalAmount: Double?
    
    var displayAmount: String {
        let formatted = String(format: "%.2f", scaledAmount)
        return "\(formatted) \(unit.rawValue)"
    }
}

// MARK: - Batch Calculator Manager
@MainActor
class BatchCalculatorManager: ObservableObject {
    static let shared = BatchCalculatorManager()
    
    @Published var savedPresets: [BatchPreset] = []
    @Published var currentMultiplier: Double = 1.0
    @Published var preferredUnit: VolumeUnit = .oz
    
    private let presetsKey = "batchCalculatorPresets"
    private let preferredUnitKey = "batchCalculatorPreferredUnit"
    
    private init() {
        loadPresets()
        loadPreferredUnit()
    }
    
    // MARK: - Scaling Functions
    
    /// Scale a cocktail recipe by a multiplier
    func scaleRecipe(drink: DrinkDetails, multiplier: Double, targetUnit: VolumeUnit) -> [ScaledIngredient] {
        let ingredients = drink.getIngredients()
        let measures = getAllMeasures(from: drink)
        
        var scaledIngredients: [ScaledIngredient] = []
        
        for (index, ingredient) in ingredients.enumerated() {
            guard index < measures.count else { continue }
            let measure = measures[index]
            
            let (amount, unit) = parseMeasurement(measure)
            
            if let amount = amount {
                let scaledOz = unit.toOz(amount) * multiplier
                let scaledInTarget = targetUnit.fromOz(scaledOz)
                
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient,
                    originalAmount: measure,
                    scaledAmount: scaledInTarget,
                    unit: targetUnit,
                    parsedOriginalAmount: amount
                ))
            } else {
                // Non-measurable ingredients (e.g., "dash", "splash")
                scaledIngredients.append(ScaledIngredient(
                    name: ingredient,
                    originalAmount: measure,
                    scaledAmount: 0,
                    unit: targetUnit,
                    parsedOriginalAmount: nil
                ))
            }
        }
        
        return scaledIngredients
    }
    
    /// Parse measurement string to extract amount and unit
    private func parseMeasurement(_ measure: String) -> (amount: Double?, unit: VolumeUnit) {
        let cleanedMeasure = measure.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Handle fractions
        let fractionMap: [String: Double] = [
            "1/4": 0.25, "1/3": 0.33, "1/2": 0.5, "2/3": 0.67, "3/4": 0.75,
            "¼": 0.25, "⅓": 0.33, "½": 0.5, "⅔": 0.67, "¾": 0.75
        ]
        
        // Try to extract numeric value and unit
        var amount: Double?
        var unit: VolumeUnit = .oz
        
        // Check for specific patterns
        if cleanedMeasure.contains("oz") {
            unit = .oz
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else if cleanedMeasure.contains("ml") {
            unit = .ml
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else if cleanedMeasure.contains("cup") {
            unit = .cups
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else if cleanedMeasure.contains("tbsp") || cleanedMeasure.contains("tablespoon") {
            unit = .tbsp
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else if cleanedMeasure.contains("tsp") || cleanedMeasure.contains("teaspoon") {
            unit = .tsp
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else if cleanedMeasure.contains("shot") {
            unit = .shots
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        } else {
            // Try to extract just a number (assume oz)
            amount = extractNumber(from: cleanedMeasure, fractionMap: fractionMap)
        }
        
        return (amount, unit)
    }
    
    /// Extract numeric value from string, handling fractions
    private func extractNumber(from string: String, fractionMap: [String: Double]) -> Double? {
        // Check for fractions first
        for (fraction, value) in fractionMap {
            if string.contains(fraction) {
                // Check if there's a whole number before the fraction
                let parts = string.components(separatedBy: fraction)
                if let wholeStr = parts.first?.trimmingCharacters(in: .whitespaces),
                   let whole = Double(wholeStr.filter { $0.isNumber || $0 == "." }) {
                    return whole + value
                }
                return value
            }
        }
        
        // Extract regular number
        let numbers = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let decimal = string.first(where: { $0 == "." }) {
            let withDecimal = string.filter { $0.isNumber || $0 == "." }
            return Double(withDecimal)
        }
        return Double(numbers)
    }
    
    /// Get all measures from a drink
    private func getAllMeasures(from drink: DrinkDetails) -> [String] {
        return [
            drink.strMeasure1, drink.strMeasure2, drink.strMeasure3,
            drink.strMeasure4, drink.strMeasure5, drink.strMeasure6,
            drink.strMeasure7, drink.strMeasure8, drink.strMeasure9,
            drink.strMeasure10, drink.strMeasure11, drink.strMeasure12,
            drink.strMeasure13, drink.strMeasure14, drink.strMeasure15
        ].compactMap { $0 }
    }
    
    // MARK: - Preset Management
    
    func savePreset(_ preset: BatchPreset) {
        savedPresets.append(preset)
        savePresets()
    }
    
    func deletePreset(_ preset: BatchPreset) {
        savedPresets.removeAll { $0.id == preset.id }
        savePresets()
    }
    
    func updatePreset(_ preset: BatchPreset) {
        if let index = savedPresets.firstIndex(where: { $0.id == preset.id }) {
            savedPresets[index] = preset
            savePresets()
        }
    }
    
    // MARK: - Quick Multipliers
    
    static let quickMultipliers: [Double] = [1, 2, 4, 8, 12]
    
    func getQuickMultiplierLabel(for multiplier: Double) -> String {
        if multiplier == 1 {
            return "1x (Single)"
        } else {
            return "\(Int(multiplier))x"
        }
    }
    
    // MARK: - Unit Preferences
    
    func setPreferredUnit(_ unit: VolumeUnit) {
        preferredUnit = unit
        UserDefaults.standard.set(unit.rawValue, forKey: preferredUnitKey)
    }
    
    private func loadPreferredUnit() {
        if let unitString = UserDefaults.standard.string(forKey: preferredUnitKey),
           let unit = VolumeUnit(rawValue: unitString) {
            preferredUnit = unit
        }
    }
    
    // MARK: - Persistence
    
    private func savePresets() {
        if let data = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(data, forKey: presetsKey)
        }
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let presets = try? JSONDecoder().decode([BatchPreset].self, from: data) {
            savedPresets = presets
        }
    }
    
    // MARK: - Cost Estimation (placeholder for future integration)
    
    func estimateCost(for ingredients: [ScaledIngredient]) -> Double? {
        // TODO: Integrate with cost tracking feature (Task 19)
        return nil
    }
}
