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
     
    var body: some View {
        if(!selectedAlcoholTypes.contains(where: { $0.name == item.name })){
            Button(action: {
                onTapped()
            }) {
                VStack(alignment:.leading){
                    if UIImage(named: item.name) != nil {
                        Image(item.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea(.all)
                            .frame(width: 150, height: 200)
                            .clipped()
                    }else{
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea(.all)
                            .frame(width: 150, height: 200)
                            .clipped()
                    }
                    HStack {
                        VStack(alignment: .leading) { // Align text to the leading edge
                            Text(item.name)
                                .font(.footnote)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                        }
                        Spacer()
                        if selectedAlcoholTypes.contains(where: { $0.name == item.name }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .white : COLOR_SECONDARY)
                        }
                    }
                    Text("\(item.type)")
                        .font(.caption2)
                        .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                }.foregroundColor(.white)
                    .frame(width: 150)
            }
        }
    }
}
