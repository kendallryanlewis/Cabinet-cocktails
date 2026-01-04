//
//  BartenderPrompts.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/29/24.
//

import SwiftUI

// MARK: - Ingredient Check Prompt
struct IngredientCheckPrompt: View {
    @Environment(\.colorScheme) var colorScheme
    let ingredients: [String]
    let onAddToCabinet: () -> Void
    let onSkip: () -> Void
    @State private var selectedIngredients: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Do you have these ingredients?")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("We'll use this to match drinks to your cabinet.")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ingredients, id: \.self) { ingredient in
                    Button(action: {
                        if selectedIngredients.contains(ingredient) {
                            selectedIngredients.remove(ingredient)
                        } else {
                            selectedIngredients.insert(ingredient)
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: selectedIngredients.contains(ingredient) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedIngredients.contains(ingredient) ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                                .font(.sectionHeader)
                            
                            Text(ingredient)
                                .font(.ingredientText)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                Button(action: onAddToCabinet) {
                    Text("Add to Cabinet")
                        .font(.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                }
                
                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(.bodyText)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
        .padding(32)
    }
}

// MARK: - Missing Ingredient Prompt
struct MissingIngredientPrompt: View {
    @Environment(\.colorScheme) var colorScheme
    let missingIngredients: [String]
    let onAddMissing: () -> Void
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Almost there")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("You're missing a few ingredients.\nWant to add them to your cabinet or continue anyway?")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(missingIngredients, id: \.self) { ingredient in
                    HStack(spacing: 12) {
                        Image(systemName: "circle")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .font(.bodyLarge)
                        
                        Text(ingredient)
                            .font(.ingredientText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                Button(action: onAddMissing) {
                    Text("Add Missing Ingredients")
                        .font(.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                }
                
                Button(action: onContinue) {
                    Text("Continue Without")
                        .font(.bodyText)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
        .padding(32)
    }
}

// MARK: - Added to Cabinet Confirmation
struct AddedToCabinetConfirmation: View {
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(COLOR_WARM_AMBER)
                .font(.iconMedium)
                .padding(.top, 24)
            
            VStack(spacing: 8) {
                Text("Added to your cabinet")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("You can update quantities anytime.")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            Button(action: onDone) {
                Text("Done")
                    .font(.buttonText)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
        .padding(32)
    }
}

// MARK: - First Time Cabinet Prompt
struct FirstTimeCabinetPrompt: View {
    let onOpenCabinet: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("What's in your cabinet?")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("Select what you already have.\nWe'll handle the rest.")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            
            VStack(spacing: 12) {
                Button(action: onOpenCabinet) {
                    Text("Open Cabinet")
                        .font(.buttonText)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                }
                
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.bodyText)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(20)
        .padding(32)
    }
}

// MARK: - Inline Helper Banner
struct InlineHelperBanner: View {
    let message: String
    let actionText: String
    let onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
            
            Spacer()
            
            Button(action: onAction) {
                Text(actionText)
                    .font(.caption)
                    .foregroundColor(COLOR_WARM_AMBER)
            }
        }
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(8)
    }
}

// MARK: - Inline Ingredient Toggle Row
struct InlineIngredientToggle: View {
    let ingredient: String
    let isInCabinet: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isInCabinet ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isInCabinet ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                    .font(.navTitle)
                
                Text(ingredient)
                    .font(.ingredientText)
                    .foregroundColor(isInCabinet ? COLOR_TEXT_PRIMARY : COLOR_TEXT_SECONDARY)
                
                Spacer()
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        FirstTimeCabinetPrompt(
            onOpenCabinet: {},
            onSkip: {}
        )
        
        AddedToCabinetConfirmation(onDone: {})
    }
    .background(COLOR_CHARCOAL)
}
