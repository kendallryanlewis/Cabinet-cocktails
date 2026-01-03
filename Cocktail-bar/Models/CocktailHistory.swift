//
//  CocktailHistory.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import Foundation

// MARK: - Time Period Filter
enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case allTime = "All Time"
    
    func dateRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            return (start, now)
        case .thisWeek:
            guard let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return nil }
            return (start, now)
        case .thisMonth:
            guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return nil }
            return (start, now)
        case .allTime:
            return nil // No filter
        }
    }
}

// MARK: - Cocktail History Item
struct CocktailHistoryItem: Codable, Identifiable {
    let id: UUID
    var cocktailName: String
    var drinkId: String
    var dateMade: Date
    var rating: Int? // 1-5 stars, optional
    var notes: String?
    var ingredients: [String]? // Store ingredients used
    
    init(id: UUID = UUID(), cocktailName: String, drinkId: String, dateMade: Date = Date(), rating: Int? = nil, notes: String? = nil, ingredients: [String]? = nil) {
        self.id = id
        self.cocktailName = cocktailName
        self.drinkId = drinkId
        self.dateMade = dateMade
        self.rating = rating
        self.notes = notes
        self.ingredients = ingredients
    }
    
    // Group key for section headers
    var sectionDate: Date {
        Calendar.current.startOfDay(for: dateMade)
    }
    
    // Formatted date for display
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateMade)
    }
    
    var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(dateMade) {
            return "Today"
        } else if calendar.isDateInYesterday(dateMade) {
            return "Yesterday"
        } else if calendar.isDate(dateMade, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day name
            return formatter.string(from: dateMade)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: dateMade)
        }
    }
}

// MARK: - History Statistics
struct HistoryStatistics {
    var totalCocktailsMade: Int
    var uniqueCocktails: Int
    var favoriteCocktails: [(name: String, count: Int)]
    var mostUsedIngredients: [(ingredient: String, count: Int)]
    var averageRating: Double?
    var cocktailsThisWeek: Int
    var cocktailsThisMonth: Int
    var currentStreak: Int // Days in a row making cocktails
}

// MARK: - Cocktail History Manager
@MainActor
class CocktailHistoryManager: ObservableObject {
    static let shared = CocktailHistoryManager()
    
    @Published var historyItems: [CocktailHistoryItem] = []
    
    private let storageKey = "CocktailHistory"
    private let maxHistoryItems = 500 // Limit to prevent storage bloat
    
    private init() {
        loadHistory()
    }
    
    // MARK: - CRUD Operations
    
    func addToHistory(cocktailName: String, drinkId: String, rating: Int? = nil, notes: String? = nil, ingredients: [String]? = nil) {
        let item = CocktailHistoryItem(
            cocktailName: cocktailName,
            drinkId: drinkId,
            rating: rating,
            notes: notes,
            ingredients: ingredients
        )
        
        historyItems.insert(item, at: 0) // Add to beginning
        
        // Limit history size
        if historyItems.count > maxHistoryItems {
            historyItems = Array(historyItems.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    func updateHistoryItem(_ item: CocktailHistoryItem) {
        if let index = historyItems.firstIndex(where: { $0.id == item.id }) {
            historyItems[index] = item
            saveHistory()
        }
    }
    
    func deleteHistoryItem(_ item: CocktailHistoryItem) {
        historyItems.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    func clearHistory() {
        historyItems.removeAll()
        saveHistory()
    }
    
    func clearOldHistory(olderThan days: Int) {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else { return }
        
        historyItems.removeAll { $0.dateMade < cutoffDate }
        saveHistory()
    }
    
    // MARK: - Filtering & Searching
    
    func getHistory(for period: TimePeriod) -> [CocktailHistoryItem] {
        guard let range = period.dateRange() else { return historyItems }
        return historyItems.filter { $0.dateMade >= range.start && $0.dateMade <= range.end }
    }
    
    func searchHistory(query: String) -> [CocktailHistoryItem] {
        guard !query.isEmpty else { return historyItems }
        let lowercased = query.lowercased()
        return historyItems.filter {
            $0.cocktailName.lowercased().contains(lowercased) ||
            ($0.notes?.lowercased().contains(lowercased) ?? false) ||
            ($0.ingredients?.contains(where: { $0.lowercased().contains(lowercased) }) ?? false)
        }
    }
    
    func groupedByDate(_ items: [CocktailHistoryItem]) -> [(date: Date, items: [CocktailHistoryItem])] {
        let grouped = Dictionary(grouping: items, by: { $0.sectionDate })
        return grouped.map { (date: $0.key, items: $0.value.sorted { $0.dateMade > $1.dateMade }) }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> HistoryStatistics {
        let uniqueCocktails = Set(historyItems.map { $0.cocktailName }).count
        
        // Favorite cocktails (most made)
        let cocktailCounts = Dictionary(grouping: historyItems, by: { $0.cocktailName })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (name: $0.key, count: $0.value) }
        
        // Most used ingredients
        var ingredientCounts: [String: Int] = [:]
        for item in historyItems {
            if let ingredients = item.ingredients {
                for ingredient in ingredients {
                    ingredientCounts[ingredient, default: 0] += 1
                }
            }
        }
        let topIngredients = ingredientCounts.sorted { $0.value > $1.value }
            .prefix(10)
            .map { (ingredient: $0.key, count: $0.value) }
        
        // Average rating
        let ratingsOnly = historyItems.compactMap { $0.rating }
        let averageRating = ratingsOnly.isEmpty ? nil : Double(ratingsOnly.reduce(0, +)) / Double(ratingsOnly.count)
        
        // This week/month counts
        let thisWeek = getHistory(for: .thisWeek).count
        let thisMonth = getHistory(for: .thisMonth).count
        
        // Current streak
        let streak = calculateCurrentStreak()
        
        return HistoryStatistics(
            totalCocktailsMade: historyItems.count,
            uniqueCocktails: uniqueCocktails,
            favoriteCocktails: cocktailCounts,
            mostUsedIngredients: topIngredients,
            averageRating: averageRating,
            cocktailsThisWeek: thisWeek,
            cocktailsThisMonth: thisMonth,
            currentStreak: streak
        )
    }
    
    func getCocktailCount(for cocktailName: String) -> Int {
        historyItems.filter { $0.cocktailName == cocktailName }.count
    }
    
    func getLastMade(for cocktailName: String) -> Date? {
        historyItems.first(where: { $0.cocktailName == cocktailName })?.dateMade
    }
    
    func hasMade(_ cocktailName: String) -> Bool {
        historyItems.contains(where: { $0.cocktailName == cocktailName })
    }
    
    // MARK: - Streak Calculation
    
    private func calculateCurrentStreak() -> Int {
        guard !historyItems.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = historyItems.map { calendar.startOfDay(for: $0.dateMade) }.sorted(by: >)
        let uniqueDates = Array(Set(sortedDates)).sorted(by: >)
        
        guard let mostRecent = uniqueDates.first else { return 0 }
        
        // Check if most recent is today or yesterday
        let today = calendar.startOfDay(for: Date())
        guard mostRecent == today || calendar.isDateInYesterday(mostRecent) else { return 0 }
        
        var streak = 1
        var currentDate = mostRecent
        
        for date in uniqueDates.dropFirst() {
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate),
               date == previousDay {
                streak += 1
                currentDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(historyItems) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CocktailHistoryItem].self, from: data) {
            historyItems = decoded
        }
    }
    
    // MARK: - Export
    
    func exportHistoryAsText() -> String {
        var text = "🍸 Cabinet Cocktails - My History\n\n"
        
        let stats = getStatistics()
        text += "📊 Statistics:\n"
        text += "Total Cocktails Made: \(stats.totalCocktailsMade)\n"
        text += "Unique Cocktails: \(stats.uniqueCocktails)\n"
        if let avgRating = stats.averageRating {
            text += "Average Rating: \(String(format: "%.1f", avgRating))⭐️\n"
        }
        text += "Current Streak: \(stats.currentStreak) days\n\n"
        
        if !stats.favoriteCocktails.isEmpty {
            text += "🏆 Top Cocktails:\n"
            for (index, favorite) in stats.favoriteCocktails.enumerated() {
                text += "\(index + 1). \(favorite.name) - \(favorite.count) times\n"
            }
            text += "\n"
        }
        
        let grouped = groupedByDate(historyItems)
        for group in grouped {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            text += "\n📅 \(formatter.string(from: group.date))\n"
            
            for item in group.items {
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .short
                text += "  • \(item.cocktailName) - \(timeFormatter.string(from: item.dateMade))"
                if let rating = item.rating {
                    text += " - \(String(repeating: "⭐️", count: rating))"
                }
                text += "\n"
            }
        }
        
        return text
    }
}
