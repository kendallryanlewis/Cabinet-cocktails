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
            LinearGradient(
                gradient: colorScheme == .dark ? 
                    Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) : 
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]), 
                startPoint: .topTrailing, 
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
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
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Text("\(DrinkManager.shared.signatureCocktails.count) saved cocktail\(DrinkManager.shared.signatureCocktails.count == 1 ? "" : "s")")
                                .font(.bodyText)
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                            
                            TextField("Search your signatures", text: $searchText)
                                .font(.bodyText)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .tint(COLOR_WARM_AMBER)
                                .placeholder(when: searchText.isEmpty) {
                                    Text("Search your signatures")
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
                                .padding(.horizontal)
                            }
                        }
                        
                        // Cocktails Grid
                        if filteredCocktails.isEmpty {
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
                            .padding(.horizontal)
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
                        .foregroundColor(COLOR_TEXT_PRIMARY)
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
                .background(COLOR_CHARCOAL_LIGHT)
            }
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .black : COLOR_TEXT_SECONDARY)
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
                    .fill(COLOR_CHARCOAL_LIGHT)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "heart.slash")
                    .font(.system(size: 40))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            // Text
            VStack(spacing: 8) {
                Text("No Signatures Yet")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("Save your favorite cocktails to quickly access them later")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
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
