//
//  GenericListView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/15/24.
//

import SwiftUI

struct GenericListView: View {
    var list: [DrinkDetails]
    @Binding var showPopover: Bool
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 30), GridItem(.flexible())], spacing: 30) {
            ForEach(list, id: \.id) { cocktail in
                GeometryReader { geometry in
                    ZStack {
                        VStack {
                            if let imageURL = cocktail.strDrinkThumb, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: 200) // Half of the parent width
                                            .clipped()
                                    default:
                                        Image("GenericAlcohol")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: geometry.size.width, height: 200) // Half of the parent width
                                            .clipped()
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: geometry.size.width, height: 200) // Half of the parent width
                        
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, COLOR_PRIMARY.opacity(0.5), COLOR_PRIMARY]), startPoint: .topTrailing, endPoint: .bottomLeading)
                            VStack {
                                Spacer()
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(cocktail.strDrink)
                                            .font(.headline)
                                            .bold()
                                        Text(cocktail.strCategory ?? "Drink")
                                            .font(.subheadline)
                                            .foregroundColor(LINEAR_BOTTOM)
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                        .frame(width: geometry.size.width, height: 200) // Ensure the overlay fits the same dimensions
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(height: 200)
                .onTapGesture {
                    DrinkManager.shared.selectedCocktail = Ingredient(name: cocktail.strDrink, image: cocktail.strDrinkThumb, type: .alcohol)
                    showPopover = true
                }
            }
        }
    }
}



#Preview {
    MainView()
}
