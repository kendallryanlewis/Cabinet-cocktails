//
//  SignaturesView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct SignaturesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @Binding var viewPage: pages
    @State private var selectedCocktail: Ingredient? = nil
    @State private var searchText = ""
    @State private var filterCategory: String? = nil
       
    var filteredCocktails: [Ingredient] {
        var cocktails = DrinkManager.shared.signatureCocktails
        
        // Apply search filter
        if !searchText.isEmpty {
            cocktails = cocktails.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        if let category = filterCategory {
            cocktails = cocktails.filter { $0.category?.lowercased() == category.lowercased() }
        }
        
        return cocktails
    }
    
    var cocktailCategories: [String] {
        let categories = Set(DrinkManager.shared.signatureCocktails.compactMap { $0.category })
        return Array(categories).sorted()
    }
    
    var body: some View {
        ZStack(){
            AppBackground()
            
            if DrinkManager.shared.signatureCocktails.isEmpty {
                // Empty state
                EmptySignaturesView(viewPage: $viewPage, colorScheme: colorScheme)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Signatures")
                                .font(.cocktailTitle)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            
                            Text("\(DrinkManager.shared.signatureCocktails.count) saved cocktail\(DrinkManager.shared.signatureCocktails.count == 1 ? "" : "s")")
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            
                            TextField("Search your signatures", text: $searchText)
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                .tint(COLOR_WARM_AMBER)
                                .placeholder(when: searchText.isEmpty) {
                                    Text("Search your signatures")
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
                        // Category Filter
                        if !cocktailCategories.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // All button
                                    CategoryFilterButton(
                                        title: "All",
                                        isSelected: filterCategory == nil,
                                        action: { filterCategory = nil }
                                    )
                                    
                                    // Category buttons
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
                        
                        // Cocktails Grid
                        if filteredCocktails.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.iconMedium)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                
                                Text("No cocktails found")
                                    .font(.sectionHeader)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                
                                Text("Try adjusting your search or filters")
                                    .font(.bodyText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                
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
                                ForEach(filteredCocktails, id: \.id) { cocktail in
                                    SignatureCocktailCard(
                                        cocktail: cocktail,
                                        onTap: {
                                            selectedCocktail = cocktail
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Bottom spacing
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .sheet(item: $selectedCocktail) { cocktail in
            DetailsView(cocktail: cocktail.name, hideCloseButton: false, dismiss: {
                selectedCocktail = nil
            })
        }
    }
}

// MARK: - Signature Cocktail Card
struct SignatureCocktailCard: View {
    @Environment(\.colorScheme) var colorScheme
    let cocktail: Ingredient
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Image
                if let imageURL = cocktail.image, let url = URL(string: imageURL) {
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
                    Text(cocktail.name)
                        .font(.cardTitle)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let category = cocktail.category {
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

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? COLOR_CHARCOAL : AdaptiveColors.textSecondary(for: colorScheme))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? COLOR_WARM_AMBER : COLOR_CHARCOAL_LIGHT)
                .cornerRadius(20)
        }
    }
}

// MARK: - Empty State
struct EmptySignaturesView: View {
    @Binding var viewPage: pages
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(AdaptiveColors.cardBackground(for: colorScheme))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.slash")
                    .font(.displayMedium)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
            
            // Text
            VStack(spacing: 8) {
                Text("No Signatures Yet")
                    .font(.sectionHeader)
                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                
                Text("Save your favorite cocktails to quickly access them later")
                    .font(.bodyText)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Action Button
            Button(action: {
                withAnimation {
                    viewPage = .mixology
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2")
                    Text("Explore Cocktails")
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
    }
}
