//
//  BarEquipmentManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import Foundation
import SwiftUI

// MARK: - Equipment Category
enum EquipmentCategory: String, Codable, CaseIterable {
    case shakers = "Shakers"
    case glassware = "Glassware"
    case tools = "Tools"
    case accessories = "Accessories"
    case garnish = "Garnish Tools"
    
    var icon: String {
        switch self {
        case .shakers: return "wineglass"
        case .glassware: return "cup.and.saucer"
        case .tools: return "wrench.and.screwdriver"
        case .accessories: return "star"
        case .garnish: return "scissors"
        }
    }
}

// MARK: - Bar Equipment
struct BarEquipment: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: EquipmentCategory
    var description: String
    var isOwned: Bool
    var purchaseDate: Date?
    var cost: Double?
    var storageLocation: String?
    var isEssential: Bool
    
    init(id: UUID = UUID(), name: String, category: EquipmentCategory, description: String, isOwned: Bool = false, purchaseDate: Date? = nil, cost: Double? = nil, storageLocation: String? = nil, isEssential: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.isOwned = isOwned
        self.purchaseDate = purchaseDate
        self.cost = cost
        self.storageLocation = storageLocation
        self.isEssential = isEssential
    }
}

// MARK: - Bar Equipment Manager
@MainActor
class BarEquipmentManager: ObservableObject {
    static let shared = BarEquipmentManager()
    
    @Published var equipment: [BarEquipment] = []
    
    private let storageKey = "bar_equipment"
    
    private init() {
        loadEquipment()
        if equipment.isEmpty {
            loadDefaultEquipment()
        }
    }
    
    func loadEquipment() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BarEquipment].self, from: data) {
            equipment = decoded
        }
    }
    
    func saveEquipment() {
        if let encoded = try? JSONEncoder().encode(equipment) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadDefaultEquipment() {
        equipment = [
            // Shakers
            BarEquipment(name: "Cocktail Shaker", category: .shakers, description: "Essential for mixing drinks with ice", isEssential: true),
            BarEquipment(name: "Boston Shaker", category: .shakers, description: "Two-piece shaker for professionals", isEssential: false),
            BarEquipment(name: "Mixing Glass", category: .shakers, description: "For stirred cocktails", isEssential: true),
            
            // Glassware
            BarEquipment(name: "Highball Glass", category: .glassware, description: "Tall glass for mixed drinks", isEssential: true),
            BarEquipment(name: "Lowball Glass", category: .glassware, description: "Short glass for spirits on the rocks", isEssential: true),
            BarEquipment(name: "Martini Glass", category: .glassware, description: "Classic V-shaped cocktail glass", isEssential: false),
            BarEquipment(name: "Coupe Glass", category: .glassware, description: "Elegant stemmed glass for cocktails", isEssential: false),
            BarEquipment(name: "Shot Glass", category: .glassware, description: "Small glass for shots and measuring", isEssential: true),
            
            // Tools
            BarEquipment(name: "Jigger", category: .tools, description: "Measuring tool for accurate pours", isEssential: true),
            BarEquipment(name: "Bar Spoon", category: .tools, description: "Long spoon for stirring", isEssential: true),
            BarEquipment(name: "Strainer", category: .tools, description: "For straining ice and ingredients", isEssential: true),
            BarEquipment(name: "Muddler", category: .tools, description: "For crushing herbs and fruits", isEssential: true),
            BarEquipment(name: "Channel Knife", category: .tools, description: "For creating citrus twists", isEssential: false),
            BarEquipment(name: "Peeler", category: .tools, description: "For citrus peels", isEssential: false),
            
            // Accessories
            BarEquipment(name: "Ice Bucket", category: .accessories, description: "For storing ice", isEssential: true),
            BarEquipment(name: "Ice Tongs", category: .accessories, description: "For handling ice cubes", isEssential: false),
            BarEquipment(name: "Cutting Board", category: .accessories, description: "For cutting garnishes", isEssential: true),
            BarEquipment(name: "Pourers", category: .accessories, description: "Speed pourers for bottles", isEssential: false),
            
            // Garnish Tools
            BarEquipment(name: "Citrus Juicer", category: .garnish, description: "For fresh juice", isEssential: true),
            BarEquipment(name: "Zester", category: .garnish, description: "For citrus zest", isEssential: false)
        ]
        saveEquipment()
    }
    
    func addEquipment(_ item: BarEquipment) {
        equipment.append(item)
        saveEquipment()
    }
    
    func updateEquipment(_ item: BarEquipment) {
        if let index = equipment.firstIndex(where: { $0.id == item.id }) {
            equipment[index] = item
            saveEquipment()
        }
    }
    
    func deleteEquipment(_ item: BarEquipment) {
        equipment.removeAll { $0.id == item.id }
        saveEquipment()
    }
    
    func getEquipmentByCategory(_ category: EquipmentCategory) -> [BarEquipment] {
        return equipment.filter { $0.category == category }
    }
    
    func getOwnedEquipment() -> [BarEquipment] {
        return equipment.filter { $0.isOwned }
    }
    
    func getEssentialEquipment() -> [BarEquipment] {
        return equipment.filter { $0.isEssential }
    }
    
    func getMissingEssentials() -> [BarEquipment] {
        return equipment.filter { $0.isEssential && !$0.isOwned }
    }
    
    func getCompletionPercentage() -> Double {
        let totalEssential = equipment.filter { $0.isEssential }.count
        guard totalEssential > 0 else { return 0 }
        let ownedEssential = equipment.filter { $0.isEssential && $0.isOwned }.count
        return Double(ownedEssential) / Double(totalEssential)
    }
    
    func getRequiredEquipmentFor(_ cocktail: DrinkDetails) -> [String] {
        var required: [String] = []
        
        // Add glass type
        if let glass = cocktail.strGlass {
            required.append(glass)
        }
        
        // Determine if shaker or mixing glass is needed
        if let category = cocktail.strCategory, category.localizedCaseInsensitiveContains("Shot") {
            required.append("Shot Glass")
        } else if let instructions = cocktail.strInstructions, instructions.localizedCaseInsensitiveContains("shake") {
            required.append("Cocktail Shaker")
            required.append("Strainer")
        } else if let instructions = cocktail.strInstructions, instructions.localizedCaseInsensitiveContains("stir") {
            required.append("Mixing Glass")
            required.append("Bar Spoon")
        }
        
        // Check for muddling
        if let instructions = cocktail.strInstructions, instructions.localizedCaseInsensitiveContains("muddle") {
            required.append("Muddler")
        }
        
        // Always need jigger for measuring
        required.append("Jigger")
        
        return Array(Set(required)) // Remove duplicates
    }
}
