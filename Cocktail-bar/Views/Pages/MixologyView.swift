//
//  MixologyView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct MixologyView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var searchTextSpirits = ""
    @State private var selection = 0
    @State private var popoverSelection: String = ""
    @State private var showMore = true
    @State var drinkDictionary: [String: [String: [DrinkDetails]]] = [:]
    @State var cocktailList: [DrinkDetails] = []
    @State var showCartList = false
    @State var showSlider = false
    @State var showMyPossibilities = false
    @State var cocktailDetails: DrinkDetails?

    // Filtered list based on the search query
    var filteredAlcoholTypes: [Ingredient] {
        if searchTextSpirits.isEmpty {
            // If search text is empty, return the entire list
            return DrinkManager.shared.allIngredients ?? []
        } else {
            // Otherwise, filter the list based on the search text
            return DrinkManager.shared.allIngredients?.filter { $0.name.lowercased().contains(searchTextSpirits.lowercased()) } ?? []
        }
    }
    
    var body: some View {
        ZStack(){
            GenericBackground()
            TabView(selection: $selection) {
                ZStack(){
                    VStack(){
                        if let imageURL = URL(string: "https://images.unsplash.com/photo-1602697027404-36d0a53aba2e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1ODEwNjN8MHwxfHNlYXJjaHw3fHxLb21idWNoYXxlbnwwfHx8fDE3MTEwNTM2ODl8MA&ixlib=rb-4.0.3&q=80&w=1080") {
                            GeometryReader { geometry in
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                    default:
                                        Color.black
                                    }
                                }
                            }
                            .ignoresSafeArea()
                            .overlay(content: {
                                if(colorScheme == .dark){
                                    LinearGradient(colors: [ .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.35), LINEAR_BOTTOM.opacity(0.5), LINEAR_BOTTOM.opacity(0.75), LINEAR_BOTTOM.opacity(0.95), LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                                        .allowsHitTesting(false) // Allows clicks to pass through
                                }else{
                                    LinearGradient(colors: [ .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.35), LIGHT_LINEAR_BOTTOM.opacity(0.5), LIGHT_LINEAR_BOTTOM.opacity(0.75), LIGHT_LINEAR_BOTTOM.opacity(0.95), LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                                        .allowsHitTesting(false) // Allows clicks to pass through
                                }
                            })
                        }
                    }.clipped().ignoresSafeArea()
                    VStack(alignment:.leading){
                        Spacer()
                        VStack(alignment: .center, spacing: 20){
                            Text(MIXOLOGY_TEXT).bold().font(.title)
                                .foregroundColor(colorScheme == .dark ? .white : .darkGray )
                            Text(MIXOLOGY_DESCRIPTION_TEXT)
                                .foregroundColor(colorScheme == .dark ? COLOR_SECONDARY : .darkGray )
                            Button(action: {
                                showMyPossibilities = true
                            }, label: {
                                HStack(){
                                    Spacer()
                                    Text(VIEW_CART).padding()
                                    Spacer()
                                }
                            })
                            .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                            .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
                            .cornerRadius(8)
                        }
                    }.padding(40)
                }.tag(0)
                ForEach(LocalStorageManager.shared.retrieveTopShelfItems().indices, id: \.self) { index in
                    DrinkView(category: LocalStorageManager.shared.retrieveTopShelfItems()[index], drinksByCategory: [:], showMore: $showMore, showSlider: $showSlider, selection: $selection, popoverSelection: $popoverSelection, cocktailList: $cocktailList)
                        .tag(index + 1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        .onAppear {
            DrinkManager.shared.onlyYourIngredients()
        }
        .ignoresSafeArea()
        .popover(isPresented: $showSlider) { // Use 'item' modifier for sheet presentation
            TabView(selection: $popoverSelection){
                ForEach(Array(DrinkManager.shared.tempDrinks.enumerated()), id: \.element.id) { subindex, cocktail in
                    DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {
                    }).tag(cocktail.strDrink)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page indicator
            .frame(maxHeight: .infinity) // Set the height of the slideshow
            .frame(maxWidth: .infinity) // Set the width of the slideshow
            .ignoresSafeArea()
        }
        .popover(isPresented: $showMyPossibilities) { // Use 'item' modifier for sheet presentation
            TabView(selection: $popoverSelection){
                if(DrinkManager.shared.myDrinkPossibilities != nil){
                    ForEach(Array(DrinkManager.shared.myDrinkPossibilities!.enumerated()), id: \.element.id) { subindex, cocktail in
                        DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {
                        }).tag(cocktail.strDrink)
                    }
                }else{
                    Text(COMBINATION_ERROR)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page indicator
            .frame(maxHeight: .infinity) // Set the height of the slideshow
            .frame(maxWidth: .infinity) // Set the width of the slideshow
            .ignoresSafeArea()
        }
    }
    
   
    func searchCombinations(ingredients: [String]){
        // Clear the existing search results
        cocktailList = []
        
        // Filter allDrinks based on provided ingredients
        if let allDrinks = DrinkManager.shared.allDrinks {
            let filteredDrinks = allDrinks.filter { drink in
                // Check if the drink contains all provided ingredients
                return ingredients.allSatisfy { ingredient in
                    // Check if the drink's ingredients contain the provided ingredient
                    return drink.containsIngredient(ingredient)
                }
            }
            
            // Map filtered drinks to Ingredient objects
            cocktailList = filteredDrinks.map { drink in
                return drink//Ingredient(name: drink.strDrink, image: drink.strDrinkThumb, type: .alcohol)
            }
        }
    }
    
    func addToFavorites(detail: DrinkDetails)-> Ingredient{
        return Ingredient(name: detail.strDrink, image: detail.strDrinkThumb ?? "", type: .alcohol)
    }
    
    func removeFromFavorites(cocktail: String) -> Int {
        // Find the index of the Person object with the given name
        if let index = LocalStorageManager.shared.retrieveFavoriteItems().firstIndex(where: { $0.name == cocktail }) {
            return index
        } else {
            return -1
        }
    }
}

#Preview {
    MixologyView()
}

