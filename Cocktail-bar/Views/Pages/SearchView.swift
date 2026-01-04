//
//  SearchView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/9/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
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
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Mix")
                            .font(.cocktailTitle)
                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        
                        Text(searchMode == .ingredients 
                            ? "Build cocktails from selected ingredients"
                            : "Search all cocktails and ingredients")
                            .font(.bodyText)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    // Mode Toggle
                    HStack(spacing: 12) {
                        ModeToggleButton(
                            icon: "doc.text.magnifyingglass",
                            title: "Search All",
                            isSelected: searchMode == .cocktails,
                            action: { 
                                searchMode = .cocktails
                                selectedIngredients.removeAll()
                                filterCategory = nil
                            }
                        )
                        
                        ModeToggleButton(
                            icon: "slider.horizontal.3",
                            title: "Mix Custom",
                            isSelected: searchMode == .ingredients,
                            action: { 
                                searchMode = .ingredients
                                searchText = ""
                                filterCategory = nil
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Selected Ingredients (for Mix Custom mode)
                    if searchMode == .ingredients && !selectedIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Selected Ingredients")
                                    .font(.sectionHeader)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedIngredients.removeAll()
                                }) {
                                    Text("Clear")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedIngredients, id: \.id) { ingredient in
                                        IngredientChip(
                                            ingredient: ingredient,
                                            onRemove: {
                                                selectedIngredients.removeAll(where: { $0.name == ingredient.name })
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Results count
                            if !quickMixResults.isEmpty {
                                Text("\(quickMixResults.count) cocktail\(quickMixResults.count == 1 ? "" : "s") found")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_WARM_AMBER)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        
                        TextField(searchMode == .cocktails ? "Search cocktails or ingredients" : "Search ingredients to add", text: $searchText)
                            .font(.bodyText)
                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            .tint(COLOR_WARM_AMBER)
                            .placeholder(when: searchText.isEmpty) {
                                Text(searchMode == .cocktails ? "Search cocktails or ingredients" : "Search ingredients to add")
                                    .font(.bodyText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            }
                        }
                    }
                    .padding(12)
                    .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Advanced Filter Controls (only in cocktails mode)
                    if searchMode == .cocktails {
                        HStack(spacing: 12) {
                            // Filter Button
                            Button(action: {
                                tempFilter = filterManager.currentFilter
                                showFilters = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                    Text("Filter")
                                    if filterManager.currentFilter.activeCount > 0 {
                                        Text("(\(filterManager.currentFilter.activeCount))")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(filterManager.currentFilter.isActive ? COLOR_WARM_AMBER : AdaptiveColors.textSecondary(for: colorScheme))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(filterManager.currentFilter.isActive ? COLOR_WARM_AMBER.opacity(0.15) : AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                .cornerRadius(8)
                            }
                            
                            // Sort Button
                            Button(action: { showSort = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: currentSortOption.icon)
                                    Text("Sort")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                .cornerRadius(8)
                            }
                            
                            // History Button
                            Button(action: { showHistory = true }) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(8)
                            }
                            
                            // Saved Searches Button
                            Button(action: { showSavedSearches = true }) {
                                Image(systemName: "bookmark")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(8)
                            }
                            
                            // Save Current Search Button
                            if !debouncedSearchText.isEmpty || filterManager.currentFilter.isActive {
                                Button(action: { showSaveSearch = true }) {
                                    Image(systemName: "bookmark.fill")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(COLOR_WARM_AMBER.opacity(0.15))
                                        .cornerRadius(8)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Ingredient Selection Mode
                    if searchMode == .ingredients {
                        if !searchText.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Add Ingredients")
                                    .font(.sectionHeader)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    .padding(.horizontal, 20)
                                
                                if filteredIngredients.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.iconSmall)
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        
                                        Text("No ingredients found")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                                        ForEach(filteredIngredients, id: \.id) { ingredient in
                                            QuickMixIngredientCard(
                                                ingredient: ingredient,
                                                isSelected: selectedIngredients.contains(where: { $0.name == ingredient.name }),
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
                        } else if selectedIngredients.isEmpty {
                            // Empty state for ingredient mode
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(COLOR_CHARCOAL_LIGHT)
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.iconSmall)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Build Your Mix")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    
                                    Text("Search and select ingredients to discover cocktail combinations")
                                        .font(.bodyText)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                    
                    // Category Filter (for cocktail results)
                    if !displayedCocktails.isEmpty && !cocktailCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryFilterButton(
                                    title: "All",
                                    isSelected: filterCategory == nil,
                                    action: { filterCategory = nil }
                                )
                                
                                ForEach(cocktailCategories, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category,
                                        isSelected: filterCategory == category,
                                        action: { filterCategory = category }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Cocktail Results
                    if searchMode == .cocktails || (searchMode == .ingredients && !selectedIngredients.isEmpty && searchText.isEmpty) {
                        VStack(alignment: .leading, spacing: 12) {
                            if searchMode == .ingredients && !quickMixResults.isEmpty {
                                Text("Possible Cocktails")
                                    .font(.sectionHeader)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    .padding(.horizontal, 20)
                            } else if searchMode == .cocktails {
                                HStack {
                                    Text("All Cocktails")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    
                                    Spacer()
                                    
                                    Text("\(displayedCocktails.count)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            if displayedCocktails.isEmpty {
                                if searchMode == .ingredients {
                                    VStack(spacing: 12) {
                                        Image(systemName: "wineglass")
                                            .font(.iconMedium)
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        
                                        Text("No cocktails found")
                                            .font(.sectionHeader)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        
                                        Text("Try selecting different ingredients")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.iconMedium)
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        
                                        Text("No results")
                                            .font(.sectionHeader)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        
                                        Button(action: {
                                            searchText = ""
                                            filterCategory = nil
                                        }) {
                                            Text("Clear Search")
                                                .font(.buttonText)
                                                .foregroundColor(COLOR_WARM_AMBER)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                }
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                                    ForEach(displayedCocktails, id: \.id) { cocktail in
                                        QuickMixCocktailCard(
                                            cocktail: cocktail,
                                            onTap: {
                                                selectedCocktail = cocktail
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
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
        }
        .onChange(of: searchText) { newValue in
            // Performance: Debounce search to avoid excessive filtering
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                if !Task.isCancelled {
                    debouncedSearchText = newValue
                    
                    // Add to search history if in cocktails mode and has results
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

// MARK: - Mode Toggle Button
struct ModeToggleButton: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.bodyText)
                
                Text(title)
                    .font(.buttonText)
            }
            .foregroundColor(isSelected ? .black : COLOR_TEXT_PRIMARY)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? COLOR_WARM_AMBER : AdaptiveColors.secondaryCardBackground(for: colorScheme))
            .cornerRadius(12)
        }
    }
}

// MARK: - Ingredient Chip
struct IngredientChip: View {
    @Environment(\.colorScheme) var colorScheme
    let ingredient: Ingredient
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if UIImage(named: ingredient.name) != nil {
                Image(ingredient.name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(AdaptiveColors.cardBackground(for: colorScheme))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "drop.fill")
                        .font(.caption)
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            
            Text(ingredient.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.bodySmall)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AdaptiveColors.cardBackground(for: colorScheme))
        .cornerRadius(16)
    }
}

// MARK: - Quick Mix Ingredient Card
struct QuickMixIngredientCard: View {
    @Environment(\.colorScheme) var colorScheme
    let ingredient: Ingredient
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Thumbnail
                if UIImage(named: ingredient.name) != nil {
                    Image(ingredient.name)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(COLOR_CHARCOAL)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "drop.fill")
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name)
                        .font(.ingredientText)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .lineLimit(2)
                    
                    Text(ingredient.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(isSelected ? COLOR_WARM_AMBER : AdaptiveColors.textSecondary(for: colorScheme))
                    .font(.iconMini)
            }
            .padding(12)
            .background(AdaptiveColors.cardBackground(for: colorScheme))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Mix Cocktail Card
struct QuickMixCocktailCard: View {
    @Environment(\.colorScheme) var colorScheme
    let cocktail: DrinkDetails
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Image
                if let imageURL = cocktail.strDrinkThumb, let url = URL(string: imageURL) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.2)
                            SwiftUI.ProgressView()
                                .tint(COLOR_WARM_AMBER)
                        }
                        .frame(height: 140)
                    }
                } else {
                    Image("GenericAlcohol")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipped()
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(cocktail.strDrink)
                        .font(.cardTitle)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let category = cocktail.strCategory {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(AdaptiveColors.cardBackground(for: colorScheme))
            }
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
