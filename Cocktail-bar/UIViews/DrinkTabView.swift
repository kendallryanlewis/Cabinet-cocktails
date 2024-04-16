//
//  DrinkTabView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/21/24.
//

import SwiftUI

struct DrinkTabView: View {
    @State var cocktail: Ingredient
    
    var body: some View {
        ZStack(){
            HStack {
                if let imageURL = cocktail.image {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipped()
                        default:
                            Color.black
                        }
                    }
                }
                Spacer()
            }
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.25), .black, .black, .black, .black.opacity(0.75), .black.opacity(0.5), .black.opacity(0.25), .clear]), startPoint: .leading, endPoint: .trailing)
            HStack{
                VStack(alignment:.leading){
                    Spacer()
                    Text(cocktail.name)
                        .font(.headline)
                        .bold()
                    Text("\(cocktail.type)")
                        .font(.subheadline)
                        .foregroundColor(COLOR_PRIMARY)
                }.foregroundColor(.white)
                Spacer()
            }.padding()
        }.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct HeadlinerTabView: View {
    @State var cocktail: Ingredient
    @State private var selectedCocktail: Ingredient? = nil
    @State private var isShowingDetail = false
    
    var body: some View {
        ZStack {
            VStack {
                AsyncImage(url: URL(string:cocktail.image!) ) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea(.all)
                            .frame(width: 150, height: 200)
                            .clipped()
                    default:
                        Color.gray
                    }
                }
            }.frame(width: 150, height: 200)
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.5), .black.opacity(0.75), COLOR_SECONDARY]), startPoint: .topTrailing, endPoint: .bottomLeading)
                VStack {
                    Spacer()
                    HStack() {
                        VStack(alignment:.leading){
                            Text(cocktail.name)
                                .font(.headline)
                                .bold()
                        }
                        Spacer()
                    }
                }
                .padding()
            }
            .frame(width: 150, height: 200)
            .foregroundColor(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
