//
//  CustomRecipeEditorView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI
import PhotosUI

struct CustomRecipeEditorView: View {
    @StateObject private var recipeManager = CustomRecipeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var recipeName = ""
    @State private var category = "Cocktail"
    @State private var glassType = "Highball glass"
    @State private var instructions = ""
    @State private var ingredients: [RecipeIngredient] = []
    @State private var difficulty: DifficultyLevel = .beginner
    @State private var prepTime = 5
    @State private var tags: [String] = []
    @State private var isPublic = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    @State private var newIngredientName = ""
    @State private var newIngredientMeasurement = ""
    @State private var showingAddIngredient = false
    @State private var newTag = ""
    @State private var showingAddTag = false
    
    let categories = ["Cocktail", "Shot", "Ordinary Drink", "Punch", "Beer", "Soft Drink", "Coffee / Tea", "Cocoa"]
    let glassTypes = ["Highball glass", "Lowball glass", "Martini glass", "Coupe glass", "Shot glass", "Wine glass", "Champagne flute", "Collins glass", "Hurricane glass"]
    
    var isValid: Bool {
        !recipeName.isEmpty && !instructions.isEmpty && !ingredients.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info
                Section(header: Text("Basic Information")) {
                    TextField("Recipe Name", text: $recipeName)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Picker("Glass Type", selection: $glassType) {
                        ForEach(glassTypes, id: \.self) { glass in
                            Text(glass).tag(glass)
                        }
                    }
                }
                
                // Image
                Section(header: Text("Photo")) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        HStack {
                            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                    .frame(width: 60, height: 60)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Add Photo")
                                    .font(.headline)
                                Text("Choose from library")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                }
                
                // Ingredients
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(ingredient.name)
                                    .font(.body)
                                Text(ingredient.measurement)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: { showingAddIngredient = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Ingredient")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Instructions
                Section(header: Text("Instructions")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
                
                // Details
                Section(header: Text("Details")) {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach([DifficultyLevel.beginner, .intermediate, .advanced, .expert], id: \.self) { level in
                            HStack {
                                Image(systemName: levelIcon(level))
                                Text(level.rawValue)
                            }
                            .tag(level)
                        }
                    }
                    
                    Stepper("Prep Time: \(prepTime) min", value: $prepTime, in: 1...60)
                }
                
                // Tags
                Section(header: Text("Tags")) {
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                        Button(action: {
                                            tags.removeAll { $0 == tag }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    Button(action: { showingAddTag = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Tag")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Sharing
                Section(header: Text("Sharing")) {
                    Toggle("Make Public", isOn: $isPublic)
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecipe()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Add Ingredient", isPresented: $showingAddIngredient) {
                TextField("Name", text: $newIngredientName)
                TextField("Measurement", text: $newIngredientMeasurement)
                Button("Cancel", role: .cancel) {
                    newIngredientName = ""
                    newIngredientMeasurement = ""
                }
                Button("Add") {
                    if !newIngredientName.isEmpty && !newIngredientMeasurement.isEmpty {
                        let ingredient = RecipeIngredient(name: newIngredientName, measurement: newIngredientMeasurement)
                        ingredients.append(ingredient)
                        newIngredientName = ""
                        newIngredientMeasurement = ""
                    }
                }
            }
            .alert("Add Tag", isPresented: $showingAddTag) {
                TextField("Tag", text: $newTag)
                Button("Cancel", role: .cancel) {
                    newTag = ""
                }
                Button("Add") {
                    if !newTag.isEmpty && !tags.contains(newTag) {
                        tags.append(newTag)
                        newTag = ""
                    }
                }
            }
        }
    }
    
    func saveRecipe() {
        let recipe = CustomRecipe(
            name: recipeName,
            category: category,
            glass: glassType,
            instructions: instructions,
            ingredients: ingredients,
            imageData: imageData,
            difficulty: difficulty,
            prepTime: prepTime,
            tags: tags,
            isPublic: isPublic
        )
        
        recipeManager.addRecipe(recipe)
        presentationMode.wrappedValue.dismiss()
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

// MARK: - Custom Recipes List View
struct CustomRecipesListView: View {
    @StateObject private var recipeManager = CustomRecipeManager.shared
    @State private var showingEditor = false
    @State private var searchText = ""
    
    var filteredRecipes: [CustomRecipe] {
        if searchText.isEmpty {
            return recipeManager.recipes
        }
        return recipeManager.searchRecipes(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if recipeManager.recipes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Custom Recipes")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create your own cocktail recipes\nand save them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showingEditor = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Recipe")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                } else {
                    List {
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink(destination: CustomRecipeDetailView(recipe: recipe)) {
                                CustomRecipeRow(recipe: recipe)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                recipeManager.deleteRecipe(filteredRecipes[index])
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search recipes")
                }
            }
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEditor = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                CustomRecipeEditorView()
            }
        }
    }
}

// MARK: - Custom Recipe Row
struct CustomRecipeRow: View {
    let recipe: CustomRecipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                
                Text(recipe.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(recipe.prepTime) min")
                        .font(.caption)
                    
                    Image(systemName: difficultyIcon(recipe.difficulty))
                        .font(.caption)
                    Text(recipe.difficulty.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
    }
    
    func difficultyIcon(_ level: DifficultyLevel) -> String {
        switch level {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
}

// MARK: - Custom Recipe Detail View
struct CustomRecipeDetailView: View {
    let recipe: CustomRecipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Meta
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(recipe.category, systemImage: "tag")
                            Spacer()
                            Label("\(recipe.prepTime) min", systemImage: "clock")
                            Label(recipe.difficulty.rawValue, systemImage: difficultyIcon(recipe.difficulty))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Tags
                    if !recipe.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.headline)
                        
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(ingredient.name)
                                        .font(.body)
                                    Text(ingredient.measurement)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)
                        
                        Text(recipe.instructions)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Glass Type
                    HStack {
                        Image(systemName: "wineglass")
                            .foregroundColor(.blue)
                        Text("Serve in: \(recipe.glass)")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func difficultyIcon(_ level: DifficultyLevel) -> String {
        switch level {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
}
