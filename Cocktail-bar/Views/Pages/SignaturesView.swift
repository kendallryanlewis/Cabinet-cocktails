//
//  SignaturesView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct SignaturesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var searchTextSpirits = ""
    // State variable to store the selected alcohol types
    @State var selectedAlcoholTypes: [String] = []
    @State var searchResults: [Ingredient] = []
    @State var showCartList = false
    @State var showSearch = true
    @State var selection = 0
       
    var body: some View {
        ZStack(){
            GenericBackground()
            VStack(){
                ResultsView(cocktails: DrinkManager.shared.signatureCocktails, selection: $selection)
                HStack(){
                    ForEach(DrinkManager.shared.signatureCocktails.indices, id: \.self) { index in
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 0.5)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(selection == index ? colorScheme == .dark ? Color.white : COLOR_SECONDARY : Color.clear)
                                .frame(width: 3, height: 3)
                            }
                        .onTapGesture {
                            selection = index // Change the selection when the user taps an indicator
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SignaturesView()
}
