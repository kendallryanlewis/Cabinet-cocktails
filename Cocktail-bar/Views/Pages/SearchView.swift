//
//  SearchView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/9/24.
//

import SwiftUI

struct SearchView: View {
    @Binding var isMenuOpen: Bool
    
    @StateObject private var filterManager = SearchFilterManager.shared
    
    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @State private var selectedIngredients: [Ingredient] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedCocktail: DrinkDetails? = nil
    @State private var searchMode: SearchMode = .cocktails
    @State private var filterCategory: String? = nil
    
    // Advanced filter states
    @State private var showFilters = false
    @State private var showSort = false
    @State private var showHistory = false
    @State private var showSavedSearches = false
    @State private var showSaveSearch = false
    @State private var currentSortOption: SortOption = .nameAscending
    @State private var tempFilter = SearchFilter()
    
    enum SearchMode {
        case cocktails
        case ingredients
    }
    
    // Filtered ingredients
    var filteredIngredients: [Ingredient] {
        var ingredients = DrinkManager.shared.allIngredients ?? []
        
        if !searchText.isEmpty {
            ingredients = ingredients.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        return ingredients
    }
    
    // Filtered cocktails by search
    var filteredCocktails: [DrinkDetails] {
        guard let allDrinks = DrinkManager.shared.allDrinks else { return [] }
        
        if searchText.isEmpty {
            return allDrinks
        }
        
        let lowercased = searchText.lowercased()
        return allDrinks.filter { drink in
            drink.strDrink.lowercased().contains(lowercased) ||
            (drink.strCategory?.lowercased().contains(lowercased) ?? false) ||
            drink.strAlcoholic.lowercased().contains(lowercased) ||
            drink.getIngredients().contains(where: { $0.lowercased().contains(lowercased) })
        }
    }
    
    // Quick mix results
    var quickMixResults: [DrinkDetails] {
        guard !selectedIngredients.isEmpty else { return [] }
        return DrinkManager.shared.getQuickDrinkPossibilities(ingredients: selectedIngredients) ?? []
    }
    
    // Categories for filtering
    var cocktailCategories: [String] {
        let allCocktails = searchMode == .ingredients ? quickMixResults : filteredCocktails
        let cats = Set(allCocktails.compactMap { $0.strCategory })
        return Array(cats).sorted()
    }
    
    // Display cocktails with filter applied
    var displayedCocktails: [DrinkDetails] {
        var source = searchMode == .ingredients ? quickMixResults : filteredCocktails
        
        // Apply category filter
        if let category = filterCategory {
            source = source.filter { $0.strCategory?.lowercased() == category.lowercased() }
        }
        
        // Apply advanced filters
        source = filterManager.filterCocktails(source)
        
        // Apply sorting
        source = filterManager.sortCocktails(source, by: currentSortOption)
        
        return source
    }
    
    // Extract available filter options from current results
    var availableCategories: [String] {
        let allCocktails = searchMode == .ingredients ? quickMixResults : filteredCocktails
        return Array(Set(allCocktails.compactMap { $0.strCategory })).sorted()
    }
    
    var availableGlasses: [String] {
        let allCocktails = searchMode == .ingredients ? quickMixResults : filteredCocktails
        return Array(Set(allCocktails.compactMap { $0.strGlass })).sorted()
    }
    
    var availableAlcoholicTypes: [String] {
        let allCocktails = searchMode == .ingredients ? quickMixResults : filteredCocktails
        return Array(Set(allCocktails.compactMap { $0.strAlcoholic })).sorted()
    }
    
    var availableIngredients: [String] {
        let allCocktails = searchMode == .ingredients ? quickMixResults : filteredCocktails
        var ingredients = Set<String>()
        for cocktail in allCocktails {
            ingredients.formUnion(cocktail.getIngredients())
        }
        return Array(ingredients).sorted()
    }


    private var headerSubtitle: String {
        if searchMode == .cocktails {
            let count = displayedCocktails.count
            return count == 1 ? "1 cocktail" : "\(count) cocktails"
        } else if selectedIngredients.isEmpty {
            return "Select ingredients to start"
        } else {
            let count = quickMixResults.count
            return count == 1 ? "1 possible cocktail" : "\(count) possible cocktails"
        }
    }

    private var searchPlaceholder: String {
        searchMode == .cocktails ? "Cocktails, ingredients, categories..." : "Search ingredients to add..."
    }

    var body: some View {
        ZStack(alignment: .top) {
            COLOR_BACKGROUND.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(searchMode == .cocktails ? "Discover" : "Quick Mix")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text(headerSubtitle)
                            .font(.system(size: 13))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        if !debouncedSearchText.isEmpty || filterManager.currentFilter.isActive {
                            Button(action: { showSaveSearch = true }) {
                                Image(systemName: "bookmark.fill")
                                    .font(.system(size: 17))
                                    .foregroundColor(COLOR_WARM_AMBER)
                            }
                        }
                        Button(action: { showHistory = true }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 17))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        Button(action: { showSavedSearches = true }) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 17))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 20)

                // Search Bar + Filter / Sort buttons
                HStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .font(.system(size: 15, weight: .medium))
                        TextField(searchPlaceholder, text: $searchText)
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

                    if searchMode == .cocktails {
                        // Filter button
                        Button(action: { tempFilter = filterManager.currentFilter; showFilters = true }) {
                            ZStack {
                                (filterManager.currentFilter.isActive ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(filterManager.currentFilter.isActive ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(13)
                        }

                        // Sort button
                        Button(action: { showSort = true }) {
                            ZStack {
                                Color.white.opacity(0.07)
                                Image(systemName: currentSortOption.icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(13)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Mode Toggle
                HStack(spacing: 0) {
                    SearchModeButton(
                        title: "All Cocktails",
                        icon: "doc.text.magnifyingglass",
                        isSelected: searchMode == .cocktails,
                        action: {
                            searchMode = .cocktails
                            selectedIngredients.removeAll()
                            filterCategory = nil
                        }
                    )
                    SearchModeButton(
                        title: "Quick Mix",
                        icon: "slider.horizontal.3",
                        isSelected: searchMode == .ingredients,
                        action: {
                            searchMode = .ingredients
                            searchText = ""
                            filterCategory = nil
                        }
                    )
                }
                .padding(3)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)

                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 24) {

                        // Selected ingredients (Quick Mix mode)
                        if searchMode == .ingredients && !selectedIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("SELECTED")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                        .kerning(1)
                                    if !quickMixResults.isEmpty {
                                        Text("\(quickMixResults.count) match\(quickMixResults.count == 1 ? "" : "es")")
                                            .font(.system(size: 11))
                                            .foregroundColor(COLOR_WARM_AMBER)
                                    }
                                    Spacer()
                                    Button("Clear") { selectedIngredients.removeAll() }
                                        .font(.system(size: 13))
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                }
                                .padding(.horizontal, 20)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(selectedIngredients, id: \.id) { ingredient in
                                            IngredientChip(ingredient: ingredient) {
                                                selectedIngredients.removeAll { $0.name == ingredient.name }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        // Ingredient search results
                        if searchMode == .ingredients && !searchText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("INGREDIENTS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .kerning(1)
                                    .padding(.horizontal, 20)
                                if filteredIngredients.isEmpty {
                                    SearchEmptyView(message: "No ingredients found for \"\(searchText)\"")
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                                        ForEach(filteredIngredients, id: \.id) { ingredient in
                                            QuickMixIngredientCard(
                                                ingredient: ingredient,
                                                isSelected: selectedIngredients.contains { $0.name == ingredient.name },
                                                onTap: {
                                                    if let index = selectedIngredients.firstIndex(where: { $0.name == ingredient.name }) {
                                                        selectedIngredients.remove(at: index)
                                                    } else {
                                                        selectedIngredients.append(ingredient)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        // Quick Mix empty prompt
                        if searchMode == .ingredients && selectedIngredients.isEmpty && searchText.isEmpty {
                            QuickMixEmptyPrompt()
                        }

                        // Cocktail results
                        if searchMode == .cocktails || (searchMode == .ingredients && !selectedIngredients.isEmpty && searchText.isEmpty) {
                            if searchMode == .ingredients && !quickMixResults.isEmpty {
                                Text("POSSIBLE COCKTAILS")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .kerning(1)
                                    .padding(.horizontal, 20)
                            }
                            if displayedCocktails.isEmpty {
                                SearchEmptyView(
                                    message: searchMode == .ingredients
                                        ? "No cocktails match your ingredients."
                                        : searchText.isEmpty ? "No cocktails found." : "No results for \"\(searchText)\""
                                )
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
                                    ForEach(displayedCocktails, id: \.id) { cocktail in
                                        QuickMixCocktailCard(cocktail: cocktail) {
                                            selectedCocktail = cocktail
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 24)
                }
            }
        }
        .onAppear {
            if DrinkManager.shared.allIngredients == nil {
                DrinkManager.shared.getAllUniqueIngredients()
            }
        }
        .onChange(of: searchText) { newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if !Task.isCancelled {
                    debouncedSearchText = newValue
                    if searchMode == .cocktails && !newValue.isEmpty && !displayedCocktails.isEmpty {
                        filterManager.addToHistory(query: newValue, resultCount: displayedCocktails.count)
                    }
                }
            }
        }
        .sheet(item: $selectedCocktail) { cocktail in
            DetailsView(cocktail: cocktail.strDrink, hideCloseButton: false, dismiss: {
                selectedCocktail = nil
            })
        }
        .sheet(isPresented: $showFilters) {
            FilterOptionsView(
                filterManager: filterManager,
                filter: $tempFilter,
                availableCategories: availableCategories,
                availableGlasses: availableGlasses,
                availableAlcoholicTypes: availableAlcoholicTypes,
                availableIngredients: availableIngredients
            )
        }
        .sheet(isPresented: $showSort) {
            SortOptionsView(selectedSort: $currentSortOption)
        }
        .sheet(isPresented: $showHistory) {
            SearchHistoryView(
                filterManager: filterManager,
                onSelectHistory: { query in
                    searchText = query
                    showHistory = false
                }
            )
        }
        .sheet(isPresented: $showSavedSearches) {
            SavedSearchesView(
                filterManager: filterManager,
                onSelectSearch: { savedSearch in
                    searchText = savedSearch.query
                    filterManager.applyFilter(savedSearch.filter)
                    filterManager.markSavedSearchAsUsed(savedSearch.id)
                    showSavedSearches = false
                }
            )
        }
        .sheet(isPresented: $showSaveSearch) {
            SaveSearchSheet(
                filterManager: filterManager,
                query: debouncedSearchText,
                filter: filterManager.currentFilter
            )
        }
    }
}

// MARK: - Search Mode Button
struct SearchModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : COLOR_TEXT_SECONDARY)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? COLOR_WARM_AMBER : Color.clear)
            .cornerRadius(10)
        }
    }
}

// MARK: - Search Filter Chip
struct SearchFilterChip: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? COLOR_WARM_AMBER.opacity(0.12) : Color.white.opacity(0.07))
            .cornerRadius(10)
        }
    }
}

// MARK: - Category Chip
struct SearchCategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .black : COLOR_TEXT_SECONDARY)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                .cornerRadius(20)
        }
    }
}

// MARK: - Search Empty View
struct SearchEmptyView: View {
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.4))
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}

// MARK: - Quick Mix Empty Prompt
struct QuickMixEmptyPrompt: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 80, height: 80)
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 30))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            VStack(spacing: 6) {
                Text("Build Your Mix")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                Text("Search and select ingredients to discover cocktail combinations")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Ingredient Chip
struct IngredientChip: View {
    let ingredient: Ingredient
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 7) {
            if UIImage(named: ingredient.name) != nil {
                Image(ingredient.name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22, height: 22)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 22, height: 22)
                    Image(systemName: "drop.fill")
                        .font(.system(size: 9))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            Text(ingredient.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(COLOR_TEXT_PRIMARY)
                .lineLimit(1)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
    }
}

// MARK: - Quick Mix Ingredient Card
struct QuickMixIngredientCard: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                if UIImage(named: ingredient.name) != nil {
                    Image(ingredient.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 46, height: 46)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 46, height: 46)
                        Image(systemName: "drop.fill")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(ingredient.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                    Text(ingredient.type.rawValue.capitalized)
                        .font(.system(size: 11))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                Spacer(minLength: 0)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(isSelected ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                    .font(.system(size: 18))
            }
            .padding(12)
            .background(isSelected ? COLOR_WARM_AMBER.opacity(0.08) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? COLOR_WARM_AMBER.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Mix Cocktail Card
struct QuickMixCocktailCard: View {
    let cocktail: DrinkDetails
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let imageURL = cocktail.strDrinkThumb, let url = URL(string: imageURL) {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.white.opacity(0.05)
                                .overlay(SwiftUI.ProgressView().tint(COLOR_WARM_AMBER))
                        }
                    } else {
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 200)
                .clipped()
                LinearGradient(
                    colors: [.clear, .clear, Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack(alignment: .leading, spacing: 4) {
                    if let category = cocktail.strCategory {
                        Text(category.uppercased())
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(COLOR_WARM_AMBER)
                            .kerning(0.8)
                    }
                    Text(cocktail.strDrink)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
            }
            .frame(height: 200)
            .cornerRadius(14)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
