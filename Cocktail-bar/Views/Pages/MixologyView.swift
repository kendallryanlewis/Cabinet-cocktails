//
//  MixologyView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

enum MixologySheet: Identifiable {
    case cocktailDetail(DrinkDetails)
    case cabinet
    case filter

    var id: String {
        switch self {
        case .cocktailDetail(let d): return "detail-\(d.strDrink)"
        case .cabinet: return "cabinet"
        case .filter: return "filter"
        }
    }
}

struct MixologyView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @Binding var isMenuOpen: Bool
    @Binding var viewPage: pages
    
    @State private var activeSheet: MixologySheet? = nil
    @State private var searchText = ""
    @State private var filterCategory: String? = nil
    @State private var showAlmostThere = false
    @State private var isLoading = false
    @State private var cabinetItems: [String] = []
    
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
    
    var ingredientSearchResults: [Ingredient] {
        guard !searchText.isEmpty, let all = DrinkManager.shared.allIngredients else { return [] }
        return all
            .filter { $0.name.lowercased().contains(searchText.lowercased()) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()
            
            if LocalStorageManager.shared.retrieveTopShelfItems().isEmpty {
                EmptyMixologyView(viewPage: $viewPage, colorScheme: colorScheme)
            } else {
                VStack(spacing: 0) {
                    // ── Fixed Header ──
                    VStack(alignment: .leading, spacing: 0) {
                        // Hero Stats Section
                        MixologyHeroSection(
                            perfectCount: perfectMatches.count,
                            almostCount: almostThereMatches.count,
                            cabinetCount: LocalStorageManager.shared.retrieveTopShelfItems().count,
                            onAddIngredients: { activeSheet = .cabinet }
                        )
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        
                        // Mode toggle — segmented control (only when both modes have content)
                        if !almostThereMatches.isEmpty {
                            HStack(spacing: 0) {
                                SearchModeButton(
                                    title: "Perfect Matches",
                                    icon: "checkmark.circle",
                                    isSelected: !showAlmostThere,
                                    action: { showAlmostThere = false }
                                )
                                SearchModeButton(
                                    title: "Almost There",
                                    icon: "sparkles",
                                    isSelected: showAlmostThere,
                                    action: { showAlmostThere = true }
                                )
                            }
                            .padding(3)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }

                        // Search + Filter row
                        HStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                    .font(.system(size: 15, weight: .medium))
                                TextField("Search cocktails & ingredients...", text: $searchText)
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

                            // Filter button — opens category sheet
                            Button(action: { activeSheet = .filter }) {
                                ZStack {
                                    (filterCategory != nil ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(filterCategory != nil ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(13)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(COLOR_BACKGROUND)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)
                    
                    // ── Scrollable content ──
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {

                            // ── Ingredient search results ──
                            if !searchText.isEmpty && !ingredientSearchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("INGREDIENTS")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                        .kerning(1)
                                        .padding(.horizontal, 20)

                                    LazyVGrid(
                                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
                                        spacing: 12
                                    ) {
                                        ForEach(ingredientSearchResults, id: \.id) { ingredient in
                                            ModernCabinetCard(
                                                ingredient: ingredient,
                                                isInCabinet: cabinetItems.contains(ingredient.name),
                                                onTap: { toggleCabinetIngredient(ingredient) }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            // ── Cocktail results ──
                            VStack(alignment: .leading, spacing: 14) {
                                if !searchText.isEmpty {
                                    Text("COCKTAILS")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                        .kerning(1)
                                        .padding(.horizontal, 20)
                                }

                                if displayedCocktails.isEmpty && (perfectMatches.isEmpty && almostThereMatches.isEmpty) {
                                    NoMatchesYetView()
                                        .padding(.vertical, 40)
                                } else if displayedCocktails.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.iconMedium)
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
                                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                                        ForEach(displayedCocktails, id: \.id) { cocktail in
                                            MixologyCocktailCard(
                                                cocktail: cocktail,
                                                showMissing: showAlmostThere,
                                                cabinetIngredients: Set(LocalStorageManager.shared.retrieveTopShelfItems().map { $0.lowercased() }),
                                                onTap: { activeSheet = .cocktailDetail(cocktail) }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            Spacer(minLength: 48)
                        }
                        .padding(.top, 24)
                    }
                }
            }
        }
        .onAppear {
            DrinkManager.shared.onlyYourIngredients()
            if DrinkManager.shared.allIngredients == nil {
                DrinkManager.shared.getAllUniqueIngredients()
            }
            cabinetItems = LocalStorageManager.shared.retrieveTopShelfItems()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .cocktailDetail(let cocktail):
                DetailsView(cocktail: cocktail.strDrink, hideCloseButton: false, dismiss: {
                    activeSheet = nil
                })
            case .cabinet:
                TopShelfView(isMenuOpen: .constant(false))
                    .onDisappear {
                        DrinkManager.shared.onlyYourIngredients()
                        cabinetItems = LocalStorageManager.shared.retrieveTopShelfItems()
                    }
            case .filter:
                MixologyFilterSheet(categories: categories, selectedCategory: $filterCategory)
            }
        }
    }

    private func toggleCabinetIngredient(_ ingredient: Ingredient) {
        if let idx = cabinetItems.firstIndex(of: ingredient.name) {
            cabinetItems.remove(at: idx)
            if let storageIdx = LocalStorageManager.shared.retrieveTopShelfItems().firstIndex(of: ingredient.name) {
                LocalStorageManager.shared.removeTopShelfItem(at: storageIdx)
            }
        } else {
            cabinetItems.append(ingredient.name)
            LocalStorageManager.shared.addTopShelfItem(newItem: ingredient.name)
        }
        DrinkManager.shared.onlyYourIngredients()
    }
}

// MARK: - Hero Section
struct MixologyHeroSection: View {
    let perfectCount: Int
    let almostCount: Int
    let cabinetCount: Int
    let onAddIngredients: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Title row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR MIXOLOGY")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .kerning(1)
                    Text("Your Cabinet")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                }
                Spacer()
                Button(action: onAddIngredients) {
                    HStack(spacing: 5) {
                        Image(systemName: "cabinet")
                            .font(.system(size: 12, weight: .semibold))
                        Text("My Cabinet")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(COLOR_CHARCOAL)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(20)
                }
            }

            // Stat card
            HStack(alignment: .center, spacing: 0) {
                // Left — cocktails ready
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(perfectCount)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(perfectCount > 0 ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                    Text("cocktail\(perfectCount == 1 ? "" : "s") ready")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 1, height: 56)
                    .padding(.horizontal, 16)

                // Right — almost there
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(COLOR_WARM_AMBER)
                        Text("\(almostCount)")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                    }
                    Text("1–2 away")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(COLOR_CHARCOAL_LIGHT)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(COLOR_WARM_AMBER.opacity(0.15), lineWidth: 1)
                    )
            )

            // Cabinet count — tappable to open cabinet
            Button(action: onAddIngredients) {
                HStack(spacing: 6) {
                    Image(systemName: "cabinet")
                        .font(.system(size: 12))
                    Text("\(cabinetCount) ingredient\(cabinetCount == 1 ? "" : "s") stocked")
                        .font(.system(size: 12))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
    }
}

// ToggleButton removed — replaced by SearchModeButton segmented control

// MARK: - Cocktail Card
struct MixologyCocktailCard: View {
    let cocktail: DrinkDetails
    let showMissing: Bool
    let cabinetIngredients: Set<String>
    let onTap: () -> Void

    var missingCount: Int {
        let drinkIngredients = Set(cocktail.getIngredients().map { $0.lowercased() })
        return drinkIngredients.subtracting(cabinetIngredients).count
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Full-bleed image
                Group {
                    if let imageURL = cocktail.strDrinkThumb, let url = URL(string: imageURL) {
                        CachedAsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ZStack {
                                COLOR_CHARCOAL_LIGHT
                                SwiftUI.ProgressView().tint(COLOR_WARM_AMBER)
                            }
                        }
                    } else {
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 200)
                .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Text at bottom
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
                }
                .padding(12)

                // "Almost There" badge — top right
                if showMissing && missingCount > 0 {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 9))
                                Text("+\(missingCount)")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(COLOR_CHARCOAL)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(10)
                            .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(14)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - No Matches Yet
struct NoMatchesYetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle")
                .font(.iconMedium)
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

// MARK: - Filter Sheet
struct MixologyFilterSheet: View {
    let categories: [String]
    @Binding var selectedCategory: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                List {
                    Section {
                        Button(action: {
                            selectedCategory = nil
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text("All Cocktails")
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Spacer()
                                if selectedCategory == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(COLOR_WARM_AMBER)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                        }
                        .listRowBackground(COLOR_CHARCOAL_LIGHT)

                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Text(category)
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                    Spacer()
                                    if selectedCategory == category {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                            }
                            .listRowBackground(COLOR_CHARCOAL_LIGHT)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filter by Category")
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
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Empty State
struct EmptyMixologyView: View {
    @Binding var viewPage: pages
    let colorScheme: ColorScheme
    @State private var showCabinet = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AdaptiveColors.cardBackground(for: colorScheme))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "cabinet")
                    .font(.displayMedium)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
            
            VStack(spacing: 8) {
                Text("Your Cabinet is Empty")
                    .font(.sectionHeader)
                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                
                Text("Add ingredients to discover what cocktails you can make")
                    .font(.bodyText)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showCabinet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Stock Your Cabinet")
                }
                .font(.buttonText)
                .foregroundColor(COLOR_CHARCOAL)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(COLOR_WARM_AMBER)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showCabinet) {
            TopShelfView(isMenuOpen: .constant(false))
        }
    }
}
