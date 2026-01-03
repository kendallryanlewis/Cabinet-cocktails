//
//  MixologyView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct MixologyView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @Binding var isMenuOpen: Bool
    @Binding var viewPage: pages
    
    @State private var selectedCocktail: DrinkDetails? = nil
    @State private var searchText = ""
    @State private var filterCategory: String? = nil
    @State private var showAlmostThere = false
    @State private var isLoading = false
    
    // Performance: Cache expensive computations
    @State private var cachedAlmostThere: [DrinkDetails] = []
    @State private var lastCabinetUpdate: [String] = []
    
    var perfectMatches: [DrinkDetails] {
        DrinkManager.shared.myDrinkPossibilities ?? []
    }
    
    var almostThereMatches: [DrinkDetails] {
        let currentCabinet = LocalStorageManager.shared.retrieveTopShelfItems()
        
        // Performance: Return cached result if cabinet hasn't changed
        if !cachedAlmostThere.isEmpty && currentCabinet == lastCabinetUpdate {
            return cachedAlmostThere
        }
        
        guard let allDrinks = DrinkManager.shared.allDrinks else { return [] }
        let cabinetIngredients = Set(currentCabinet.map { $0.lowercased() })
        
        let results = allDrinks.filter { drink in
            let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            let missing = drinkIngredients.subtracting(cabinetIngredients)
            return missing.count >= 1 && missing.count <= 2 && !perfectMatches.contains(drink)
        }.prefix(12).map { $0 }
        
        // Cache the result
        DispatchQueue.main.async {
            cachedAlmostThere = results
            lastCabinetUpdate = currentCabinet
        }
        
        return results
    }
    
    var displayedCocktails: [DrinkDetails] {
        let source = showAlmostThere ? almostThereMatches : perfectMatches
        var filtered = source
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.strDrink.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if let category = filterCategory {
            filtered = filtered.filter { $0.strCategory?.lowercased() == category.lowercased() }
        }
        
        return filtered
    }
    
    var categories: [String] {
        let allCocktails = perfectMatches + almostThereMatches
        let cats = Set(allCocktails.compactMap { $0.strCategory })
        return Array(cats).sorted()
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
            
            if LocalStorageManager.shared.retrieveTopShelfItems().isEmpty {
                EmptyMixologyView(viewPage: $viewPage, colorScheme: colorScheme)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Hero Stats Section
                        MixologyHeroSection(
                            perfectCount: perfectMatches.count,
                            almostCount: almostThereMatches.count,
                            cabinetCount: LocalStorageManager.shared.retrieveTopShelfItems().count
                        )
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        // Toggle: Perfect vs Almost There
                        if !almostThereMatches.isEmpty {
                            HStack(spacing: 12) {
                                ToggleButton(
                                    title: "Perfect Matches",
                                    count: perfectMatches.count,
                                    isSelected: !showAlmostThere,
                                    action: { showAlmostThere = false }
                                )
                                
                                ToggleButton(
                                    title: "Almost There",
                                    count: almostThereMatches.count,
                                    isSelected: showAlmostThere,
                                    action: { showAlmostThere = true }
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Search Bar
                        if !perfectMatches.isEmpty || !almostThereMatches.isEmpty {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                TextField("Search cocktails", text: $searchText)
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .tint(COLOR_WARM_AMBER)
                                    .placeholder(when: searchText.isEmpty) {
                                        Text("Search cocktails")
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
                        }
                        
                        // Category Filter
                        if !categories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    CategoryFilterButton(
                                        title: "All",
                                        isSelected: filterCategory == nil,
                                        action: { filterCategory = nil }
                                    )
                                    
                                    ForEach(categories, id: \.self) { category in
                                        CategoryFilterButton(
                                            title: category,
                                            isSelected: filterCategory == category,
                                            action: { filterCategory = category }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Results Section
                        if displayedCocktails.isEmpty && (perfectMatches.isEmpty && almostThereMatches.isEmpty) {
                            NoMatchesYetView()
                                .padding(.vertical, 40)
                        } else if displayedCocktails.isEmpty {
                            // Filtered out all results
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                Text("No cocktails found")
                                    .font(.sectionHeader)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                
                                Text("Try adjusting your search or filters")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                Button(action: {
                                    searchText = ""
                                    filterCategory = nil
                                }) {
                                    Text("Clear Filters")
                                        .font(.buttonText)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            // Cocktail Grid
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                                ForEach(displayedCocktails, id: \.id) { cocktail in
                                    MixologyCocktailCard(
                                        cocktail: cocktail,
                                        showMissing: showAlmostThere,
                                        cabinetIngredients: Set(LocalStorageManager.shared.retrieveTopShelfItems().map { $0.lowercased() }),
                                        onTap: {
                                            selectedCocktail = cocktail
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear(perform: DrinkManager.shared.onlyYourIngredients)
        .sheet(item: $selectedCocktail) { cocktail in
            DetailsView(cocktail: cocktail.strDrink, hideCloseButton: false, dismiss: {
                selectedCocktail = nil
            })
        }
    }
}

// MARK: - Hero Section
struct MixologyHeroSection: View {
    let perfectCount: Int
    let almostCount: Int
    let cabinetCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Mixology")
                .font(.cocktailTitle)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            if perfectCount > 0 {
                HStack(spacing: 8) {
                    Text("\(perfectCount)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(COLOR_WARM_AMBER)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("cocktail\(perfectCount == 1 ? "" : "s")")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("you can make right now")
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }
            }
            
            if almostCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(COLOR_WARM_AMBER)
                        .font(.system(size: 16))
                    
                    Text("\(almostCount) more with 1-2 ingredients")
                        .font(.bodyText)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            
            HStack(spacing: 8) {
                Image(systemName: "cabinet")
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .font(.system(size: 14))
                
                Text("\(cabinetCount) ingredients in your cabinet")
                    .font(.caption)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
    }
}

// MARK: - Toggle Button
struct ToggleButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .black : COLOR_TEXT_PRIMARY)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .black : COLOR_TEXT_SECONDARY)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? COLOR_WARM_AMBER : COLOR_CHARCOAL_LIGHT)
            .cornerRadius(12)
        }
    }
}

// MARK: - Cocktail Card
struct MixologyCocktailCard: View {
    @Environment(\.colorScheme) var colorScheme
    let cocktail: DrinkDetails
    let showMissing: Bool
    let cabinetIngredients: Set<String>
    let onTap: () -> Void
    
    var missingIngredients: [String] {
        let drinkIngredients = Set(cocktail.getIngredients().map { $0.lowercased() })
        let missing = drinkIngredients.subtracting(cabinetIngredients)
        return Array(missing)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
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
                    
                    // Missing ingredients badge
                    if showMissing && !missingIngredients.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 10))
                            Text("\(missingIngredients.count)")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                        .padding(8)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(cocktail.strDrink)
                        .font(.cardTitle)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let category = cocktail.strCategory {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(showMissing ? COLOR_TEXT_SECONDARY : COLOR_WARM_AMBER)
                            .textCase(.uppercase)
                    }
                    
                    // Show missing ingredients for "Almost There"
                    if showMissing && !missingIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Need:")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                            
                            ForEach(missingIngredients.prefix(2), id: \.self) { ingredient in
                                Text("• \(ingredient.capitalized)")
                                    .font(.system(size: 10))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(COLOR_CHARCOAL_LIGHT)
            }
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - No Matches Yet
struct NoMatchesYetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundColor(COLOR_TEXT_SECONDARY)
            
            VStack(spacing: 8) {
                Text("No matches yet")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("Add a few more ingredients to unlock cocktail recipes")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Empty State
struct EmptyMixologyView: View {
    @Binding var viewPage: pages
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(COLOR_CHARCOAL_LIGHT)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "cabinet")
                    .font(.system(size: 40))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            VStack(spacing: 8) {
                Text("Your Cabinet is Empty")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("Add ingredients to discover what cocktails you can make")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                withAnimation {
                    viewPage = .cabinet
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Stock Your Cabinet")
                }
                .font(.buttonText)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(COLOR_WARM_AMBER)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
