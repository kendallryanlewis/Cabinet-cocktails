//
//  ExpirationTracker.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import Foundation
import UserNotifications

// MARK: - Expiration Status
enum ExpirationStatus {
    case fresh
    case expiringSoon // Within 7 days
    case expired
    
    var displayText: String {
        switch self {
        case .fresh: return "Fresh"
        case .expiringSoon: return "Use Soon"
        case .expired: return "Expired"
        }
    }
    
    var colorHex: String {
        switch self {
        case .fresh: return "#4CAF50" // Green
        case .expiringSoon: return "#FFC107" // Amber/Yellow
        case .expired: return "#F44336" // Red
        }
    }
}

// MARK: - Expiration Info Model
struct ExpirationInfo: Codable, Identifiable {
    let id: UUID
    var ingredientName: String
    var expirationDate: Date
    var notificationScheduled: Bool
    var dateAdded: Date
    var notes: String?
    
    init(id: UUID = UUID(), ingredientName: String, expirationDate: Date, notificationScheduled: Bool = false, dateAdded: Date = Date(), notes: String? = nil) {
        self.id = id
        self.ingredientName = ingredientName
        self.expirationDate = expirationDate
        self.notificationScheduled = notificationScheduled
        self.dateAdded = dateAdded
        self.notes = notes
    }
    
    // Calculate status based on expiration date
    var status: ExpirationStatus {
        let now = Date()
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: now, to: expirationDate).day ?? 0
        
        if daysUntilExpiration < 0 {
            return .expired
        } else if daysUntilExpiration <= 7 {
            return .expiringSoon
        } else {
            return .fresh
        }
    }
    
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }
    
    var isExpired: Bool {
        status == .expired
    }
    
    var isExpiringSoon: Bool {
        status == .expiringSoon
    }
}

// MARK: - Expiration Tracker Manager
@MainActor
class ExpirationTracker: ObservableObject {
    static let shared = ExpirationTracker()
    
    @Published var expirationItems: [ExpirationInfo] = []
    @Published var notificationsEnabled: Bool = false
    
    private let storageKey = "ExpirationItems"
    private let notificationsKey = "ExpirationNotificationsEnabled"
    
    private init() {
        loadItems()
        loadNotificationPreference()
        requestNotificationPermission()
    }
    
    // MARK: - CRUD Operations
    
    func addExpirationInfo(ingredientName: String, expirationDate: Date, notes: String? = nil) {
        // Check if ingredient already has expiration info
        if let existingIndex = expirationItems.firstIndex(where: { $0.ingredientName.lowercased() == ingredientName.lowercased() }) {
            // Update existing
            expirationItems[existingIndex].expirationDate = expirationDate
            expirationItems[existingIndex].notes = notes
        } else {
            // Add new
            let info = ExpirationInfo(ingredientName: ingredientName, expirationDate: expirationDate, notes: notes)
            expirationItems.append(info)
        }
        
        saveItems()
        
        // Schedule notification if enabled
        if notificationsEnabled {
            scheduleNotification(for: ingredientName, expirationDate: expirationDate)
        }
    }
    
    func updateExpirationDate(for itemId: UUID, newDate: Date) {
        guard let index = expirationItems.firstIndex(where: { $0.id == itemId }) else { return }
        expirationItems[index].expirationDate = newDate
        
        saveItems()
        
        // Reschedule notification
        if notificationsEnabled {
            cancelNotification(for: expirationItems[index].ingredientName)
            scheduleNotification(for: expirationItems[index].ingredientName, expirationDate: newDate)
        }
    }
    
    func removeExpirationInfo(for itemId: UUID) {
        guard let index = expirationItems.firstIndex(where: { $0.id == itemId }) else { return }
        let ingredientName = expirationItems[index].ingredientName
        
        expirationItems.remove(at: index)
        saveItems()
        
        // Cancel notification
        cancelNotification(for: ingredientName)
    }
    
    func removeExpirationInfo(ingredientName: String) {
        expirationItems.removeAll { $0.ingredientName.lowercased() == ingredientName.lowercased() }
        saveItems()
        cancelNotification(for: ingredientName)
    }
    
    func getExpirationInfo(for ingredientName: String) -> ExpirationInfo? {
        expirationItems.first { $0.ingredientName.lowercased() == ingredientName.lowercased() }
    }
    
    // MARK: - Filtering & Sorting
    
    var expiredItems: [ExpirationInfo] {
        expirationItems.filter { $0.isExpired }.sorted { $0.expirationDate < $1.expirationDate }
    }
    
    var expiringSoonItems: [ExpirationInfo] {
        expirationItems.filter { $0.isExpiringSoon }.sorted { $0.expirationDate < $1.expirationDate }
    }
    
    var freshItems: [ExpirationInfo] {
        expirationItems.filter { $0.status == .fresh }.sorted { $0.expirationDate < $1.expirationDate }
    }
    
    func itemsSortedByExpiration() -> [ExpirationInfo] {
        expirationItems.sorted { $0.expirationDate < $1.expirationDate }
    }
    
    // MARK: - Statistics
    
    var totalTrackedIngredients: Int {
        expirationItems.count
    }
    
    var expiredCount: Int {
        expiredItems.count
    }
    
    var expiringSoonCount: Int {
        expiringSoonItems.count
    }
    
    // MARK: - Persistence
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(expirationItems) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ExpirationInfo].self, from: data) {
            expirationItems = decoded
        }
    }
    
    private func saveNotificationPreference() {
        UserDefaults.standard.set(notificationsEnabled, forKey: notificationsKey)
    }
    
    private func loadNotificationPreference() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: notificationsKey)
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        saveNotificationPreference()
        
        if enabled {
            requestNotificationPermission()
            // Schedule all notifications
            for item in expirationItems {
                scheduleNotification(for: item.ingredientName, expirationDate: item.expirationDate)
            }
        } else {
            // Cancel all notifications
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
                if granted {
                    self.notificationsEnabled = true
                    self.saveNotificationPreference()
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotification(for ingredientName: String, expirationDate: Date) {
        // Calculate notification date (3 days before expiration)
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -3, to: expirationDate) else { return }
        
        // Only schedule if notification date is in the future
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Ingredient Expiring Soon"
        content.body = "\(ingredientName) will expire in 3 days. Use it before it goes bad!"
        content.sound = .default
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = "expiration-\(ingredientName.lowercased().replacingOccurrences(of: " ", with: "-"))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        
        // Mark as scheduled
        if let index = expirationItems.firstIndex(where: { $0.ingredientName == ingredientName }) {
            expirationItems[index].notificationScheduled = true
            saveItems()
        }
    }
    
    private func cancelNotification(for ingredientName: String) {
        let identifier = "expiration-\(ingredientName.lowercased().replacingOccurrences(of: " ", with: "-"))"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Mark as not scheduled
        if let index = expirationItems.firstIndex(where: { $0.ingredientName == ingredientName }) {
            expirationItems[index].notificationScheduled = false
            saveItems()
        }
    }
    
    // MARK: - Batch Operations
    
    func clearExpiredItems() {
        let expiredIngredients = expirationItems.filter { $0.isExpired }
        for item in expiredIngredients {
            cancelNotification(for: item.ingredientName)
        }
        expirationItems.removeAll { $0.isExpired }
        saveItems()
    }
    
    func clearAllExpirationData() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        expirationItems.removeAll()
        saveItems()
    }
}
