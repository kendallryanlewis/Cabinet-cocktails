//
//  UserPreferencesView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

typealias DrinkStrength = UserPreferences.DrinkStrength
typealias DietaryRestriction = UserPreferences.DietaryRestriction

struct UserPreferencesView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var showingAllergyInput = false
    @State private var newAllergy = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Drink Strength
                Section(header: Text("Drink Strength Preference")) {
                    Picker("Preferred Strength", selection: $preferencesManager.preferences.preferredStrength) {
                        ForEach([DrinkStrength.light, .medium, .strong, .veryStrong], id: \.self) { strength in
                            Text(strength.rawValue).tag(strength)
                        }
                    }
                    .onChange(of: preferencesManager.preferences.preferredStrength) { _ in
                        preferencesManager.save()
                    }
                }
                
                // Experience Level
                Section(header: Text("Experience Level")) {
                    Picker("Your Experience", selection: $preferencesManager.preferences.experienceLevel) {
                        ForEach([DifficultyLevel.beginner, .intermediate, .advanced, .expert], id: \.self) { level in
                            HStack {
                                Image(systemName: levelIcon(level))
                                Text(level.rawValue)
                            }
                            .tag(level)
                        }
                    }
                    .onChange(of: preferencesManager.preferences.experienceLevel) { _ in
                        preferencesManager.save()
                    }
                }
                
                // Favorite Spirits
                Section(header: Text("Favorite Spirits")) {
                    NavigationLink(destination: FavoriteSpiritsView()) {
                        HStack {
                            Text("Manage Favorites")
                            Spacer()
                            Text("\(preferencesManager.preferences.favoriteSpirits.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Allergies
                Section(header: Text("Allergies & Dietary Restrictions")) {
                    NavigationLink(destination: AllergiesView()) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Allergies")
                            Spacer()
                            Text("\(preferencesManager.preferences.allergies.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: DislikedIngredientsView()) {
                        HStack {
                            Image(systemName: "hand.thumbsdown")
                                .foregroundColor(.orange)
                            Text("Disliked Ingredients")
                            Spacer()
                            Text("\(preferencesManager.preferences.dislikedIngredients.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: DietaryRestrictionsView()) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("Dietary Restrictions")
                            Spacer()
                            Text("\(preferencesManager.preferences.dietaryRestrictions.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Preferred Glassware
                Section(header: Text("Preferred Glassware")) {
                    NavigationLink(destination: PreferredGlasswareView()) {
                        HStack {
                            Text("Manage Glassware")
                            Spacer()
                            Text("\(preferencesManager.preferences.preferredGlasses.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func levelIcon(_ level: DifficultyLevel) -> String {
        switch level {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
}

// MARK: - Favorite Spirits View
struct FavoriteSpiritsView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var newSpirit = ""
    @State private var showingAddSpirit = false
    
    let commonSpirits = ["Vodka", "Gin", "Rum", "Tequila", "Whiskey", "Bourbon", "Scotch", "Brandy", "Cognac"]
    
    var body: some View {
        List {
            Section(header: Text("Your Favorites")) {
                ForEach(preferencesManager.preferences.favoriteSpirits, id: \.self) { spirit in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(spirit)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let spirit = preferencesManager.preferences.favoriteSpirits[index]
                        preferencesManager.removeFavoriteSpirit(spirit)
                    }
                }
            }
            
            Section(header: Text("Common Spirits")) {
                ForEach(commonSpirits.filter { !preferencesManager.preferences.favoriteSpirits.contains($0) }, id: \.self) { spirit in
                    Button(action: {
                        preferencesManager.addFavoriteSpirit(spirit)
                    }) {
                        HStack {
                            Text(spirit)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorite Spirits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSpirit = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Spirit", isPresented: $showingAddSpirit) {
            TextField("Spirit Name", text: $newSpirit)
            Button("Cancel", role: .cancel) {
                newSpirit = ""
            }
            Button("Add") {
                if !newSpirit.isEmpty {
                    preferencesManager.addFavoriteSpirit(newSpirit)
                    newSpirit = ""
                }
            }
        }
    }
}

// MARK: - Allergies View
struct AllergiesView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var newAllergy = ""
    @State private var showingAddAllergy = false
    
    let commonAllergens = ["Dairy", "Eggs", "Nuts", "Soy", "Gluten", "Shellfish"]
    
    var body: some View {
        List {
            Section(header: Text("Your Allergies"),
                    footer: Text("Cocktails containing these ingredients will be filtered out for your safety.")) {
                ForEach(preferencesManager.preferences.allergies, id: \.self) { allergy in
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(allergy)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        preferencesManager.preferences.allergies.remove(at: index)
                        preferencesManager.save()
                    }
                }
            }
            
            Section(header: Text("Common Allergens")) {
                ForEach(commonAllergens.filter { !preferencesManager.preferences.allergies.contains($0) }, id: \.self) { allergen in
                    Button(action: {
                        preferencesManager.addAllergy(allergen)
                    }) {
                        HStack {
                            Text(allergen)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Allergies")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddAllergy = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Allergy", isPresented: $showingAddAllergy) {
            TextField("Ingredient", text: $newAllergy)
            Button("Cancel", role: .cancel) {
                newAllergy = ""
            }
            Button("Add") {
                if !newAllergy.isEmpty {
                    preferencesManager.addAllergy(newAllergy)
                    newAllergy = ""
                }
            }
        }
    }
}

// MARK: - Disliked Ingredients View
struct DislikedIngredientsView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var newIngredient = ""
    @State private var showingAddIngredient = false
    
    var body: some View {
        List {
            Section(header: Text("Disliked Ingredients"),
                    footer: Text("Cocktails containing these ingredients will be hidden from recommendations.")) {
                ForEach(preferencesManager.preferences.dislikedIngredients, id: \.self) { ingredient in
                    HStack {
                        Image(systemName: "hand.thumbsdown")
                            .foregroundColor(.orange)
                        Text(ingredient)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        preferencesManager.preferences.dislikedIngredients.remove(at: index)
                        preferencesManager.save()
                    }
                }
            }
        }
        .navigationTitle("Disliked Ingredients")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddIngredient = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Disliked Ingredient", isPresented: $showingAddIngredient) {
            TextField("Ingredient", text: $newIngredient)
            Button("Cancel", role: .cancel) {
                newIngredient = ""
            }
            Button("Add") {
                if !newIngredient.isEmpty {
                    preferencesManager.preferences.dislikedIngredients.append(newIngredient)
                    preferencesManager.save()
                    newIngredient = ""
                }
            }
        }
    }
}

// MARK: - Dietary Restrictions View
struct DietaryRestrictionsView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    
    var body: some View {
        List {
            Section(footer: Text("Select all dietary restrictions that apply to you.")) {
                ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                    Toggle(isOn: binding(for: restriction)) {
                        HStack {
                            Image(systemName: iconFor(restriction))
                                .foregroundColor(colorFor(restriction))
                            Text(restriction.rawValue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Dietary Restrictions")
    }
    
    func binding(for restriction: DietaryRestriction) -> Binding<Bool> {
        Binding(
            get: { preferencesManager.preferences.dietaryRestrictions.contains(restriction) },
            set: { isOn in
                if isOn {
                    if !preferencesManager.preferences.dietaryRestrictions.contains(restriction) {
                        preferencesManager.preferences.dietaryRestrictions.append(restriction)
                    }
                } else {
                    preferencesManager.preferences.dietaryRestrictions.removeAll { $0 == restriction }
                }
                preferencesManager.save()
            }
        )
    }
    
    func iconFor(_ restriction: DietaryRestriction) -> String {
        switch restriction {
        case .vegan: return "leaf.fill"
        case .glutenFree: return "g.circle.fill"
        case .dairyFree: return "drop.triangle.fill"
        case .sugarFree: return "s.circle.fill"
        case .lowCalorie: return "flame.fill"
        }
    }
    
    func colorFor(_ restriction: DietaryRestriction) -> Color {
        switch restriction {
        case .vegan: return .green
        case .glutenFree: return .orange
        case .dairyFree: return .blue
        case .sugarFree: return .purple
        case .lowCalorie: return .red
        }
    }
}

// MARK: - Preferred Glassware View
struct PreferredGlasswareView: View {
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @State private var newGlass = ""
    @State private var showingAddGlass = false
    
    let commonGlasses = ["Highball glass", "Lowball glass", "Martini glass", "Coupe glass", "Shot glass", "Wine glass", "Champagne flute"]
    
    var body: some View {
        List {
            Section(header: Text("Your Glassware")) {
                ForEach(preferencesManager.preferences.preferredGlasses, id: \.self) { glass in
                    HStack {
                        Image(systemName: "wineglass")
                            .foregroundColor(.blue)
                        Text(glass)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        preferencesManager.preferences.preferredGlasses.remove(at: index)
                        preferencesManager.save()
                    }
                }
            }
            
            Section(header: Text("Common Glassware")) {
                ForEach(commonGlasses.filter { !preferencesManager.preferences.preferredGlasses.contains($0) }, id: \.self) { glass in
                    Button(action: {
                        preferencesManager.preferences.preferredGlasses.append(glass)
                        preferencesManager.save()
                    }) {
                        HStack {
                            Text(glass)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Preferred Glassware")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddGlass = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Add Glassware", isPresented: $showingAddGlass) {
            TextField("Glass Type", text: $newGlass)
            Button("Cancel", role: .cancel) {
                newGlass = ""
            }
            Button("Add") {
                if !newGlass.isEmpty {
                    preferencesManager.preferences.preferredGlasses.append(newGlass)
                    preferencesManager.save()
                    newGlass = ""
                }
            }
        }
    }
}
