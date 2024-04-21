//
//  SearchView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/9/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    let savedItems = LocalStorageManager.shared.retrieveTopShelfItems()
    @Binding var isMenuOpen: Bool
    @State private var searchTextSpirits = ""
    @State var selectedAlcoholTypes: [Ingredient] = []
    @State var showResults = true
    @State var showPopover = false
    @State var searchResults: [DrinkDetails] = []
    @State private var columns: [GridItem] = []

    // Adjusting number of columns based on device orientation
    private func adjustColumns(width: CGFloat) {
        // Define breakpoints or use specific width thresholds
        if width > 1000 { // Likely an iPad in landscape
            columns = Array(repeating: .init(.flexible()), count: 5)
        } else if width > 768 { // Likely an iPad in portrait
            columns = Array(repeating: .init(.flexible()), count: 4)
        } else { // iPhone and smaller iPad sizes in various orientations
            columns = Array(repeating: .init(.flexible()), count: 2)
        }
    }
    
    // Filtered list based on the search query
    var filteredAlcoholTypes: [Ingredient] {
        if searchTextSpirits.isEmpty {
            // If search text is empty, return the entire list
            if(DrinkManager.shared.allIngredients == nil){
                DrinkManager.shared.getAllUniqueIngredients() //get all ingredients
            }
            return DrinkManager.shared.allIngredients ?? []
        } else {
            // Otherwise, filter the list based on the search text
            return DrinkManager.shared.allIngredients?.filter { $0.name.lowercased().contains(searchTextSpirits.lowercased()) } ?? []
        }
    }
    
    var filteredDrinks: [DrinkDetails] {
        if searchTextSpirits.isEmpty {
            // If search text is empty, return the entire list
            return DrinkManager.shared.allDrinks ?? []
        } else {
            // Otherwise, filter the list based on the search text
            let lowercasedSearchText = searchTextSpirits.lowercased()            // Filter the drinks based on the search criteria
            return DrinkManager.shared.allDrinks?.filter { drink in
                // Check if the drink's category contains the search text
                let categoryMatch = drink.strCategory?.lowercased().contains(lowercasedSearchText) ?? false

                // Check if the drink's alcoholic content contains the search text
                let alcoholicMatch = drink.strAlcoholic.lowercased().contains(lowercasedSearchText)

                
                // Check if the drink's alcoholic content contains the search text
                let drinkMatch = drink.strDrink.lowercased().contains(lowercasedSearchText)

                // Check if any of the drink's ingredients contain the search text
                let ingredientMatch = drink.getIngredients().contains(where: { ingredient in
                    ingredient.lowercased().contains(lowercasedSearchText)
                })

                // Combine the conditions with a logical OR to allow for broader searches
                return drinkMatch || categoryMatch || alcoholicMatch || ingredientMatch
            } ?? []
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack(){
                    VStack(alignment: .leading){
                        Text(QUICK_MIX_TEXT)
                            .font(.title).bold().foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        Text(QUICK_MIX_DESCRIPTION_TEXT).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    }
                    Spacer().frame(width: 100)
                }.padding(.bottom)
                SearchShelfView(searchText: $searchTextSpirits, showSearchField: $showResults, selectedAlcoholTypes: selectedAlcoholTypes)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack{
                        if(showResults && selectedAlcoholTypes.count == 0){
                            DashboardView(searchText: $searchTextSpirits)
                        }
                        if(selectedAlcoholTypes.count != 0){
                            HStack(){
                                Text(CABINET_TEXT).bold()
                                    .font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                Spacer()
                            }.padding(.top)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack{
                                HStack {
                                    ForEach(selectedAlcoholTypes, id: \.self) { cocktail in
                                        ZStack {
                                            COLOR_SECONDARY
                                            VStack {
                                                if UIImage(named: cocktail.name) != nil {
                                                    Image(cocktail.name)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .ignoresSafeArea(.all)
                                                        .frame(width: 150, height: 200)
                                                        .clipped()
                                                }else{
                                                    Image("GenericAlcohol")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .ignoresSafeArea(.all)
                                                        .frame(width: 150, height: 200)
                                                        .clipped()
                                                }
                                            }.frame(width: 150, height: 200)
                                            ZStack {
                                                LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, COLOR_PRIMARY.opacity(0.5), COLOR_PRIMARY]), startPoint: .topTrailing, endPoint: .bottomLeading)
                                                VStack {
                                                    Spacer()
                                                    HStack() {
                                                        VStack(alignment:.leading){
                                                            Text(cocktail.name)
                                                                .font(.headline)
                                                                .bold()
                                                            Text("\(cocktail.type)")
                                                                .font(.subheadline)
                                                                .foregroundColor(LINEAR_BOTTOM)
                                                        }
                                                        Spacer()
                                                    }
                                                }
                                                .padding()
                                            }
                                            .frame(width: 150, height: 200)
                                            .foregroundColor(.white)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .onTapGesture {
                                            if let index = selectedAlcoholTypes.firstIndex(where: { $0.name == cocktail.name }) {
                                                selectedAlcoholTypes.remove(at: index)
                                                if(selectedAlcoholTypes.count == 0){
                                                    showResults = true
                                                }else{
                                                    searchResults = DrinkManager.shared.searchIngredients(ingredients: selectedAlcoholTypes) ?? []
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }.padding(0)
                        if(showResults){
                            HStack(){
                                Text(SEARCH_SHELF).bold().font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                Spacer()
                            }.padding(.top)
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(filteredAlcoholTypes) { item in
                                    CabinetView(onTapped: {
                                        if let index = selectedAlcoholTypes.firstIndex(where: { $0.name == item.name }) {
                                            selectedAlcoholTypes.remove(at: index)
                                        } else {
                                            selectedAlcoholTypes.append(item)
                                        }
                                        
                                    }, searchTextSpirits: $searchTextSpirits, selectedAlcoholTypes: $selectedAlcoholTypes, item: item)
                                }
                            }.padding(.horizontal, -20)
                        }else{
                            HStack(){
                                Text(SEARCH_SHELF_RESULTS).bold().font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                Spacer()
                            }.padding(.top)
                            if(searchResults.count == 0 || selectedAlcoholTypes.count == 1){
                                HStack(){
                                    Text(NO_COCKTAILS_FOUND)
                                        .padding(.top, 30)
                                        .bold()
                                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                    Spacer()
                                }.padding(.bottom)
                            }else{
                                GenericListView(list: searchResults, showPopover: $showPopover)
                            }
                        }
                        if(showResults){
                            HStack{
                                Text(COCKTAILS_TEXT).bold().font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                Spacer()
                            }
                            GenericListView(list: filteredDrinks, showPopover: $showPopover)
                        }
                    }
                }
                Button(action: {
                    searchResults = DrinkManager.shared.getQuickDrinkPossibilities(ingredients: selectedAlcoholTypes) ?? []
                    showResults.toggle()
                }, label: {
                    HStack(){
                        Spacer()
                        Text(showResults ? VIEW_MIXES : VIEW_CABINET).padding()
                        Spacer()
                    }
                })
                .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
                .cornerRadius(8)
            }.padding(40) // Added vertical padding
            .sheet(isPresented: $showPopover) {
                if DrinkManager.shared.selectedCocktail != nil {
                    DetailsView(cocktail: DrinkManager.shared.selectedCocktail!.name, hideCloseButton: true, dismiss: {})
                } else {
                    // Provide a default/fallback view in case 'selectedCocktail' is nil
                    Text("No cocktail selected")
                }
            }
            .onAppear {
                adjustColumns(width: geometry.size.width)
            }
            .onChange(of: geometry.size.width) { newWidth in
                adjustColumns(width: newWidth)
            }
        }
    }
}
