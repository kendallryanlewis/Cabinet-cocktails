//
//  MixologyView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct MixologyView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @Binding var isMenuOpen: Bool
    @State private var searchTextSpirits = ""
    @State private var selection = 0
    @State private var popoverSelection: String = ""
    @State private var showMore = true
    @State private var drinkDictionary: [String: [String: [DrinkDetails]]] = [:]
    @State private var cocktailList: [DrinkDetails] = []
    @State private var showCartList = false
    @State private var showSlider = false
    @State private var showMyPossibilities = false
    @State private var cocktailDetails: DrinkDetails?
    
    var filteredAlcoholTypes: [Ingredient] {
        DrinkManager.shared.allIngredients?.filter { $0.name.lowercased().contains(searchTextSpirits.lowercased()) } ?? []
    }

    var body: some View {
        ZStack {
            backgroundGradient
            tabView
        }
        .onAppear(perform: DrinkManager.shared.onlyYourIngredients)
        .popover(isPresented: $showSlider, content: sliderPopover)
        .popover(isPresented: $showMyPossibilities, content: possibilitiesPopover)
    }

    private var backgroundGradient: some View {
        VStack(){}.background(
            LinearGradient(gradient: Gradient(colors: colorScheme == .dark ? darkGradient : lightGradient), startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var darkGradient: [Color] {
        Array(repeating: .clear, count: 10) +
        [COLOR_SECONDARY.opacity(0.15), COLOR_SECONDARY.opacity(0.35), COLOR_SECONDARY.opacity(0.5), COLOR_SECONDARY.opacity(0.75), COLOR_SECONDARY.opacity(0.95), COLOR_SECONDARY]
    }

    private var lightGradient: [Color] {
        Array(repeating: .clear, count: 10) +
        [LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.35), LIGHT_LINEAR_BOTTOM.opacity(0.5), LIGHT_LINEAR_BOTTOM.opacity(0.75), LIGHT_LINEAR_BOTTOM.opacity(0.95), LIGHT_LINEAR_BOTTOM]
    }

    private var mixologyHeader: some View {
        VStack(alignment: .center) {
            Text(MIXOLOGY_TEXT).bold().font(.title)
                .foregroundColor(colorScheme == .dark ? .white : .darkGray)
            Text(MIXOLOGY_DESCRIPTION_TEXT)
                .foregroundColor(colorScheme == .dark ? COLOR_SECONDARY : .darkGray).multilineTextAlignment(.center)
        }
    }

    private var cartButton: some View {
        Button(action: {
            showMyPossibilities = DrinkManager.shared.myDrinkPossibilities != nil
        }) {
            HStack {
                Spacer()
                Text(DrinkManager.shared.myDrinkPossibilities != nil ? VIEW_CART : COMBINATION_ERROR).padding()
                Spacer()
            }
        }
        .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
        .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
        .cornerRadius(8)
    }

    private var tabView: some View {
        TabView(selection: $selection) {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                mixologyHeader
                cartButton
            }
            .padding(40)
            ForEach(LocalStorageManager.shared.retrieveTopShelfItems().indices, id: \.self) { index in
                DrinkView(category: LocalStorageManager.shared.retrieveTopShelfItems()[index], drinksByCategory: [:], showMore: $showMore, showSlider: $showSlider, selection: $selection, popoverSelection: $popoverSelection, cocktailList: $cocktailList)
                    .tag(index + 1)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }

    private func sliderPopover() -> some View {
        TabView(selection: $popoverSelection) {
            ForEach(Array(DrinkManager.shared.tempDrinks.enumerated()), id: \.element.id) { index, cocktail in
                DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {}).tag(cocktail.strDrink)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }

    private func possibilitiesPopover() -> some View {
        TabView(selection: $popoverSelection) {
            ForEach(Array(DrinkManager.shared.myDrinkPossibilities!.enumerated()), id: \.element.id) { index, cocktail in
                DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {}).tag(cocktail.strDrink)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
}
