//
//  SearchView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/9/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @State private var searchTextSpirits = ""
    @State var selectedAlcoholTypes: [Ingredient] = []
    @State var showResults = true
    @State var showPopover = false
    @State var searchResults: [DrinkDetails] = []
    
    let savedItems = LocalStorageManager.shared.retrieveTopShelfItems()
    
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
    
    var body: some View {
        ZStack(){
            VStack {
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
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
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
                        if(searchResults.count == 0){
                            Text("Sorry, try some other ingredients.").padding(.top, 30).bold()
                        }else{
                            HStack(){
                                Text(SEARCH_SHELF_RESULTS).bold().font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                Spacer()
                            }.padding(.top)
                            GenericListView(list: searchResults, showPopover: $showPopover).padding(.top, -20)
                        }
                    }
                }
                Button(action: {
                    searchResults = DrinkManager.shared.searchIngredients(ingredients: selectedAlcoholTypes) ?? []
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
        }
        .popover(isPresented: $showPopover) {
            if DrinkManager.shared.selectedCocktail != nil {
                DetailsView(cocktail: DrinkManager.shared.selectedCocktail!.name, hideCloseButton: true, dismiss: {})
            } else {
                // Provide a default/fallback view in case 'selectedCocktail' is nil
                Text("No cocktail selected")
            }
        }
    }
}
