//
//  SearchFilterManager.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import Foundation
import SwiftUI

// MARK: - Search Filter
struct SearchFilter: Codable {
    var categories: Set<String>
    var glassTypes: Set<String>
    var alcoholicTypes: Set<String>
    var ingredients: Set<String>
    var sortOption: SortOption
    
    init() {
        self.categories = []
        self.glassTypes = []
        self.alcoholicTypes = []
        self.ingredients = []
        self.sortOption = .nameAscending
    }
    
    var isActive: Bool {
        return !categories.isEmpty || !glassTypes.isEmpty || !alcoholicTypes.isEmpty || !ingredients.isEmpty
    }
    
    var activeCount: Int {
        return categories.count + glassTypes.count + alcoholicTypes.count + ingredients.count
    }
    
    mutating func clear() {
        categories.removeAll()
        glassTypes.removeAll()
        alcoholicTypes.removeAll()
        ingredients.removeAll()
    }
}

// MARK: - Sort Option
enum SortOption: String, Codable, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case categoryAscending = "Category (A-Z)"
    case mostIngredients = "Most Ingredients"
    case leastIngredients = "Fewest Ingredients"
    case alcoholicFirst = "Alcoholic First"
    case nonAlcoholicFirst = "Non-Alcoholic First"
    
    var icon: String {
        switch self {
        case .nameAscending: return "arrow.up.arrow.down"
        case .nameDescending: return "arrow.down.arrow.up"
        case .categoryAscending: return "folder"
        case .mostIngredients: return "list.bullet"
        case .leastIngredients: return "list.dash"
        case .alcoholicFirst: return "wineglass"
        case .nonAlcoholicFirst: return "drop"
        }
    }
}

// MARK: - Search History Item
struct SearchHistoryItem: Identifiable, Codable {
    let id: UUID
    let query: String
    let timestamp: Date
    let resultCount: Int
    
    init(id: UUID = UUID(), query: String, resultCount: Int, timestamp: Date = Date()) {
        self.id = id
        self.query = query
        self.resultCount = resultCount
        self.timestamp = timestamp
    }
}

// MARK: - Saved Search
struct SavedSearch: Identifiable, Codable {
    let id: UUID
    var name: String
    var query: String
    var filter: SearchFilter
    let createdDate: Date
    var lastUsedDate: Date
    
    init(id: UUID = UUID(),
         name: String,
         query: String,
         filter: SearchFilter,
         createdDate: Date = Date(),
         lastUsedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.query = query
        self.filter = filter
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
    }
}

// MARK: - Search Filter Manager
@MainActor
class SearchFilterManager: ObservableObject {
    static let shared = SearchFilterManager()
    
    @Published var currentFilter = SearchFilter()
    @Published private(set) var searchHistory: [SearchHistoryItem] = []
    @Published private(set) var savedSearches: [SavedSearch] = []
    
    private let historyKey = "search_history"
    private let savedSearchesKey = "saved_searches"
    private let maxHistoryItems = 50
    
    private init() {
        loadHistory()
        loadSavedSearches()
    }
    
    // MARK: - Search History
    
    func addToHistory(query: String, resultCount: Int) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Remove duplicate if exists
        searchHistory.removeAll { $0.query.lowercased() == query.lowercased() }
        
        // Add new entry at the beginning
        let item = SearchHistoryItem(query: query, resultCount: resultCount)
        searchHistory.insert(item, at: 0)
        
        // Limit history size
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        searchHistory.removeAll()
        saveHistory()
    }
    
    func removeFromHistory(_ item: SearchHistoryItem) {
        searchHistory.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    func getRecentSearches(limit: Int = 10) -> [SearchHistoryItem] {
        return Array(searchHistory.prefix(limit))
    }
    
    // MARK: - Saved Searches
    
    func saveSearch(name: String, query: String, filter: SearchFilter) {
        let search = SavedSearch(name: name, query: query, filter: filter)
        savedSearches.append(search)
        saveSavedSearches()
    }
    
    func updateSavedSearch(_ search: SavedSearch) {
        if let index = savedSearches.firstIndex(where: { $0.id == search.id }) {
            savedSearches[index] = search
            saveSavedSearches()
        }
    }
    
    func deleteSavedSearch(_ search: SavedSearch) {
        savedSearches.removeAll { $0.id == search.id }
        saveSavedSearches()
    }
    
    func markSavedSearchAsUsed(_ searchId: UUID) {
        if let index = savedSearches.firstIndex(where: { $0.id == searchId }) {
            savedSearches[index].lastUsedDate = Date()
            saveSavedSearches()
        }
    }
    
    func getRecentSavedSearches(limit: Int = 5) -> [SavedSearch] {
        return savedSearches
            .sorted { $0.lastUsedDate > $1.lastUsedDate }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Filter Application
    
    func applyFilter(_ filter: SearchFilter) {
        currentFilter = filter
    }
    
    func clearFilter() {
        currentFilter.clear()
    }
    
    func filterCocktails(_ cocktails: [DrinkDetails]) -> [DrinkDetails] {
        var result = cocktails
        
        // Filter by category
        if !currentFilter.categories.isEmpty {
            result = result.filter { cocktail in
                guard let category = cocktail.strCategory else { return false }
                return currentFilter.categories.contains(category)
            }
        }
        
        // Filter by glass type
        if !currentFilter.glassTypes.isEmpty {
            result = result.filter { cocktail in
                guard let glass = cocktail.strGlass else { return false }
                return currentFilter.glassTypes.contains(glass)
            }
        }
        
        // Filter by alcoholic type
        if !currentFilter.alcoholicTypes.isEmpty {
            result = result.filter { cocktail in
                return currentFilter.alcoholicTypes.contains(cocktail.strAlcoholic)
            }
        }
        
        // Filter by ingredients
        if !currentFilter.ingredients.isEmpty {
            result = result.filter { cocktail in
                let cocktailIngredients = cocktail.getIngredients().map { $0.lowercased() }
                return currentFilter.ingredients.allSatisfy { filterIngredient in
                    cocktailIngredients.contains { $0.contains(filterIngredient.lowercased()) }
                }
            }
        }
        
        return result
    }
    
    func sortCocktails(_ cocktails: [DrinkDetails], by sortOption: SortOption) -> [DrinkDetails] {
        switch sortOption {
        case .nameAscending:
            return cocktails.sorted { $0.strDrink < $1.strDrink }
        case .nameDescending:
            return cocktails.sorted { $0.strDrink > $1.strDrink }
        case .categoryAscending:
            return cocktails.sorted { ($0.strCategory ?? "") < ($1.strCategory ?? "") }
        case .mostIngredients:
            return cocktails.sorted { $0.getIngredients().count > $1.getIngredients().count }
        case .leastIngredients:
            return cocktails.sorted { $0.getIngredients().count < $1.getIngredients().count }
        case .alcoholicFirst:
            return cocktails.sorted { 
                if $0.strAlcoholic == "Alcoholic" && $1.strAlcoholic != "Alcoholic" {
                    return true
                }
                if $0.strAlcoholic != "Alcoholic" && $1.strAlcoholic == "Alcoholic" {
                    return false
                }
                return $0.strDrink < $1.strDrink
            }
        case .nonAlcoholicFirst:
            return cocktails.sorted { 
                if $0.strAlcoholic != "Alcoholic" && $1.strAlcoholic == "Alcoholic" {
                    return true
                }
                if $0.strAlcoholic == "Alcoholic" && $1.strAlcoholic != "Alcoholic" {
                    return false
                }
                return $0.strDrink < $1.strDrink
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(searchHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([SearchHistoryItem].self, from: data) {
            searchHistory = decoded
        }
    }
    
    private func saveSavedSearches() {
        if let encoded = try? JSONEncoder().encode(savedSearches) {
            UserDefaults.standard.set(encoded, forKey: savedSearchesKey)
        }
    }
    
    private func loadSavedSearches() {
        if let data = UserDefaults.standard.data(forKey: savedSearchesKey),
           let decoded = try? JSONDecoder().decode([SavedSearch].self, from: data) {
            savedSearches = decoded
        }
    }
}
