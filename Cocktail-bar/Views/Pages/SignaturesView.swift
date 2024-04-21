//
//  SignaturesView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/18/24.
//

import SwiftUI

struct SignaturesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    @Binding var viewPage: pages
    @State private var searchTextSpirits = ""
    // State variable to store the selected alcohol types
    @State var selectedAlcoholTypes: [String] = []
    @State var searchResults: [Ingredient] = []
    @State var showCartList = false
    @State var showSearch = true
    @State var selection = 0
       
    var body: some View {
        ZStack(){
            VStack(){
                if(DrinkManager.shared.signatureCocktails.count != 0){
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
                }else{
                    ZStack{
                        GeometryReader { geometry in
                            Image("emptyBar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .ignoresSafeArea()
                        }
                        .ignoresSafeArea()
                        VStack{
                            Spacer()
                            Text("You currently have no saved drinks.")
                                .foregroundColor(.white).font(.headline)
                            Button(action: {
                                withAnimation {
                                    viewPage = .mixology
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("View Mixology")
                                        .padding()
                                    Spacer()
                                }
                            }
                            .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                            .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)
                            .cornerRadius(8)
                        }.padding(40)
                            .shadow(color: Color.darkGray, radius: 5, x: 0, y: 2)
                    }
                }
            }.background(colorScheme == .dark ? LINEAR_BOTTOM : LIGHT_LINEAR_BOTTOM)
        }
    }
}
