//
//  DrinkTabView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/21/24.
//

import SwiftUI

struct DrinkTabView: View {
    @State var cocktail: Ingredient
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 12)
                .fill(COLOR_CHARCOAL_LIGHT)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            
            HStack(spacing: 16) {
                // Image
                if let imageURL = cocktail.image {
                    CachedAsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(COLOR_CHARCOAL)
                            SwiftUI.ProgressView()
                                .tint(COLOR_WARM_AMBER)
                        }
                        .frame(width: 80, height: 80)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(cocktail.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .lineLimit(2)
                    
                    Text(cocktail.type.rawValue)
                        .font(.caption)
                        .foregroundColor(COLOR_WARM_AMBER)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .font(.system(size: 14))
            }
            .padding(12)
        }
        .frame(height: 104)
    }
}

struct HeadlinerTabView: View {
    @State var cocktail: Ingredient
    @State private var selectedCocktail: Ingredient? = nil
    @State private var isShowingDetail = false
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 12)
                .fill(COLOR_CHARCOAL_LIGHT)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 0) {
                // Image
                CachedAsyncImage(url: URL(string: cocktail.image!)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        SwiftUI.ProgressView()
                            .tint(COLOR_WARM_AMBER)
                    }
                    .frame(width: 150, height: 150)
                }
                
                // Text overlay with gradient
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            COLOR_CHARCOAL.opacity(0.6),
                            COLOR_CHARCOAL.opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(cocktail.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .lineLimit(2)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 50)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(width: 150, height: 200)
    }
}
