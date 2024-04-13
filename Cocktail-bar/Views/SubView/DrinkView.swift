//
//  DrinkView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/1/24.
//

import SwiftUI

struct DrinkView: View {
    @Environment(\.colorScheme) var colorScheme
    let category: String
    let drinksByCategory: [String: [DrinkDetails]]
    @Binding var showMore: Bool
    @Binding var showSlider: Bool
    @Binding var selection: Int
    @Binding var popoverSelection: String
    @Binding var cocktailList: [DrinkDetails]
    @State private var drinkCombinations: [String: [String: [DrinkDetails]]]?
    

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack {
                    if UIImage(named: category) != nil {
                        Image(category)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }.opacity(drinkCombinations != nil ? 0.3 : 0.9)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(content: {
                    if(colorScheme == .dark){
                        LinearGradient(colors: [ .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, LINEAR_BOTTOM.opacity(0.05), LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.35), LINEAR_BOTTOM.opacity(0.5), LINEAR_BOTTOM.opacity(0.75), LINEAR_BOTTOM.opacity(0.95), 
                            LINEAR_BOTTOM, LINEAR_BOTTOM,
                            LINEAR_BOTTOM, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                            .allowsHitTesting(false) // Allows clicks to pass through
                    }else{
                        LinearGradient(colors: [ .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, .clear, LIGHT_LINEAR_BOTTOM.opacity(0.05), LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.35), LIGHT_LINEAR_BOTTOM.opacity(0.5), LIGHT_LINEAR_BOTTOM.opacity(0.75), LIGHT_LINEAR_BOTTOM.opacity(0.95), LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                            .allowsHitTesting(false) // Allows clicks to pass through
                    }
                })
            }
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                VStack(spacing: 20) {
                    // Title and description
                    Text("\(category) drinks")
                        .bold()
                        .font(.title)
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                    
                    Text("Create customized cocktails with \(category)")
                        .foregroundColor(colorScheme == .dark ? COLOR_SECONDARY : .darkGray)
                    
                    if(drinkCombinations != nil){
                        SubDrinkListView(drinksByCombination: drinkCombinations!, cocktailList: $cocktailList, showSlider: $showSlider, popoverSelection: $popoverSelection)
                    }
                    // Show more button
                    Button(action: {
                        drinkCombinations = DrinkManager.shared.findDrinksForCombinations(mainIngredient: category)
                        withAnimation {
                            showMore.toggle()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(showMore ? "Viewing \(category) possibilities" : "See What You Can Make")
                                .padding()
                            Spacer()
                        }
                    }
                    .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                    .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
                    .cornerRadius(8)
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 40)
            }
        }
    }
}
