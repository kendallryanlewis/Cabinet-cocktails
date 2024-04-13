//
//  SubDrinkView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/1/24.
//

import SwiftUI

struct SubDrinkListView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var drinksByCombination: [String: [String: [DrinkDetails]]]
    @Binding var cocktailList: [DrinkDetails]
    @Binding var showSlider: Bool
    @Binding var popoverSelection: String
    @State private var selectedDrinkDetails: DrinkDetails? // Use this to store selected drink details
    @State private var expandedSections = Set<String>()
    

    var body: some View {
        List {
            ForEach(drinksByCombination.keys.sorted(by: { $0.count < $1.count }), id: \.self) { combinationKey in
                Section(
                    header: CustomSectionHeader(
                        title: removeKey(ingredients: combinationKey),
                        isExpanded: expandedSections.contains(combinationKey), // Pass the expanded state
                        onTap: {
                            // Toggle section state
                            if expandedSections.contains(combinationKey) {
                                expandedSections.remove(combinationKey)
                            } else {
                                expandedSections.insert(combinationKey)
                            }
                        }
                    )
                ) {
                    if expandedSections.contains(combinationKey) {
                        ForEach(drinksByCombination[combinationKey]?.keys.sorted() ?? [], id: \.self) { categoryKey in
                            ForEach(drinksByCombination[combinationKey]?[categoryKey] ?? [], id: \.id) { drinkDetail in
                                Button(action: {
                                    self.selectedDrinkDetails = drinkDetail
                                    self.popoverSelection = drinkDetail.strDrink
                                    self.cocktailList = DrinkManager.shared.tempDrinks
                                    showSlider = true
                                }) {
                                    HStack {
                                        Text(drinkDetail.strDrink)
                                        Spacer()
                                        Image(systemName: "chevron.right.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                            .padding(5)
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .padding(.horizontal, -10)
                                .listRowSpacing(10)
                            }
                        }
                    }
                }
            }
        }
        //.scrollIndicatorsEnabled(false)
        .listStyle(PlainListStyle())
    }
    
    func removeKey(ingredients: String) -> String{
        // Split the string into an array by commas
        var components = ingredients.components(separatedBy: ", ")
        let key = components[0]
        // Check if there are any elements to remove
        if !components.isEmpty {
            components.removeFirst() // Remove the first element
        }
        return components.count == 0 ? "All \(key) Drinks" : components.joined(separator: ", ")
    }
}

struct CustomSectionHeader: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var title: String
    var isExpanded: Bool // Add this
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                    .foregroundColor(isExpanded ? colorScheme == .dark ? .white : COLOR_SECONDARY : .secondary)
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid button-like appearance
        .padding(.horizontal, -15)
    }
}
