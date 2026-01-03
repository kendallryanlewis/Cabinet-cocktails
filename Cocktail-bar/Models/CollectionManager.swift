//
//  CollectionManager.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import Foundation
import SwiftUI

// MARK: - Cocktail Tag
struct CocktailTag: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var color: String // Hex color string
    let createdDate: Date
    
    init(id: UUID = UUID(), name: String, color: String = "#D4A574", createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.createdDate = createdDate
    }
    
    var displayColor: Color {
        Color(hex: color) ?? COLOR_WARM_AMBER
    }
    
    // Predefined tag colors
    static let tagColors: [String: String] = [
        "Amber": "#D4A574",
        "Blue": "#5B9BD5",
        "Green": "#70AD47",
        "Red": "#E74C3C",
        "Purple": "#9B59B6",
        "Orange": "#F39C12",
        "Pink": "#E91E63",
        "Teal": "#1ABC9C",
        "Gray": "#95A5A6"
    ]
}

// MARK: - Cocktail Collection Item
struct CollectionCocktail: Identifiable, Codable {
    let id: UUID
    let drinkId: String
    let drinkName: String
    let drinkThumb: String?
    let addedDate: Date
    var notes: String?
    
    init(id: UUID = UUID(),
         drinkId: String,
         drinkName: String,
         drinkThumb: String? = nil,
         addedDate: Date = Date(),
         notes: String? = nil) {
        self.id = id
        self.drinkId = drinkId
        self.drinkName = drinkName
        self.drinkThumb = drinkThumb
        self.addedDate = addedDate
        self.notes = notes
    }
}

// MARK: - Cocktail Collection
struct CocktailCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String?
    var cocktails: [CollectionCocktail]
    var tags: [UUID] // Tag IDs
    var iconName: String
    var colorHex: String
    let createdDate: Date
    var modifiedDate: Date
    var isFavorite: Bool
    
    init(id: UUID = UUID(),
         name: String,
         description: String? = nil,
         cocktails: [CollectionCocktail] = [],
         tags: [UUID] = [],
         iconName: String = "folder.fill",
         colorHex: String = "#D4A574",
         createdDate: Date = Date(),
         modifiedDate: Date = Date(),
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.cocktails = cocktails
        self.tags = tags
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.isFavorite = isFavorite
    }
    
    var displayColor: Color {
        Color(hex: colorHex) ?? COLOR_WARM_AMBER
    }
    
    var cocktailCount: Int {
        cocktails.count
    }
    
    // Predefined collection icons
    static let collectionIcons = [
        "folder.fill", "star.fill", "heart.fill", "flame.fill",
        "snowflake", "sun.max.fill", "moon.stars.fill", "sparkles",
        "party.popper.fill", "gift.fill", "wineglass.fill", "birthday.cake.fill"
    ]
    
    // Predefined collection colors (same as tags)
    static let collectionColors = CocktailTag.tagColors
}

// MARK: - Collection Manager
@MainActor
class CollectionManager: ObservableObject {
    static let shared = CollectionManager()
    
    @Published private(set) var collections: [CocktailCollection] = []
    @Published private(set) var tags: [CocktailTag] = []
    
    private let collectionsKey = "cocktail_collections"
    private let tagsKey = "cocktail_tags"
    
    private init() {
        loadCollections()
        loadTags()
        createDefaultTagsIfNeeded()
    }
    
    // MARK: - Collections Management
    
    func createCollection(name: String,
                         description: String? = nil,
                         iconName: String = "folder.fill",
                         colorHex: String = "#D4A574",
                         tags: [UUID] = []) {
        let collection = CocktailCollection(
            name: name,
            description: description,
            tags: tags,
            iconName: iconName,
            colorHex: colorHex
        )
        collections.append(collection)
        saveCollections()
    }
    
    func updateCollection(_ collection: CocktailCollection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            var updated = collection
            updated.modifiedDate = Date()
            collections[index] = updated
            saveCollections()
        }
    }
    
    func deleteCollection(_ collection: CocktailCollection) {
        collections.removeAll { $0.id == collection.id }
        saveCollections()
    }
    
    func deleteCollections(at offsets: IndexSet) {
        collections.remove(atOffsets: offsets)
        saveCollections()
    }
    
    func toggleCollectionFavorite(_ collection: CocktailCollection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            collections[index].isFavorite.toggle()
            collections[index].modifiedDate = Date()
            saveCollections()
        }
    }
    
    // MARK: - Cocktail Management within Collections
    
    func addCocktail(to collectionId: UUID,
                    drinkId: String,
                    drinkName: String,
                    drinkThumb: String? = nil,
                    notes: String? = nil) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        
        // Check if cocktail already exists in collection
        if collections[index].cocktails.contains(where: { $0.drinkId == drinkId }) {
            return
        }
        
        let cocktail = CollectionCocktail(
            drinkId: drinkId,
            drinkName: drinkName,
            drinkThumb: drinkThumb,
            notes: notes
        )
        
        collections[index].cocktails.append(cocktail)
        collections[index].modifiedDate = Date()
        saveCollections()
    }
    
    func removeCocktail(from collectionId: UUID, cocktailId: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        collections[index].cocktails.removeAll { $0.id == cocktailId }
        collections[index].modifiedDate = Date()
        saveCollections()
    }
    
    func updateCocktailNotes(in collectionId: UUID, cocktailId: UUID, notes: String?) {
        guard let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }),
              let cocktailIndex = collections[collectionIndex].cocktails.firstIndex(where: { $0.id == cocktailId }) else {
            return
        }
        
        collections[collectionIndex].cocktails[cocktailIndex].notes = notes
        collections[collectionIndex].modifiedDate = Date()
        saveCollections()
    }
    
    func isCocktailInCollection(_ drinkId: String, collectionId: UUID) -> Bool {
        guard let collection = collections.first(where: { $0.id == collectionId }) else {
            return false
        }
        return collection.cocktails.contains(where: { $0.drinkId == drinkId })
    }
    
    func getCollectionsContaining(drinkId: String) -> [CocktailCollection] {
        return collections.filter { collection in
            collection.cocktails.contains(where: { $0.drinkId == drinkId })
        }
    }
    
    // MARK: - Tags Management
    
    func createTag(name: String, color: String = "#D4A574") {
        // Check if tag with same name already exists
        if tags.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            return
        }
        
        let tag = CocktailTag(name: name, color: color)
        tags.append(tag)
        saveTags()
    }
    
    func updateTag(_ tag: CocktailTag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }
    
    func deleteTag(_ tag: CocktailTag) {
        // Remove tag from all collections
        for i in 0..<collections.count {
            collections[i].tags.removeAll { $0 == tag.id }
        }
        saveCollections()
        
        // Remove tag from tags list
        tags.removeAll { $0.id == tag.id }
        saveTags()
    }
    
    func addTagToCollection(_ tagId: UUID, collectionId: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        
        if !collections[index].tags.contains(tagId) {
            collections[index].tags.append(tagId)
            collections[index].modifiedDate = Date()
            saveCollections()
        }
    }
    
    func removeTagFromCollection(_ tagId: UUID, collectionId: UUID) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        collections[index].tags.removeAll { $0 == tagId }
        collections[index].modifiedDate = Date()
        saveCollections()
    }
    
    func getTag(by id: UUID) -> CocktailTag? {
        return tags.first(where: { $0.id == id })
    }
    
    func getTags(for collection: CocktailCollection) -> [CocktailTag] {
        return collection.tags.compactMap { tagId in
            tags.first(where: { $0.id == tagId })
        }
    }
    
    // MARK: - Filtering & Search
    
    func filterCollections(by tagId: UUID) -> [CocktailCollection] {
        return collections.filter { $0.tags.contains(tagId) }
    }
    
    func searchCollections(query: String) -> [CocktailCollection] {
        guard !query.isEmpty else { return collections }
        
        let lowercasedQuery = query.lowercased()
        return collections.filter { collection in
            collection.name.lowercased().contains(lowercasedQuery) ||
            collection.description?.lowercased().contains(lowercasedQuery) == true ||
            collection.cocktails.contains(where: { $0.drinkName.lowercased().contains(lowercasedQuery) })
        }
    }
    
    func getFavoriteCollections() -> [CocktailCollection] {
        return collections.filter { $0.isFavorite }
    }
    
    func getRecentCollections(limit: Int = 5) -> [CocktailCollection] {
        return collections
            .sorted { $0.modifiedDate > $1.modifiedDate }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Statistics
    
    func getTotalCocktailsCount() -> Int {
        return collections.reduce(0) { $0 + $1.cocktails.count }
    }
    
    func getCollectionsBySize() -> [CocktailCollection] {
        return collections.sorted { $0.cocktails.count > $1.cocktails.count }
    }
    
    // MARK: - Persistence
    
    private func saveCollections() {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: collectionsKey)
        }
    }
    
    private func loadCollections() {
        if let data = UserDefaults.standard.data(forKey: collectionsKey),
           let decoded = try? JSONDecoder().decode([CocktailCollection].self, from: data) {
            collections = decoded
        }
    }
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: tagsKey)
        }
    }
    
    private func loadTags() {
        if let data = UserDefaults.standard.data(forKey: tagsKey),
           let decoded = try? JSONDecoder().decode([CocktailTag].self, from: data) {
            tags = decoded
        }
    }
    
    private func createDefaultTagsIfNeeded() {
        guard tags.isEmpty else { return }
        
        let defaultTags = [
            CocktailTag(name: "Date Night", color: "#E91E63"),
            CocktailTag(name: "Party", color: "#F39C12"),
            CocktailTag(name: "Summer", color: "#F39C12"),
            CocktailTag(name: "Winter", color: "#5B9BD5"),
            CocktailTag(name: "Classics", color: "#D4A574"),
            CocktailTag(name: "Tiki", color: "#1ABC9C"),
            CocktailTag(name: "Strong", color: "#E74C3C"),
            CocktailTag(name: "Refreshing", color: "#70AD47")
        ]
        
        tags = defaultTags
        saveTags()
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
