//
//  CabinetView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/10/24.
//

import SwiftUI

struct CabinetView: View {
    var onTapped: () -> Void  // Pass action directly
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchTextSpirits: String
    @Binding var selectedAlcoholTypes: [Ingredient]
    var item: Ingredient
    
    private var isInCabinet: Bool {
        selectedAlcoholTypes.contains(where: { $0.name == item.name })
    }
     
    var body: some View {
        Button(action: {
            onTapped()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Image with overlay indicator
                ZStack(alignment: .topTrailing) {
                    if UIImage(named: item.name) != nil {
                        Image(item.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 200)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 200)
                            .clipped()
                            .cornerRadius(12)
                    }
                    
                    // Cabinet status indicator
                    if isInCabinet {
                        ZStack {
                            Circle()
                                .fill(COLOR_CHARCOAL_LIGHT)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(COLOR_WARM_AMBER)
                                .font(.cocktailTitle)
                        }
                        .padding(8)
                    }
                }
                
                // Text info
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.ingredientText)
                            .fontWeight(.semibold)
                            .foregroundColor(isInCabinet ? COLOR_TEXT_PRIMARY : COLOR_TEXT_SECONDARY)
                            .lineLimit(2)
                        
                        Text("\(item.type)")
                            .font(.caption)
                            .foregroundColor(isInCabinet ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                    }
                    
                    Spacer()
                    
                    // Action indicator
                    if !isInCabinet {
                        Image(systemName: "plus.circle")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .font(.navTitle)
                    }
                }
            }
            .frame(width: 150)
        }
    }
}
