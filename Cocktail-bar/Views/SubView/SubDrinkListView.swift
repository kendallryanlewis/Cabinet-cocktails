//
//  SubDrinkView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/1/24.
//

import SwiftUI
import SwiftUI

struct SubDrinkListView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var drinksByCombination: [String: [String: [DrinkDetails]]]
    @Binding var cocktailList: [DrinkDetails]
    @Binding var showSlider: Bool
    @Binding var popoverSelection: String
    @State private var selectedDrinkDetails: DrinkDetails?
    @State private var expandedSections = Set<String>()

    var body: some View {
        List {
            ForEach(drinksByCombination.keys.sorted(by: { $0.count < $1.count }), id: \.self) { combinationKey in
                Section(
                    header: CustomSectionHeader(
                        title: removeKey(ingredients: combinationKey),
                        isExpanded: expandedSections.contains(combinationKey),
                        onTap: {
                            expandedSections.toggleInsert(combinationKey)
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
                                    DrinkRow(drinkDetail: drinkDetail, colorScheme: colorScheme)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    func removeKey(ingredients: String) -> String {
        let components = ingredients.components(separatedBy: ", ")
        
        let filteredDrinks = components.filter { drink in
            !(drink.contains(components.first!))
        }
        return filteredDrinks.isEmpty ? "Other \(components.first!) Drinks" : filteredDrinks.joined(separator: ", ")
    }
}

struct DrinkRow: View {
    var drinkDetail: DrinkDetails
    var colorScheme: ColorScheme

    var body: some View {
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
}

struct CustomSectionHeader: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var title: String
    var isExpanded: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                    .foregroundColor(isExpanded ? (colorScheme == .dark ? .white : COLOR_SECONDARY) : .secondary)
            }
            .padding(.vertical, 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension Set {
    mutating func toggleInsert(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
