//
//  DashboardView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/11/23.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settingsManager: SystemSettingsManager
    @EnvironmentObject var session: SessionStore
    @State var showCartList = false
    @State private var selectedCocktail: Ingredient? = nil
    @State var showSearch = true
    @Binding var isMenuOpen: Bool
    @State private var selection = 0
    @State private var showPopover = false
    @State var popularDrinks: [Ingredient] = []
    @State var randomDrinks: [Ingredient] = []
    @State var latestDrinks: [Ingredient] = []
    
    
    @State private var searchText = ""
    @State var selectedAlcoholTypes: [DrinkDetails] = []
    
    var filteredDrinks: [DrinkDetails] {
        if searchText.isEmpty {
            // If search text is empty, return the entire list
            return DrinkManager.shared.allDrinks ?? []
        } else {
            // Otherwise, filter the list based on the search text
            let lowercasedSearchText = searchText.lowercased()

            // Filter the drinks based on the search criteria
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
        NavigationView {
            ZStack(){
                GenericBackground()
                VStack {
                    // Slideshow
                    TabView(selection: $selection)  {
                        ForEach(Array(popularDrinks.enumerated().prefix(5)), id: \.element.id) { index, cocktail in
                            AsyncImage(url: URL(string: cocktail.image!)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    Color.gray
                                }
                            }.ignoresSafeArea()
                            .tag(index)
                            .onTapGesture {
                                DrinkManager.shared.selectedCocktail = cocktail
                                if(selectedCocktail?.name != ""){
                                    showPopover = true
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page indicator
                    .frame(height: 500) // Set the height of the slideshow
                    .frame(maxWidth: .infinity) // Stretch TabView to full width
                    .ignoresSafeArea()
                    Spacer()
                }.opacity(0.8)
                if(colorScheme != .dark){
                    LinearGradient(colors: [ LIGHT_LINEAR_TOP, .clear, .clear, .clear, .clear, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                        .allowsHitTesting(false) // Allows clicks to pass through
                }else{
                    LinearGradient(colors: [ .clear, .clear, .clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.35), LINEAR_BOTTOM.opacity(0.5), LINEAR_BOTTOM.opacity(0.75), LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                        .allowsHitTesting(false) // Allows clicks to pass through
                }
                VStack(){
                    VStack(){
                        if(session.userSession != nil){
                            Button(action: {
                                withAnimation {
                                    isMenuOpen.toggle()
                                    showPopover = false
                                }
                            }) {
                                UserHeader(isMenuOpen: $isMenuOpen, user: session.userSession!).padding(.horizontal)
                            }
                        }else{
                            Text(APP_NAME)
                        }
                        
                        if(searchText.count == 0){
                            Spacer()
                        }
                        
                        HStack() {
                            ForEach(popularDrinks.indices.prefix(5), id: \.self) { index in
                                if(index == selection){
                                    VStack(alignment: .leading){
                                        Text("\(popularDrinks[index].name)").font(.headline).bold().textCase(.uppercase).foregroundColor(colorScheme == .dark ? .white : .darkGray)
                                        Text("\(popularDrinks[index].type)").font(.subheadline).foregroundColor(colorScheme == .dark ? .gray : .white)
                                    }
                                }
                            }
                            Spacer()
                            ForEach(popularDrinks.indices.prefix(5), id: \.self) { index in
                                ZStack {
                                    Circle()
                                        .stroke(colorScheme == .dark ? Color.white : .darkGray, lineWidth: 0.5)
                                        .frame(width: 8, height: 8)
                                    Circle()
                                        .fill(selection == index ? colorScheme == .dark ? Color.white : .darkGray : Color.clear)
                                        .frame(width: 3, height: 3)
                                    }
                                .onTapGesture {
                                    selection = index // Change the selection when the user taps an indicator
                                }
                            }
                        }
                        .padding()
                    }.frame(height: searchText.count == 0 ? 400 : 0) // Set the height of the slideshow
                    VStack {
                        CustomSearchBar(searchText: $searchText, showSearchField: $showSearch, selectedAlcoholTypes: selectedAlcoholTypes)
                        if(searchText.isEmpty && showSearch){
                            ScrollView(showsIndicators: false){
                                HStack(){
                                    Text("Popular").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                                    Spacer()
                                }
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(){
                                        ForEach(popularDrinks, id: \.id) { cocktail in
                                            itemView(onTapped: {
                                                DrinkManager.shared.selectedCocktail = cocktail
                                                if(cocktail.name != ""){
                                                    showPopover = true
                                                }
                                            }, cocktail: cocktail)
                                        }
                                    }
                                }
                                HStack(){
                                    Text("Latest").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                                    Spacer()
                                }.padding(.top)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(){
                                        ForEach(latestDrinks, id: \.id) { cocktail in
                                            itemView(onTapped: {
                                                DrinkManager.shared.selectedCocktail = cocktail
                                                if(cocktail.name != ""){
                                                    showPopover = true
                                                }
                                            }, cocktail: cocktail)
                                        }
                                    }
                                }
                                HStack(){
                                    Text("Random").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                                    Spacer()
                                }.padding(.top)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(){
                                        ForEach(randomDrinks, id: \.id) { cocktail in
                                            itemView(onTapped: {
                                                DrinkManager.shared.selectedCocktail = cocktail
                                                if(cocktail.name != ""){
                                                    showPopover = true
                                                }
                                            }, cocktail: cocktail)
                                        }
                                    }
                                }
                            }.padding(.top)
                        } else {
                            if(showSearch){
                                GenericListView(list: filteredDrinks, showPopover: $showPopover)
                            }
                        }
                    }
                    .padding() // Added vertical padding
                    //Spacer()
                }.padding()
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
        .allowsHitTesting(isMenuOpen ? false : true) // Allows clicks to pass through
        .onAppear(){
            searchPopularCocktails()
        }
    }
    
    //Function to find popular drinks
    func searchPopularCocktails() {
        fetchCocktails(from: "popular") { popularDrinks2 in
            self.popularDrinks = popularDrinks2
            self.selectedCocktail = popularDrinks2.first
        }
        fetchCocktails(from: "randomselection") { randomDrinks in
            self.randomDrinks = randomDrinks
        }
        fetchCocktails(from: "latest") { latestDrinks in
            self.latestDrinks = latestDrinks
        }
    }
    
    func fetchCocktails(from endpoint: String, completion: @escaping ([Ingredient]) -> Void) {
        guard let url = URL(string: "\(API_URL)/\(endpoint).php") else {
            print("Invalid URL for endpoint: \(endpoint)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let response = try JSONDecoder().decode(CocktailDBResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.drinks.compactMap { drink in
                        Ingredient(name: drink.strDrink, image: drink.strDrinkThumb, type: .alcohol)
                    })
                }
            } catch {
                print("Error decoding JSON for endpoint \(endpoint): \(error)")
            }
        }.resume()
    }
    
}

struct itemView: View {
    var onTapped: () -> Void  // Pass action directly
    @Environment(\.colorScheme) var colorScheme
    @State var cocktail: Ingredient
    
    var body: some View {
        Button(action: {
            onTapped()
        }, label: {
            ZStack {
                VStack {
                    if let imageURL = cocktail.image {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .ignoresSafeArea(.all)
                                    .frame(width: 150, height: 200)
                                    .clipped()
                            default:
                                Color.gray
                            }
                        }
                    }
                }.frame(width: 150, height: 200)
                ZStack {
                    if(colorScheme == .dark){
                        LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, COLOR_PRIMARY.opacity(0.75), COLOR_PRIMARY, COLOR_PRIMARY]), startPoint: .topTrailing, endPoint: .bottomLeading)
                    }else{
                        LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, COLOR_SECONDARY.opacity(0.75), COLOR_SECONDARY, COLOR_SECONDARY]), startPoint: .topTrailing, endPoint: .bottomLeading)
                    }
                    VStack(alignment:.leading) {
                        Spacer()
                        HStack() {
                            VStack(alignment:.leading){
                                Text(cocktail.name)
                                    .font(.headline)
                                    .bold().multilineTextAlignment(.leading)
                                Text("\(cocktail.type)")
                                    .font(.subheadline)
                                    .foregroundColor(colorScheme == .dark ? .darkGray : .white)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                }
                .frame(width: 150, height: 200)
                .foregroundColor(colorScheme == .dark ? .darkGray : .white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
    }
}

struct UserHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    var user:User
    var body: some View {
        HStack() {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.darkGray, radius: 5, x: 0, y: 2)
                Image(systemName: isMenuOpen ? "xmark.circle" : "house.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isMenuOpen ? colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY : colorScheme == .dark ? .gray : COLOR_SECONDARY)
                    .padding(5)
                    .frame(width: 60, height: 60)
            }
            
            // User Information
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(user.username)!")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(user.email)
                    .font(.caption)
            }.foregroundColor(.white)
                .shadow(color: Color.darkGray, radius: 5, x: 0, y: 2)
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
