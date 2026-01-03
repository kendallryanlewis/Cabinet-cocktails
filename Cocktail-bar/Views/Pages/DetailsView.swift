//
//  DetailsView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/11/23.
//

import SwiftUI
import AVKit
import WebKit


struct DetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var cocktail: String
    @State var hideCloseButton: Bool
    @State private var tagArray: [String]?
    @State var cocktailDetails: DrinkDetails? // Make it optional initially
    @State private var isFilled = false
    @State private var showDetails = false
    @State private var isLoading = true
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @State private var showMarkAsMadeSheet = false
    @State private var showBatchCalculator = false
    @State private var showSubstitutions = false
    @State private var showAddToCollection = false
    @StateObject private var substitutionManager = SubstitutionManager.shared
    @StateObject private var collectionManager = CollectionManager.shared
    let dismiss: () -> Void // Closure to dismiss the sheet
    
    var body: some View {
        ZStack(){
            if isLoading {
                // Loading state
                ZStack {
                    LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    SwiftUI.ProgressView()
                        .scaleEffect(1.5)
                        .tint(COLOR_WARM_AMBER)
                }
            } else if let details = cocktailDetails {
                ZStack(){
                    LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    VStack(){
                        if let imageURLString = details.strDrinkThumb,
                           let imageURL = URL(string: imageURLString) {
                            CachedAsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .ignoresSafeArea()
                            } placeholder: {
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    SwiftUI.ProgressView()
                                        .tint(COLOR_WARM_AMBER)
                                }
                                .frame(height: 300)
                                .ignoresSafeArea()
                            }
                        }
                        Spacer()
                    }
                    if(colorScheme == .dark){
                        LinearGradient(colors: [ .clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.5), LINEAR_BOTTOM.opacity(0.75), LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    }else{
                        LinearGradient(colors: [ .clear, LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.5), LIGHT_LINEAR_BOTTOM.opacity(0.75), LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    }
                    VStack() {
                        VStack{
                            if(!hideCloseButton){
                                HStack{
                                    Button(action: {
                                        dismiss() // Call the dismiss closure
                                    }, label: {
                                        ZStack {
                                            // Black circle with opacity
                                            Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 30, height: 30)
                                            
                                            // User icon
                                            Image(systemName: "xmark")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.white)
                                                .frame(width: 10, height: 10)
                                        }
                                    })
                                    Spacer()
                                }.padding(.top)
                            }
                            Spacer()
                            HStack(){
                                VStack(alignment: .leading){
                                    Text(cocktail).font(.largeTitle).fontWeight(.bold)
                                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                    if let strCategory = details.strCategory {
                                        Text(strCategory).textCase(.uppercase).font(.subheadline)
                                            .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .white)

                                    }
                                }
                                Spacer()
                            }
                        }.padding().frame(height: 300)
                        ScrollView(showsIndicators:false) {
                            VStack(alignment:.leading){
                                HStack(){
                                    Text("Details for \(cocktail)").font(.title3).bold()
                                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                    Spacer()
                                    
                                    // Mark as Made Button
                                    Button(action: {
                                        showMarkAsMadeSheet = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: historyManager.hasMade(cocktail) ? "checkmark.circle.fill" : "plus.circle")
                                            if historyManager.getCocktailCount(for: cocktail) > 0 {
                                                Text("\(historyManager.getCocktailCount(for: cocktail))")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                            }
                                        }
                                        .foregroundColor(historyManager.hasMade(cocktail) ? .green : COLOR_WARM_AMBER)
                                    }
                                    .padding(.trailing, 8)
                                    
                                    // Batch Calculator Button
                                    Button(action: {
                                        showBatchCalculator = true
                                    }) {
                                        Image(systemName: "multiply.circle")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                    }
                                    .padding(.trailing, 8)
                                    
                                    // Substitution Button
                                    if getMissingIngredientsCount(details: details) > 0 {
                                        Button(action: {
                                            showSubstitutions = true
                                        }) {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .foregroundColor(COLOR_WARM_AMBER)
                                        }
                                        .padding(.trailing, 8)
                                    }
                                    
                                    // Add to Collection Button
                                    Button(action: {
                                        showAddToCollection = true
                                    }) {
                                        Image(systemName: "folder.badge.plus")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                    }
                                    .padding(.trailing, 8)
                                    
                                    // Share Button
                                    QuickShareButton(contentType: .cocktailRecipe(details))
                                        .padding(.trailing, 8)
                                    
                                    // Favorite Star
                                    Button(action: {
                                        if(isFilled){
                                            LocalStorageManager.shared.removeFavoriteItem(at: removeFromFavorites())
                                        }else{
                                            LocalStorageManager.shared.addFavoriteItem(newItem: addToFavorites(detail: details))
                                        }
                                        isFilled.toggle()
                                    }) {
                                        Image(systemName: isFilled ? "star.fill" : "star")
                                            .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                    }
                                }.padding(.vertical, 30)
                                HStack(){
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Ingredients:").fontWeight(.bold)
                                            .font(.subheadline)
                                            .foregroundColor(colorScheme == .dark ? COLOR_WARM_AMBER : COLOR_SECONDARY)
                                        
                                        // Get all ingredients with their measurements
                                        let ingredients = [
                                            (details.strIngredient1, details.strMeasure1),
                                            (details.strIngredient2, details.strMeasure2),
                                            (details.strIngredient3, details.strMeasure3),
                                            (details.strIngredient4, details.strMeasure4),
                                            (details.strIngredient5, details.strMeasure5),
                                            (details.strIngredient6, details.strMeasure6),
                                            (details.strIngredient7, details.strMeasure7),
                                            (details.strIngredient8, details.strMeasure8),
                                            (details.strIngredient9, details.strMeasure9),
                                            (details.strIngredient10, details.strMeasure10),
                                            (details.strIngredient11, details.strMeasure11),
                                            (details.strIngredient12, details.strMeasure12),
                                            (details.strIngredient13, details.strMeasure13),
                                            (details.strIngredient14, details.strMeasure14),
                                            (details.strIngredient15, details.strMeasure15)
                                        ]
                                        
                                        let userIngredients = LocalStorageManager.shared.retrieveTopShelfItems()
                                        
                                        ForEach(ingredients.compactMap { $0 }, id: \.0) { ingredient, measure in
                                            if let ingredientName = ingredient {
                                                let hasIngredient = userIngredients.contains { userIng in
                                                    userIng.lowercased() == ingredientName.lowercased()
                                                }
                                                
                                                Button(action: {
                                                    // Toggle ingredient in cabinet
                                                    if hasIngredient {
                                                        if let index = userIngredients.firstIndex(where: { $0.lowercased() == ingredientName.lowercased() }) {
                                                            LocalStorageManager.shared.removeTopShelfItem(at: index)
                                                        }
                                                    } else {
                                                        LocalStorageManager.shared.addTopShelfItem(newItem: ingredientName)
                                                    }
                                                }) {
                                                    HStack(spacing: 12) {
                                                        Image(systemName: hasIngredient ? "checkmark.circle.fill" : "circle")
                                                            .foregroundColor(hasIngredient ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                                                            .font(.system(size: 20))
                                                        
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(ingredientName)
                                                                .font(.ingredientText)
                                                                .foregroundColor(hasIngredient ? COLOR_TEXT_PRIMARY : COLOR_TEXT_SECONDARY)
                                                            
                                                            if let measureText = measure, !measureText.isEmpty {
                                                                Text(measureText)
                                                                    .font(.caption)
                                                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 8)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        
                                        // Inline helper text
                                        Text("Tap to add to your cabinet")
                                            .font(.caption)
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                            .padding(.top, 8)
                                        Spacer()
                                    }
                                    Spacer()
                                    if details.strVideo == nil && tagArray != []{
                                        VStack(alignment: .leading, spacing: 5){
                                            Text("Drink Tags:")
                                                .fontWeight(.bold).font(.subheadline).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                            
                                            let tags = details.strTags?.split(separator: ",").map(String.init) ?? ["No tag"]
                                            let filteredTags = tags.filter { $0.count <= 8 }

                                            ForEach(filteredTags, id: \.self) { tag in
                                                if tag.count <= 12 {
                                                    Text(tag.trimmingCharacters(in: .whitespaces))
                                                }
                                            }
                                            Spacer()
                                        }.padding(.trailing, 20)
                                    }
                                }
                                if let isntructions = details.strInstructions {
                                    Text("Instructions").fontWeight(.bold).font(.headline).padding(.top, 10).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                    Text(isntructions)
                                }
                                if let strGlass = details.strGlass {
                                    Text("Drinking Glass").fontWeight(.bold).font(.headline).padding(.top, 10).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                    Text("Drink with a \(strGlass).")
                                }
                            }.padding()
                        }
                        Spacer()
                        if details.strVideo != nil {
                            VStack(){
                                Button(action: {
                                    showDetails.toggle()
                                }, label: {
                                    Spacer()
                                    Text("Start Mixing")
                                    Spacer()
                                }).padding()
                                    .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                    .cornerRadius(50)
                                    .foregroundColor(colorScheme == .dark ? LINEAR_BOTTOM : LIGHT_LINEAR_BOTTOM)
                            }.padding()
                        }
                    }.padding()
                }
                .sheet(isPresented: $showMarkAsMadeSheet) {
                    if let details = cocktailDetails {
                        let ingredients = extractIngredients(from: details)
                        MarkAsMadeSheet(
                            isPresented: $showMarkAsMadeSheet,
                            cocktailName: details.strDrink,
                            drinkId: details.idDrink,
                            ingredients: ingredients
                        )
                    }
                }
                .sheet(isPresented: $showBatchCalculator) {
                    if let details = cocktailDetails {
                        BatchCalculatorView(drink: details)
                    }
                }
                .sheet(isPresented: $showSubstitutions) {
                    if let details = cocktailDetails {
                        SubstitutionSuggestionsView(drink: details)
                    }
                }
                .sheet(isPresented: $showAddToCollection) {
                    if let details = cocktailDetails {
                        AddToCollectionView(
                            drinkId: details.idDrink,
                            drinkName: details.strDrink,
                            drinkThumb: details.strDrinkThumb
                        )
                    }
                }
            } else {
                // Error state
                ZStack {
                    LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        Text("Cocktail not found")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(COLOR_WARM_AMBER)
                    }
                }
            }
        }.ignoresSafeArea()
        .task(id: cocktail) {
            // Performance: Load cocktail details immediately when view appears
            isLoading = true
            self.cocktailDetails = DrinkManager.shared.findDrinkByName(name: cocktail)
            if LocalStorageManager.shared.retrieveFavoriteItems().contains(where: { $0.name == cocktail }) {
                isFilled = true
            }
            isLoading = false
        }
        .sheet(isPresented: $showDetails) {
            DetailsSubView(cocktailDetails: cocktailDetails!, tagArray: tagArray ?? [])
        }
        .sheet(isPresented: $showMarkAsMadeSheet) {
            if let details = cocktailDetails {
                MarkAsMadeSheet(
                    isPresented: $showMarkAsMadeSheet,
                    cocktailName: cocktail,
                    drinkId: details.idDrink,
                    ingredients: extractIngredients(from: details)
                )
            }
        }
    }
    
    func addToFavorites(detail: DrinkDetails)-> Ingredient{
        return Ingredient(name: detail.strDrink, image: detail.strDrinkThumb ?? "", type: .alcohol, category: detail.strCategory)
    }
    
    func removeFromFavorites() -> Int{
        // Find the index of the Person object with the given name
        if let index = LocalStorageManager.shared.retrieveFavoriteItems().firstIndex(where: { $0.name == cocktail }) {
            return index
        } else {
            return -1
        }
    }
    
    func extractIngredients(from details: DrinkDetails) -> [String] {
        let ingredients = [
            details.strIngredient1, details.strIngredient2, details.strIngredient3,
            details.strIngredient4, details.strIngredient5, details.strIngredient6,
            details.strIngredient7, details.strIngredient8, details.strIngredient9,
            details.strIngredient10, details.strIngredient11, details.strIngredient12,
            details.strIngredient13, details.strIngredient14, details.strIngredient15
        ]
        return ingredients.compactMap { $0 }.filter { !$0.isEmpty }
    }
    
    func getMissingIngredientsCount(details: DrinkDetails) -> Int {
        let userInventory = LocalStorageManager.shared.retrieveTopShelfItems()
        let userInventoryLower = userInventory.map { $0.lowercased() }
        let ingredients = extractIngredients(from: details)
        
        let missing = ingredients.filter { ingredient in
            let ingredientLower = ingredient.lowercased()
            return !userInventoryLower.contains(where: { $0.contains(ingredientLower) || ingredientLower.contains($0) })
        }
        
        return missing.count
    }
}

struct DetailsSubView: View {
    @State var cocktailDetails: DrinkDetails
    @State var tagArray: [String]
    var body: some View {
        if cocktailDetails.strVideo != nil {
            WebVideoView(urlString: cocktailDetails.strVideo!).frame(height: .infinity)
        }
    }
}

// MARK: - Mark as Made Sheet
struct MarkAsMadeSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @StateObject private var historyManager = CocktailHistoryManager.shared
    
    let cocktailName: String
    let drinkId: String
    let ingredients: [String]
    
    @State private var rating: Int = 0
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: colorScheme == .dark ?
                        Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                        Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                    startPoint: .topTrailing,
                    endPoint: .leading
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Cocktail Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mark as Made")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Text(cocktailName)
                                .font(.cocktailTitle)
                                .foregroundColor(COLOR_WARM_AMBER)
                            
                            if historyManager.getCocktailCount(for: cocktailName) > 0 {
                                Text("You've made this \\(historyManager.getCocktailCount(for: cocktailName)) time\(historyManager.getCocktailCount(for: cocktailName) == 1 ? "" : "s") before")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        }
                        
                        // Rating
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rating (Optional)")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            HStack(spacing: 16) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: {
                                        rating = star
                                    }) {
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.system(size: 32))
                                            .foregroundColor(star <= rating ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                                    }
                                }
                                
                                if rating > 0 {
                                    Button(action: { rating = 0 }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                }
                            }
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes (Optional)")
                                .font(.sectionHeader)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            TextEditor(text: $notes)
                                .font(.bodyText)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .frame(height: 100)
                                .padding(8)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                        }
                        
                        // Save Button
                        Button(action: {
                            historyManager.addToHistory(
                                cocktailName: cocktailName,
                                drinkId: drinkId,
                                rating: rating > 0 ? rating : nil,
                                notes: notes.isEmpty ? nil : notes,
                                ingredients: ingredients
                            )
                            isPresented = false
                        }) {
                            Text("Save to History")
                                .font(.bodyText)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_CHARCOAL)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(COLOR_WARM_AMBER)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Log Cocktail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
}

// MARK: - Extension for Drink Initializer
extension DetailsView {
    init(drink: Drink) {
        self.init(
            cocktail: drink.strDrink,
            hideCloseButton: false,
            dismiss: {}
        )
    }
}


#Preview {
    MainView()
}
