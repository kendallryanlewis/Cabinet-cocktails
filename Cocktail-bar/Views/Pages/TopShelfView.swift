//
//  TopShelfView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct TopShelfView: View {
    @Binding var isMenuOpen: Bool
    @State private var viewMode: CabinetViewMode = .cabinet
    @State private var searchText = ""
    @State private var selectedAlcoholTypes: [Ingredient] = []
    @State private var selectedCategory: IngredientType? = nil
    @State private var showClearConfirmation = false
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var showExpirationSettings = false
    @State private var showFilterSheet = false

    enum CabinetViewMode {
        case cabinet, browse
    }
    
    // Filtered list based on search and category — excludes items already in cabinet
    var filteredIngredients: [Ingredient] {
        var ingredients = (DrinkManager.shared.allIngredients ?? [])
            .filter { ingredient in
                !selectedAlcoholTypes.contains(where: { $0.name == ingredient.name })
            }
        
        // Apply search filter
        if !searchText.isEmpty {
            ingredients = ingredients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            ingredients = ingredients.filter { $0.type == category }
        }
        
        return ingredients.sorted { $0.name < $1.name }
    }
    
    var cabinetIngredients: [Ingredient] {
        selectedAlcoholTypes.sorted { $0.name < $1.name }
    }
    
    var cocktailsAvailable: Int {
        DrinkManager.shared.myDrinkPossibilities?.count ?? 0
    }
    
    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Sticky Header + Segmented Control ──
                VStack(alignment: .leading, spacing: 0) {
                    // Title + subtitle
                    VStack(alignment: .leading, spacing: 6) {
                        Text("YOUR CABINET")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Text("Your Cabinet")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)

                        if viewMode == .cabinet {
                            if !selectedAlcoholTypes.isEmpty {
                                HStack(spacing: 6) {
                                    Text("\(selectedAlcoholTypes.count) ingredient\(selectedAlcoholTypes.count == 1 ? "" : "s")")
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                    if cocktailsAvailable > 0 {
                                        Text("·").foregroundColor(COLOR_TEXT_SECONDARY)
                                        Text("\(cocktailsAvailable) cocktails ready")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                    }
                                }
                                .font(.system(size: 14))
                            } else {
                                Text("Add ingredients to see what you can make")
                                    .font(.system(size: 14))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 20)

                    // Segmented control
                    HStack(spacing: 0) {
                        SearchModeButton(
                            title: "My Cabinet",
                            icon: "cabinet",
                            isSelected: viewMode == .cabinet,
                            action: { viewMode = .cabinet }
                        )
                        SearchModeButton(
                            title: "Add Ingredients",
                            icon: "plus.circle",
                            isSelected: viewMode == .browse,
                            action: { viewMode = .browse }
                        )
                    }
                    .padding(3)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(COLOR_BACKGROUND)

                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                // ── Scrollable content ──
                ScrollView(showsIndicators: false) {
                    if viewMode == .cabinet {
                        cabinetContent
                    } else {
                        browseContent
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
        .sheet(isPresented: $showFilterSheet) {
            TopShelfFilterSheet(selectedCategory: $selectedCategory)
        }
    }
    }

    // MARK: - Cabinet Tab
    @ViewBuilder
    private var cabinetContent: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Expiration warnings
            if !expirationTracker.expiringSoonItems.isEmpty || !expirationTracker.expiredItems.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(expirationTracker.expiredItems.isEmpty ? .orange : .red)
                        Text(expirationTracker.expiredItems.isEmpty ? "EXPIRING SOON" : "ACTION NEEDED")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Spacer()
                        Button(action: { showExpirationSettings = true }) {
                            Text("Manage")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                    .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(expirationTracker.expiredItems + expirationTracker.expiringSoonItems) { item in
                                ExpirationWarningCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // Cabinet grid
            if cabinetIngredients.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cabinet")
                        .font(.system(size: 44))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                    Text("Your cabinet is empty")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Text("Switch to Add Ingredients to stock\nyour cabinet")
                        .font(.system(size: 14))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .multilineTextAlignment(.center)
                    Button(action: { viewMode = .browse }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Ingredients")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_CHARCOAL)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("IN YOUR CABINET")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Spacer()
                        Button(action: { showExpirationSettings = true }) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 16))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        Button(action: { showClearConfirmation = true }) {
                            Image(systemName: "trash")
                                .font(.system(size: 16))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                    .padding(.horizontal, 20)

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        ForEach(cabinetIngredients, id: \.id) { ingredient in
                            CabinetImageCard(
                                ingredient: ingredient,
                                onRemove: { removeIngredient(ingredient) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer(minLength: 48)
        }
        .padding(.top, 8)
    }

    // MARK: - Browse Tab
    @ViewBuilder
    private var browseContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Search + Filter button
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .font(.system(size: 15, weight: .medium))
                    TextField("Search ingredients...", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .tint(COLOR_WARM_AMBER)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.07))
                .cornerRadius(13)

                Button(action: { showFilterSheet = true }) {
                    ZStack {
                        (selectedCategory != nil ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedCategory != nil ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(13)
                }
            }
            .padding(.horizontal, 20)

            // Browse grid
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("BROWSE INGREDIENTS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .kerning(1)
                    Spacer()
                    Text("\(filteredIngredients.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .padding(.horizontal, 20)

                if filteredIngredients.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        Text("No ingredients found")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Button(action: { searchText = ""; selectedCategory = nil }) {
                            Text("Clear Filters")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(filteredIngredients, id: \.id) { ingredient in
                            ModernCabinetCard(
                                ingredient: ingredient,
                                isInCabinet: selectedAlcoholTypes.contains(where: { $0.name == ingredient.name }),
                                onTap: { toggleIngredient(ingredient) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer(minLength: 48)
        }
        .padding(.top, 8)
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

// MARK: - Cabinet Image Card
struct CabinetImageCard: View {
    let ingredient: Ingredient
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Full-bleed image with gradient overlay
            ZStack(alignment: .bottomLeading) {
                Group {
                    if UIImage(named: ingredient.name) != nil {
                        Image(ingredient.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            COLOR_CHARCOAL_LIGHT
                            Image("GenericAlcohol")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.35)
                        }
                    }
                }
                .frame(height: 160)
                .clipped()

                LinearGradient(
                    colors: [.clear, .clear, Color.black.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(ingredient.type.rawValue.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                        .kerning(0.8)
                    Text(ingredient.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                }
                .padding(10)
            }
            .frame(height: 160)
            .cornerRadius(14)
            .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(COLOR_WARM_AMBER.opacity(0.5), lineWidth: 1.5)
            )

            // Remove badge
            Button(action: onRemove) {
                ZStack {
                    Circle().fill(COLOR_CHARCOAL).frame(width: 24, height: 24)
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            .padding(6)
        }
    }
}

// MARK: - Modern Cabinet Card
struct ModernCabinetCard: View {
    let ingredient: Ingredient
    let isInCabinet: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Thumbnail
                Group {
                    if UIImage(named: ingredient.name) != nil {
                        Image(ingredient.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color.white.opacity(0.05)
                            Image("GenericAlcohol")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.5)
                        }
                    }
                }
                .frame(width: 56, height: 56)
                .cornerRadius(8)
                .clipped()

                // Name + type
                VStack(alignment: .leading, spacing: 3) {
                    Text(ingredient.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                    Text(ingredient.type.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Add / added indicator
                Image(systemName: isInCabinet ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundColor(isInCabinet ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
            }
            .padding(10)
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isInCabinet ? COLOR_WARM_AMBER.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
// MARK: - Filter Sheet
struct TopShelfFilterSheet: View {
    @Binding var selectedCategory: IngredientType?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                List {
                    Section {
                        filterRow(title: "All Ingredients", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                            presentationMode.wrappedValue.dismiss()
                        }
                        filterRow(title: "Alcohol", isSelected: selectedCategory == .alcohol) {
                            selectedCategory = .alcohol
                            presentationMode.wrappedValue.dismiss()
                        }
                        filterRow(title: "Mixers", isSelected: selectedCategory == .mixer) {
                            selectedCategory = .mixer
                            presentationMode.wrappedValue.dismiss()
                        }
                        filterRow(title: "Garnish", isSelected: selectedCategory == .garnish) {
                            selectedCategory = .garnish
                            presentationMode.wrappedValue.dismiss()
                        }
                        filterRow(title: "Non-Alcoholic", isSelected: selectedCategory == .nonAlcohol) {
                            selectedCategory = .nonAlcohol
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        selectedCategory = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .opacity(selectedCategory != nil ? 1 : 0)
                    .disabled(selectedCategory == nil)
                }
            }
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    private func filterRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title).foregroundColor(COLOR_TEXT_PRIMARY)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(COLOR_WARM_AMBER)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .listRowBackground(COLOR_CHARCOAL_LIGHT)
    }
}

// MARK: - Expiration Warning Card
struct ExpirationWarningCard: View {
    let item: ExpirationInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle()
                    .fill(item.isExpired ? Color.red : Color.orange)
                    .frame(width: 8, height: 8)
                Text(item.ingredientName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(1)
            }
            Text(item.isExpired
                 ? "Expired \(abs(item.daysUntilExpiration))d ago"
                 : "Expires in \(item.daysUntilExpiration)d")
                .font(.system(size: 11))
                .foregroundColor(item.isExpired ? .red : .orange)
        }
        .padding(12)
        .frame(width: 160)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isExpired ? Color.red.opacity(0.4) : Color.orange.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Expiration Item Row
struct ExpirationItemRow: View {
    let item: ExpirationInfo
    let color: Color
    var isLast: Bool = false
    @StateObject private var expirationTracker = ExpirationTracker.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.ingredientName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Text(dateString(item.expirationDate))
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 12))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .italic()
                    }
                }
                Spacer()
                Text(item.isExpired ? "Expired" : "\(item.daysUntilExpiration)d")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                Button(action: { expirationTracker.removeExpirationInfo(for: item.id) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 38)
            }
        }
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Expiration Section
struct ExpirationSection: View {
    let title: String
    let items: [ExpirationInfo]
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .kerning(1)
                Spacer()
                Text("\(items.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            .padding(.horizontal, 20)
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ExpirationItemRow(item: item, color: color, isLast: index == items.count - 1)
                }
            }
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Add Expiration View
struct AddExpirationView: View {
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

    var canAdd: Bool {
        showCustomIngredient ? !customIngredient.isEmpty : !selectedIngredient.isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Ingredient
                        VStack(alignment: .leading, spacing: 10) {
                            Text("INGREDIENT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            if cabinetIngredients.isEmpty {
                                Text("Your cabinet is empty. Add ingredients first.")
                                    .font(.system(size: 14))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(14)
                            } else {
                                Menu {
                                    ForEach(cabinetIngredients, id: \.self) { ingredient in
                                        Button(ingredient) { selectedIngredient = ingredient }
                                    }
                                    Button("Custom Ingredient...") { showCustomIngredient = true }
                                } label: {
                                    HStack {
                                        Text(selectedIngredient.isEmpty ? "Select ingredient" : selectedIngredient)
                                            .font(.system(size: 15))
                                            .foregroundColor(selectedIngredient.isEmpty ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(14)
                                }
                            }
                        }

                        // Date
                        VStack(alignment: .leading, spacing: 10) {
                            Text("EXPIRATION DATE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(COLOR_WARM_AMBER)
                                .padding(16)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(14)
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES (OPTIONAL)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Add any notes...")
                                        .font(.system(size: 15))
                                        .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.6))
                                        .padding(14)
                                }
                                TextEditor(text: $notes)
                                    .font(.system(size: 15))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .tint(COLOR_WARM_AMBER)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                            }
                            .frame(minHeight: 100)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(14)
                        }

                        // Add button
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
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(canAdd ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canAdd ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                                .cornerRadius(14)
                        }
                        .disabled(!canAdd)

                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Track Expiration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .alert("Custom Ingredient", isPresented: $showCustomIngredient) {
                TextField("Ingredient name", text: $customIngredient)
                Button("Add") { selectedIngredient = customIngredient; showCustomIngredient = false }
                Button("Cancel", role: .cancel) { showCustomIngredient = false }
            }
        }
    }
}

// MARK: - Expiration Management View
struct ExpirationManagementView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var expirationTracker = ExpirationTracker.shared
    @State private var showAddExpiration = false

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Stats
                        HStack(spacing: 12) {
                            expirationStat(value: expirationTracker.totalTrackedIngredients, label: "Tracked", color: COLOR_WARM_AMBER)
                            expirationStat(value: expirationTracker.expiringSoonCount, label: "Expiring Soon", color: .orange)
                            expirationStat(value: expirationTracker.expiredCount, label: "Expired", color: .red)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        // Notifications toggle
                        Toggle(isOn: Binding(
                            get: { expirationTracker.notificationsEnabled },
                            set: { expirationTracker.toggleNotifications($0) }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Expiration Reminders")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Text("Get notified 3 days before ingredients expire")
                                    .font(.system(size: 12))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        }
                        .tint(COLOR_WARM_AMBER)
                        .padding(16)
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                        .padding(.horizontal, 20)

                        // Track button
                        Button(action: { showAddExpiration = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Track New Expiration Date")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)

                        // Lists
                        if !expirationTracker.expiredItems.isEmpty {
                            ExpirationSection(title: "Expired", items: expirationTracker.expiredItems, color: .red, icon: "xmark.circle.fill")
                        }
                        if !expirationTracker.expiringSoonItems.isEmpty {
                            ExpirationSection(title: "Expiring Soon", items: expirationTracker.expiringSoonItems, color: .orange, icon: "exclamationmark.triangle.fill")
                        }
                        if !expirationTracker.freshItems.isEmpty {
                            ExpirationSection(title: "Fresh", items: expirationTracker.freshItems, color: .green, icon: "checkmark.circle.fill")
                        }

                        // Clear expired
                        if !expirationTracker.expiredItems.isEmpty {
                            Button(action: { expirationTracker.clearExpiredItems() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                    Text("Clear Expired Items")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 48)
                    }
                }
            }
            .navigationTitle("Expiration Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .sheet(isPresented: $showAddExpiration) {
                AddExpirationView(isPresented: $showAddExpiration)
            }
        }
    }

    @ViewBuilder
    private func expirationStat(value: Int, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}
