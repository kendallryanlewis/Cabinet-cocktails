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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible())], spacing: 20) {
            ForEach(list, id: \.id) { cocktail in
                GeometryReader { geometry in
                    ZStack {
                        // Background card
                        RoundedRectangle(cornerRadius: 12)
                            .fill(COLOR_CHARCOAL_LIGHT)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 0) {
                            // Image with cached loading
                            if let imageURL = cocktail.strDrinkThumb, let url = URL(string: imageURL) {
                                CachedAsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width, height: 150)
                                        .clipped()
                                } placeholder: {
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        SwiftUI.ProgressView()
                                            .tint(COLOR_WARM_AMBER)
                                    }
                                    .frame(width: geometry.size.width, height: 150)
                                }
                                .frame(height: 150)
                            }
                            
                            // Content overlay with gradient
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .clear,
                                        .clear,
                                        COLOR_CHARCOAL.opacity(0.7),
                                        COLOR_CHARCOAL.opacity(0.95)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Spacer()
                                    Text(cocktail.strDrink)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                        .lineLimit(2)
                                    
                                    Text(cocktail.strCategory ?? "Cocktail")
                                        .font(.caption)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 80)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(height: 230)
                .onTapGesture {
                    DrinkManager.shared.selectedCocktail = Ingredient(name: cocktail.strDrink, image: cocktail.strDrinkThumb, type: .alcohol)
                    showPopover = true
                }
            }
        }
        .padding(.horizontal, 16)
    }
}



#Preview {
    MainView()
}
