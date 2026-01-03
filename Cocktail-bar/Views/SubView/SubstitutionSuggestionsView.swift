//
//  SubstitutionSuggestionsView.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import SwiftUI

// MARK: - Substitution Suggestions View
struct SubstitutionSuggestionsView: View {
    let drink: DrinkDetails
    @StateObject private var substitutionManager = SubstitutionManager.shared
    
    @State private var suggestions: [SubstitutionSuggestion] = []
    @State private var selectedSuggestion: SubstitutionSuggestion?
    @State private var showSubstitutionDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !suggestions.isEmpty {
                headerSection
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(suggestions) { suggestion in
                            SubstitutionCard(suggestion: suggestion)
                                .onTapGesture {
                                    selectedSuggestion = suggestion
                                    showSubstitutionDetail = true
                                }
                        }
                    }
                    .padding()
                }
            } else {
                emptyStateView
            }
        }
        .onAppear {
            loadSuggestions()
        }
        .sheet(isPresented: $showSubstitutionDetail) {
            if let suggestion = selectedSuggestion {
                SubstitutionDetailView(suggestion: suggestion)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(COLOR_WARM_AMBER)
                Text("Ingredient Substitutions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text("Missing ingredients? Here are some alternatives from your bar.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("You have all ingredients!")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("No substitutions needed for this cocktail.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadSuggestions() {
        let missingIngredients = getMissingIngredients()
        let userInventory = LocalStorageManager.shared.retrieveTopShelfItems()
        suggestions = substitutionManager.findSuggestions(
            for: missingIngredients,
            userInventory: userInventory
        )
    }
    
    private func getMissingIngredients() -> [String] {
        var missing: [String] = []
        let userInventory = LocalStorageManager.shared.retrieveTopShelfItems()
        let userInventoryLower = userInventory.map { $0.lowercased() }
        
        // Get all ingredients from the drink
        let drinkIngredients = drink.getIngredients()
        
        for ingredient in drinkIngredients {
            let ingredientLower = ingredient.lowercased()
            if !userInventoryLower.contains(where: { $0.contains(ingredientLower) || ingredientLower.contains($0) }) {
                missing.append(ingredient)
            }
        }
        
        return missing
    }
}

// MARK: - Substitution Card
struct SubstitutionCard: View {
    let suggestion: SubstitutionSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with missing ingredient
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Missing:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(suggestion.missingIngredient)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                difficultyBadge
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Recommended alternative
            if let recommended = suggestion.recommendedAlternative {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(COLOR_WARM_AMBER)
                            .font(.caption)
                        Text("Recommended Substitute")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                    
                    HStack {
                        Text(recommended.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(recommended.displayRatio())
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(COLOR_WARM_AMBER.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                    
                    if let notes = recommended.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
            }
            
            // Available alternatives count
            if suggestion.availableAlternatives.count > 1 {
                Text("\(suggestion.availableAlternatives.count) alternatives in your bar")
                    .font(.caption)
                    .foregroundColor(COLOR_WARM_AMBER)
            } else if suggestion.availableAlternatives.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("\(suggestion.substitution.alternatives.count) substitutes available")
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
    
    private var difficultyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: difficultyIcon)
                .font(.caption)
            Text(suggestion.substitution.difficulty.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(difficultyColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(difficultyColor.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var difficultyIcon: String {
        switch suggestion.substitution.difficulty {
        case .easy: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.circle.fill"
        case .challenging: return "exclamationmark.triangle.fill"
        }
    }
    
    private var difficultyColor: Color {
        switch suggestion.substitution.difficulty {
        case .easy: return .green
        case .moderate: return .yellow
        case .challenging: return .orange
        }
    }
}

// MARK: - Substitution Detail View
struct SubstitutionDetailView: View {
    let suggestion: SubstitutionSuggestion
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Missing ingredient info
                    missingIngredientSection
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // All alternatives
                    alternativesSection
                    
                    // Category and flavor notes
                    if suggestion.substitution.preservesOriginalFlavor {
                        preservesFlavorNote
                    }
                }
                .padding()
            }
            .background(COLOR_CHARCOAL.ignoresSafeArea())
            .navigationTitle("Substitution Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
    
    private var missingIngredientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                Text("Missing Ingredient")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(suggestion.missingIngredient)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(COLOR_WARM_AMBER)
            
            HStack {
                Text("Category:")
                    .foregroundColor(.gray)
                Text(suggestion.substitution.category.rawValue)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
    
    private var alternativesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Substitutes")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(suggestion.substitution.alternatives) { alternative in
                AlternativeRow(
                    alternative: alternative,
                    isAvailable: suggestion.availableAlternatives.contains(where: { $0.id == alternative.id }),
                    isRecommended: suggestion.recommendedAlternative?.id == alternative.id
                )
            }
        }
    }
    
    private var preservesFlavorNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Flavor Preserved")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("These substitutes maintain the original flavor profile")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Alternative Row
struct AlternativeRow: View {
    let alternative: SubstitutionAlternative
    let isAvailable: Bool
    let isRecommended: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status icon
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                // Name and ratio
                HStack {
                    Text(alternative.name)
                        .font(.body)
                        .fontWeight(isRecommended ? .bold : .medium)
                        .foregroundColor(.white)
                    
                    if isRecommended {
                        Image(systemName: "star.fill")
                            .foregroundColor(COLOR_WARM_AMBER)
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                
                // Ratio
                Text(alternative.displayRatio())
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(COLOR_WARM_AMBER.opacity(0.2))
                    .cornerRadius(6)
                    .foregroundColor(COLOR_WARM_AMBER)
                
                // Notes
                if let notes = alternative.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                
                // Flavor profile
                if let flavor = alternative.flavorProfile {
                    HStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                        Text(flavor)
                            .font(.caption)
                    }
                    .foregroundColor(COLOR_WARM_AMBER.opacity(0.8))
                }
            }
        }
        .padding()
        .background(isAvailable ? COLOR_CHARCOAL_LIGHT : COLOR_CHARCOAL)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRecommended ? COLOR_WARM_AMBER : Color.clear, lineWidth: 2)
        )
    }
    
    private var statusIcon: String {
        if isAvailable {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private var statusColor: Color {
        if isRecommended {
            return COLOR_WARM_AMBER
        } else if isAvailable {
            return .green
        } else {
            return .gray
        }
    }
}

// MARK: - Compact Substitution Badge (for DetailsView)
struct SubstitutionBadge: View {
    let missingCount: Int
    let hasSubstitutes: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption)
            Text("\(missingCount) substitutes")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(hasSubstitutes ? COLOR_WARM_AMBER : .gray)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(hasSubstitutes ? COLOR_WARM_AMBER.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}
