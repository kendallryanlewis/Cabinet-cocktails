//
//  TopShelfView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct TopShelfView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @State private var searchText = ""
    @State private var selectedAlcoholTypes: [Ingredient] = []
    @State private var selectedCategory: IngredientType? = nil
    @State private var showClearConfirmation = false
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var showExpirationSettings = false
    
    // Filtered list based on search and category
    var filteredIngredients: [Ingredient] {
        var ingredients = DrinkManager.shared.allIngredients ?? []
        
        // Apply search filter
        if !searchText.isEmpty {
            ingredients = ingredients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            ingredients = ingredients.filter { $0.type == category }
        }
        
        return ingredients.sorted { ingredient1, ingredient2 in
            let in1 = selectedAlcoholTypes.contains(where: { $0.name == ingredient1.name })
            let in2 = selectedAlcoholTypes.contains(where: { $0.name == ingredient2.name })
            if in1 != in2 {
                return in1
            }
            return ingredient1.name < ingredient2.name
        }
    }
    
    var cabinetIngredients: [Ingredient] {
        selectedAlcoholTypes.sorted { $0.name < $1.name }
    }
    
    var cocktailsAvailable: Int {
        DrinkManager.shared.myDrinkPossibilities?.count ?? 0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: colorScheme == .dark ?
                    Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Cabinet")
                            .font(.cocktailTitle)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        
                        if !selectedAlcoholTypes.isEmpty {
                            HStack(spacing: 8) {
                                Text("\(selectedAlcoholTypes.count) ingredient\(selectedAlcoholTypes.count == 1 ? "" : "s")")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                if cocktailsAvailable > 0 {
                                    Text("•")
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                    
                                    Text("\(cocktailsAvailable) cocktail\(cocktailsAvailable == 1 ? "" : "s") ready")
                                        .font(.bodyText)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                
                                if expirationTracker.expiringSoonCount > 0 || expirationTracker.expiredCount > 0 {
                                    Text("•")
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 12))
                                        Text("\(expirationTracker.expiringSoonCount + expirationTracker.expiredCount) expiring")
                                    }
                                    .font(.bodyText)
                                    .foregroundColor(expirationTracker.expiredCount > 0 ? .red : .orange)
                                }
                            }
                        } else {
                            Text("Add ingredients to see what you can make")
                                .font(.bodyText)
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Expiring Soon Section
                    if !expirationTracker.expiringSoonItems.isEmpty || !expirationTracker.expiredItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(expirationTracker.expiredItems.isEmpty ? .orange : .red)
                                
                                Text(expirationTracker.expiredItems.isEmpty ? "Expiring Soon" : "Action Needed")
                                    .font(.sectionHeader)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                
                                Spacer()
                                
                                Button(action: { showExpirationSettings = true }) {
                                    Text("Manage")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(expirationTracker.expiredItems + expirationTracker.expiringSoonItems) { item in
                                        ExpirationWarningCard(item: item)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Active Cabinet Section
                    if !cabinetIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("In Your Cabinet")
                                    .font(.sectionHeader)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                
                                Spacer()
                                
                                Button(action: { showExpirationSettings = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.system(size: 14))
                                        Text("Track Expiration")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(COLOR_WARM_AMBER)
                                }
                                
                                Button(action: {
                                    showClearConfirmation = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                        Text("Clear All")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(cabinetIngredients, id: \.id) { ingredient in
                                        CabinetIngredientChip(
                                            ingredient: ingredient,
                                            expirationInfo: expirationTracker.getExpirationInfo(for: ingredient.name),
                                            onRemove: {
                                                removeIngredient(ingredient)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        
                        TextField("Search ingredients", text: $searchText)
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .tint(COLOR_WARM_AMBER)
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search ingredients")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        }
                    }
                    .padding(12)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            CategoryFilterButton(
                                title: "Alcohol",
                                isSelected: selectedCategory == .alcohol,
                                action: { selectedCategory = .alcohol }
                            )
                            
                            CategoryFilterButton(
                                title: "Mixers",
                                isSelected: selectedCategory == .mixer,
                                action: { selectedCategory = .mixer }
                            )
                            
                            CategoryFilterButton(
                                title: "Garnish",
                                isSelected: selectedCategory == .garnish,
                                action: { selectedCategory = .garnish }
                            )
                            
                            CategoryFilterButton(
                                title: "Non-Alcoholic",
                                isSelected: selectedCategory == .nonAlcohol,
                                action: { selectedCategory = .nonAlcohol }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Browse All Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Browse Ingredients")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Spacer()
                            
                            Text("\(filteredIngredients.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        .padding(.horizontal)
                        
                        if filteredIngredients.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                Text("No ingredients found")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                Button(action: {
                                    searchText = ""
                                    selectedCategory = nil
                                }) {
                                    Text("Clear Filters")
                                        .font(.buttonText)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredIngredients, id: \.id) { ingredient in
                                    ModernCabinetCard(
                                        ingredient: ingredient,
                                        isInCabinet: selectedAlcoholTypes.contains(where: { $0.name == ingredient.name }),
                                        onTap: {
                                            toggleIngredient(ingredient)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            if DrinkManager.shared.allIngredients == nil {
                DrinkManager.shared.getAllUniqueIngredients()
            }
            
            // Load saved ingredients
            LocalStorageManager.shared.retrieveTopShelfItems().forEach { item in
                if let foundItem = DrinkManager.shared.allIngredients?.first(where: { $0.name == item }) {
                    if !selectedAlcoholTypes.contains(where: { $0.name == foundItem.name }) {
                        selectedAlcoholTypes.append(foundItem)
                    }
                }
            }
        }
        .actionSheet(isPresented: $showClearConfirmation) {
            ActionSheet(
                title: Text("Clear Cabinet"),
                message: Text("Remove all \(selectedAlcoholTypes.count) ingredients from your cabinet?"),
                buttons: [
                    .destructive(Text("Clear All Ingredients")) {
                        clearAllIngredients()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showExpirationSettings) {
            ExpirationManagementView()
        }
    }
    
    private func toggleIngredient(_ ingredient: Ingredient) {
        if let index = selectedAlcoholTypes.firstIndex(where: { $0.name == ingredient.name }) {
            selectedAlcoholTypes.remove(at: index)
            if let storageIndex = LocalStorageManager.shared.retrieveTopShelfItems().firstIndex(of: ingredient.name) {
                LocalStorageManager.shared.removeTopShelfItem(at: storageIndex)
            }
        } else {
            selectedAlcoholTypes.append(ingredient)
            LocalStorageManager.shared.addTopShelfItem(newItem: ingredient.name)
        }
        DrinkManager.shared.onlyYourIngredients()
    }
    
    private func removeIngredient(_ ingredient: Ingredient) {
        if let index = selectedAlcoholTypes.firstIndex(where: { $0.name == ingredient.name }) {
            selectedAlcoholTypes.remove(at: index)
            if let storageIndex = LocalStorageManager.shared.retrieveTopShelfItems().firstIndex(of: ingredient.name) {
                LocalStorageManager.shared.removeTopShelfItem(at: storageIndex)
            }
            DrinkManager.shared.onlyYourIngredients()
        }
    }
    
    private func clearAllIngredients() {
        selectedAlcoholTypes.removeAll()
        // Clear all from storage
        let count = LocalStorageManager.shared.retrieveTopShelfItems().count
        for i in (0..<count).reversed() {
            LocalStorageManager.shared.removeTopShelfItem(at: i)
        }
        DrinkManager.shared.onlyYourIngredients()
    }
}

// MARK: - Cabinet Ingredient Chip
struct CabinetIngredientChip: View {
    let ingredient: Ingredient
    let expirationInfo: ExpirationInfo?
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Small thumbnail
            if UIImage(named: ingredient.name) != nil {
                Image(ingredient.name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(COLOR_CHARCOAL)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 14))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(1)
                
                // Expiration badge
                if let info = expirationInfo {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(info.isExpired ? Color.red : (info.isExpiringSoon ? Color.orange : Color.green))
                            .frame(width: 6, height: 6)
                        
                        Text(info.isExpired ? "Expired" : "\\(abs(info.daysUntilExpiration))d")
                            .font(.system(size: 9))
                            .foregroundColor(info.isExpired ? .red : (info.isExpiringSoon ? .orange : COLOR_TEXT_SECONDARY))
                    }
                }
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
    }
}

// MARK: - Modern Cabinet Card
struct ModernCabinetCard: View {
    let ingredient: Ingredient
    let isInCabinet: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Image with checkmark overlay
                ZStack(alignment: .topTrailing) {
                    if UIImage(named: ingredient.name) != nil {
                        Image(ingredient.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    } else {
                        ZStack {
                            COLOR_CHARCOAL
                            Image("GenericAlcohol")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .opacity(0.3)
                        }
                        .frame(height: 120)
                    }
                    
                    // Status indicator
                    if isInCabinet {
                        ZStack {
                            Circle()
                                .fill(COLOR_CHARCOAL_LIGHT)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(COLOR_WARM_AMBER)
                                .font(.system(size: 24))
                        }
                        .padding(6)
                    } else {
                        ZStack {
                            Circle()
                                .fill(COLOR_CHARCOAL_LIGHT.opacity(0.8))
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "plus.circle")
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .font(.system(size: 24))
                        }
                        .padding(6)
                    }
                }
                
                // Info section
                VStack(alignment: .leading, spacing: 6) {
                    Text(ingredient.name)
                        .font(.ingredientText)
                        .fontWeight(.semibold)
                        .foregroundColor(isInCabinet ? COLOR_TEXT_PRIMARY : COLOR_TEXT_SECONDARY)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(ingredient.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(isInCabinet ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(COLOR_CHARCOAL_LIGHT)
            }
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(isInCabinet ? 0.4 : 0.2), radius: isInCabinet ? 10 : 6, x: 0, y: isInCabinet ? 5 : 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - Expiration Warning Card
struct ExpirationWarningCard: View {
    let item: ExpirationInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(item.isExpired ? Color.red : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(item.ingredientName)
                    .font(.bodyText)
                    .fontWeight(.semibold)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(1)
            }
            
            Text(item.isExpired ? "Expired \(abs(item.daysUntilExpiration)) days ago" : "Expires in \(item.daysUntilExpiration) day\(item.daysUntilExpiration == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(item.isExpired ? .red : .orange)
        }
        .padding(12)
        .frame(width: 160)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isExpired ? Color.red.opacity(0.5) : Color.orange.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Expiration Management View
struct ExpirationManagementView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var showAddExpiration = false
    @State private var selectedIngredient: String = ""
    @State private var selectedDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    @State private var notes = ""
    
    var cabinetIngredients: [String] {
        LocalStorageManager.shared.retrieveTopShelfItems()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: colorScheme == .dark ?
                        Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                        Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                    startPoint: .topTrailing,
                    endPoint: .leading
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Stats
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Tracked",
                                    value: "\\(expirationTracker.totalTrackedIngredients)",
                                    color: COLOR_WARM_AMBER
                                )
                                
                                StatCard(
                                    title: "Expiring Soon",
                                    value: "\\(expirationTracker.expiringSoonCount)",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "Expired",
                                    value: "\\(expirationTracker.expiredCount)",
                                    color: .red
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Notifications Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: Binding(
                                get: { expirationTracker.notificationsEnabled },
                                set: { expirationTracker.toggleNotifications($0) }
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Expiration Reminders")
                                        .font(.bodyText)
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                    
                                    Text("Get notified 3 days before ingredients expire")
                                        .font(.caption)
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                }
                            }
                            .tint(COLOR_WARM_AMBER)
                            .padding(16)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Add Expiration Button
                        Button(action: { showAddExpiration = true }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 18))
                                Text("Track New Expiration Date")
                                    .font(.bodyText)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Expired Items
                        if !expirationTracker.expiredItems.isEmpty {
                            ExpirationSection(
                                title: "Expired",
                                items: expirationTracker.expiredItems,
                                color: .red,
                                icon: "xmark.circle.fill"
                            )
                        }
                        
                        // Expiring Soon Items
                        if !expirationTracker.expiringSoonItems.isEmpty {
                            ExpirationSection(
                                title: "Expiring Soon",
                                items: expirationTracker.expiringSoonItems,
                                color: .orange,
                                icon: "exclamationmark.triangle.fill"
                            )
                        }
                        
                        // Fresh Items
                        if !expirationTracker.freshItems.isEmpty {
                            ExpirationSection(
                                title: "Fresh",
                                items: expirationTracker.freshItems,
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )
                        }
                        
                        // Clear Expired Button
                        if !expirationTracker.expiredItems.isEmpty {
                            Button(action: {
                                expirationTracker.clearExpiredItems()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear Expired Items")
                                        .font(.bodyText)
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Expiration Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .sheet(isPresented: $showAddExpiration) {
                AddExpirationView(isPresented: $showAddExpiration)
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}

// MARK: - Expiration Section
struct ExpirationSection: View {
    let title: String
    let items: [ExpirationInfo]
    let color: Color
    let icon: String
    @StateObject private var expirationTracker = ExpirationTracker.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Spacer()
                
                Text("\\(items.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(items) { item in
                    ExpirationItemRow(item: item, color: color)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Expiration Item Row
struct ExpirationItemRow: View {
    let item: ExpirationInfo
    let color: Color
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var showEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ingredientName)
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text(dateString(item.expirationDate))
                    .font(.caption)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .italic()
                }
            }
            
            Spacer()
            
            Text(item.isExpired ? "Expired" : "\\(item.daysUntilExpiration)d")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Button(action: {
                expirationTracker.removeExpirationInfo(for: item.id)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Add Expiration View
struct AddExpirationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var selectedIngredient: String = ""
    @State private var selectedDate = Date().addingTimeInterval(30 * 24 * 60 * 60)
    @State private var notes = ""
    @State private var showCustomIngredient = false
    @State private var customIngredient = ""
    
    var cabinetIngredients: [String] {
        LocalStorageManager.shared.retrieveTopShelfItems().sorted()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: colorScheme == .dark ?
                        Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                        Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                    startPoint: .topTrailing,
                    endPoint: .leading
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Ingredient Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ingredient")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            if cabinetIngredients.isEmpty {
                                Text("Your cabinet is empty. Add ingredients first.")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(12)
                            } else {
                                Menu {
                                    ForEach(cabinetIngredients, id: \.self) { ingredient in
                                        Button(ingredient) {
                                            selectedIngredient = ingredient
                                        }
                                    }
                                    
                                    Button("Custom Ingredient...") {
                                        showCustomIngredient = true
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedIngredient.isEmpty ? "Select ingredient" : selectedIngredient)
                                            .font(.bodyText)
                                            .foregroundColor(selectedIngredient.isEmpty ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(12)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Date Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expiration Date")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(COLOR_WARM_AMBER)
                                .padding(12)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (Optional)")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            TextEditor(text: $notes)
                                .font(.bodyText)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .frame(height: 80)
                                .padding(8)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                        }
                        
                        // Add Button
                        Button(action: {
                            let ingredient = showCustomIngredient ? customIngredient : selectedIngredient
                            if !ingredient.isEmpty {
                                expirationTracker.addExpirationInfo(
                                    ingredientName: ingredient,
                                    expirationDate: selectedDate,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                isPresented = false
                            }
                        }) {
                            Text("Add Expiration Date")
                                .font(.bodyText)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedIngredient.isEmpty && !showCustomIngredient ? COLOR_TEXT_SECONDARY : COLOR_CHARCOAL)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background((selectedIngredient.isEmpty && !showCustomIngredient) ? COLOR_CHARCOAL : COLOR_WARM_AMBER)
                                .cornerRadius(12)
                        }
                        .disabled(selectedIngredient.isEmpty && !showCustomIngredient)
                    }
                    .padding()
                }
            }
            .navigationTitle("Track Expiration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .alert("Custom Ingredient", isPresented: $showCustomIngredient) {
                TextField("Ingredient name", text: $customIngredient)
                Button("Add") {
                    selectedIngredient = customIngredient
                    showCustomIngredient = false
                }
                Button("Cancel", role: .cancel) {
                    showCustomIngredient = false
                }
            }
        }
    }
}
