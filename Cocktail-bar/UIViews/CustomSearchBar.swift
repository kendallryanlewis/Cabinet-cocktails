//
//  CustomSearchBar.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/15/24.
//

import SwiftUI

struct CustomSearchBar: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText: String
    @Binding var showSearchField: Bool
    @State var selectedAlcoholTypes: [DrinkDetails]
    
    var body: some View {
        ZStack(alignment: .leading) {
            if searchText.isEmpty {
                Text(SEARCH_TEXT)
                    .foregroundColor(COLOR_PRIMARY) // Change placeholder color here
                    .padding(.horizontal, 10)
            }
            HStack {
                TextField("", text: $searchText)
                    .foregroundColor(.white)
                    .background(Color.clear)
                if(selectedAlcoholTypes.isEmpty){
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(COLOR_PRIMARY).bold()
                }else{
                    Button(action: {
                        clearCart()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                }
            }
            .padding(10)
        } .background(colorScheme == .dark ? .white.opacity(0.5) : COLOR_SECONDARY).cornerRadius(8)
        .onTapGesture {
            // Perform action when the search field is clicked
            showSearchField = true
        }
    }
    func clearCart(){
        
    }
}


#Preview {
    MainView()
}
