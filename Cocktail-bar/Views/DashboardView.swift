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
    @State private var selection = 0
    @State private var showPopover = false
    @State var popularDrinks: [Ingredient] = []
    @State var randomDrinks: [Ingredient] = []
    @State var latestDrinks: [Ingredient] = []
    
    @Binding var searchText:String
    @State var selectedAlcoholTypes: [DrinkDetails] = []

    var body: some View {
        VStack {
            if(searchText.isEmpty){
                HStack(){
                    Text("Popular Cocktails").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                    Spacer()
                }
                ScrollView(.horizontal){
                    HStack(spacing: 30){
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
                    Text("Latest Cocktails").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                    Spacer()
                }.padding(.top)
                ScrollView(.horizontal){
                    HStack(spacing: 30){
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
                    Text("Random Cocktails").bold().font(.headline).foregroundColor(colorScheme == .light ? .darkGray : .white)
                    Spacer()
                }.padding(.top)
                ScrollView(.horizontal){
                    HStack(spacing: 30){
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
            }
        }
        .sheet(isPresented: $showPopover) {
            if DrinkManager.shared.selectedCocktail != nil {
                DetailsView(cocktail: DrinkManager.shared.selectedCocktail!.name, hideCloseButton: true, dismiss: {})
            } else {
                // Provide a default/fallback view in case 'selectedCocktail' is nil
                Text("No cocktail selected")
            }
        }
        .onAppear(){
            searchPopularCocktails()
        }
    }
    
    //Function to find popular drinks
    func searchPopularCocktails() {
        fetchCocktails(from: "popular") { popularDrinks in
            self.popularDrinks = popularDrinks
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


#Preview {
    MainView()
}
