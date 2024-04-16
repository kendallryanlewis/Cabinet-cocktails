//
//  TopShelfView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct TopShelfView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @State private var searchTextSpirits = ""
    @State var selectedAlcoholTypes: [Ingredient] = []
    @State var showSearch = true
    //Local Storage
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
                        Text(TOPSHELF_TEXT)
                            .font(.title).bold().foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        Text(ADD_REMOVE_CABINET).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    }
                    Spacer().frame(width: 100)
                }.padding(.bottom)
                SearchShelfView(searchText: $searchTextSpirits, showSearchField: $showSearch, selectedAlcoholTypes: selectedAlcoholTypes)
                ScrollView(.vertical, showsIndicators: false) {
                    HStack(){
                        Text(CABINET_TEXT).bold()
                            .font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        Spacer()
                    }.padding(.top)
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
                                            LocalStorageManager.shared.removeTopShelfItem(at: index)
                                        }
                                    }
                                }
                            }
                        }
                    }.padding(0)
                    HStack(){
                        Text(SEARCH_SHELF).bold().font(.headline).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        Spacer()
                    }.padding(.top)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                        ForEach(filteredAlcoholTypes) { item in
                        CabinetView(onTapped: {
                            if let index = selectedAlcoholTypes.firstIndex(where: { $0.name == item.name }) {
                                selectedAlcoholTypes.remove(at: index)
                                LocalStorageManager.shared.removeTopShelfItem(at: index)
                            } else {
                                selectedAlcoholTypes.append(item)
                                LocalStorageManager.shared.addTopShelfItem(newItem: item.name)
                                
                            }
                        }, searchTextSpirits: $searchTextSpirits, selectedAlcoholTypes: $selectedAlcoholTypes, item: item)
                        }
                    }.padding(.horizontal, -20)
                }
                .onAppear(){
                    //selectedAlcoholTypes = LocalStorageManager.shared.retrieveTopShelfItems()
                    LocalStorageManager.shared.retrieveTopShelfItems().forEach { item in
                        if let foundItem = DrinkManager.shared.allIngredients?.first(where: { $0.name == item }) {
                            selectedAlcoholTypes.append(foundItem)
                        }
                    }
                }
            }.padding(40) // Added vertical padding
        }
    }
}
struct SearchShelfView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText: String
    @Binding var showSearchField: Bool
    @State var selectedAlcoholTypes: [Ingredient]
    
    var body: some View {
        ZStack(alignment: .leading) {
            if searchText.isEmpty {
                Text("Search")
                    .foregroundColor(COLOR_PRIMARY) // Change placeholder color here
                    .padding(.horizontal, 10)
            }
            HStack {
                TextField("", text: $searchText)
                    .foregroundColor(.white)
                    .background(Color.clear)
                if(selectedAlcoholTypes.isEmpty){
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(COLOR_PRIMARY).bold()
                }else{
                    Button(action: {
                        clearCart()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                }
            }
            .padding(10)
        } .background(colorScheme == .dark ? .white.opacity(0.5) : COLOR_SECONDARY).cornerRadius(8)
        .onTapGesture {
            // Perform action when the search field is clicked
            showSearchField = true
        }
    }
    func clearCart(){
        
    }
}
