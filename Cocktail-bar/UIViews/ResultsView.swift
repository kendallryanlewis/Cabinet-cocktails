//
//  ResultsView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/16/24.
//

import SwiftUI

struct ResultsView: View {
    @State var cocktails: [Ingredient]
    @State private var selectedCocktail: Ingredient? = nil
    @State private var isShowingDetail = false
    @Binding var selection:Int
    
    var body: some View {
        VStack {
            // Slideshow
            TabView(selection: $selection)  {
                ForEach(Array(cocktails.enumerated()), id: \.element.id) { index, cocktail in
                    DetailsView(cocktail: cocktail.name, hideCloseButton: true, dismiss: {
                        // Implement dismiss logic here
                    })
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide page indicator
            .frame(maxHeight: .infinity) // Set the height of the slideshow
            .frame(maxWidth: .infinity) // Set the width of the slideshow
            .ignoresSafeArea()
        }.ignoresSafeArea()
    }
}


#Preview {
    MainView()
}
