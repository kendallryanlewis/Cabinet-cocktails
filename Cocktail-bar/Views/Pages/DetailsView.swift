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
    let dismiss: () -> Void // Closure to dismiss the sheet
    
    var body: some View {
        ZStack(){
            if let details = cocktailDetails {
                ZStack(){
                    LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                    VStack(){
                        if let imageURLString = details.strDrinkThumb,
                           let imageURL = URL(string: imageURLString) {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300).ignoresSafeArea()
                                default:
                                    Color.clear
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300).ignoresSafeArea()
                                }
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
                                            .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                        if let ingredient1 = details.strIngredient1 {
                                            HStack {
                                                Text("\(details.strMeasure1 ?? "-") \(ingredient1)")
                                            }
                                        }
                                        
                                        if let ingredient2 = details.strIngredient2 {
                                            HStack {
                                                Text("\(details.strMeasure2 ?? "-") \(ingredient2)")
                                            }
                                        }
                                        
                                        if let ingredient3 = details.strIngredient3 {
                                            HStack {
                                                Text("\(details.strMeasure3 ?? "-") \(ingredient3)")
                                            }
                                        }
                                        
                                        if let ingredient4 = details.strIngredient4 {
                                            HStack {
                                                Text("\(details.strMeasure4 ?? "-") \(ingredient4)")
                                            }
                                        }
                                        
                                        if let ingredient5 = details.strIngredient5 {
                                            HStack {
                                                Text("\(details.strMeasure5 ?? "-") \(ingredient5)")
                                            }
                                        }
                                        
                                        if let ingredient6 = details.strIngredient6 {
                                            HStack {
                                                Text("\(details.strMeasure6 ?? "-") \(ingredient6)")
                                            }
                                        }
                                        
                                        if let ingredient7 = details.strIngredient7 {
                                            HStack {
                                                Text("\(details.strMeasure7 ?? "-") \(ingredient7)")
                                            }
                                        }
                                        
                                        if let ingredient8 = details.strIngredient8 {
                                            HStack {
                                                Text("\(details.strMeasure8 ?? "-") \(ingredient8)")
                                            }
                                        }
                                        
                                        if let ingredient9 = details.strIngredient9 {
                                            HStack {
                                                Text("\(details.strMeasure9 ?? "-") \(ingredient9)")
                                            }
                                        }
                                        
                                        if let ingredient10 = details.strIngredient10 {
                                            HStack {
                                                Text("\(details.strMeasure10 ?? "-") \(ingredient10)")
                                            }
                                        }
                                        
                                        if let ingredient11 = details.strIngredient11 {
                                            HStack {
                                                Text("\(details.strMeasure11 ?? "-") \(ingredient11)")
                                            }
                                        }
                                        
                                        if let ingredient12 = details.strIngredient12 {
                                            HStack {
                                                Text("\(details.strMeasure12 ?? "-") \(ingredient12)")
                                            }
                                        }
                                        
                                        if let ingredient13 = details.strIngredient13 {
                                            HStack {
                                                Text("\(details.strMeasure13 ?? "-") \(ingredient13)")
                                            }
                                        }
                                        
                                        if let ingredient14 = details.strIngredient14 {
                                            HStack {
                                                Text("\(details.strMeasure14 ?? "-") \(ingredient14)")
                                            }
                                        }
                                        if let ingredient15 = details.strIngredient15 {
                                            HStack {
                                                Text("\(details.strMeasure15 ?? "-") \(ingredient15)")
                                            }
                                        }
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
            }
        }.ignoresSafeArea()
        .onAppear() {
            self.cocktailDetails = DrinkManager.shared.findDrinkByName(name: cocktail)
            dump(cocktailDetails)
            if LocalStorageManager.shared.retrieveFavoriteItems().contains(where: { $0.name == cocktail }) {
                isFilled = true
            }
        }
        .popover(isPresented: $showDetails) {
            DetailsSubView(cocktailDetails: cocktailDetails!, tagArray: tagArray ?? [])
        }
    }
    
    func addToFavorites(detail: DrinkDetails)-> Ingredient{
        return Ingredient(name: detail.strDrink, image: detail.strDrinkThumb ?? "", type: .alcohol)
    }
    
    func removeFromFavorites() -> Int{
        // Find the index of the Person object with the given name
        if let index = LocalStorageManager.shared.retrieveFavoriteItems().firstIndex(where: { $0.name == cocktail }) {
            return index
        } else {
            return -1
        }
    }
}

struct DetailsSubView: View {
    @State var cocktailDetails: DrinkDetails
    @State var tagArray: [String]
    var body: some View {
        if cocktailDetails.strVideo != nil {
            WebView(urlString: cocktailDetails.strVideo!).frame(height: .infinity)
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


#Preview {
    MainView()
}
