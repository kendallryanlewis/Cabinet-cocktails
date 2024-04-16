//
//  AboutView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/5/24.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    var body: some View {
        ZStack(){
            VStack(alignment: .leading, spacing:30){
                Text("Cabinet Cocktails")
                    .bold()
                    .font(.title)
                    .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                    .padding(.leading, 40)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Welcome to Cabinet Cocktails, the innovative iOS app designed to transform your home bartending experience. Whether you're a cocktail aficionado or a newcomer eager to explore the world of mixology, our app is your personal guide to crafting delightful drinks with ingredients you already have at home or even those you're looking to experiment with.")
                        
                        SectionHeader(title: "Discover New Cocktails")
                        
                        Text("Cabinet Cocktails is built on the idea that making cocktails should be fun, accessible, and creative. Our extensive database features a wide range of cocktail recipes from classic favorites to modern concoctions, ensuring there's something for every taste and occasion.")
                        
                        SectionHeader(title: "Personalized Recommendations")
                        
                        Text("Tell us what ingredients you have in your bar or kitchen, and our app will provide a curated list of cocktail recipes you can make without needing to step out for additional supplies.")
                        
                        SectionHeader(title: "Explore With or Without")
                        
                        Text("Not only does our app allow you to discover cocktails based on the ingredients you possess, but it also introduces you to the world of cocktails that are just a few ingredients away.")
                        
                        SectionHeader(title: "Features at a Glance:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeaturePoint(text: "Ingredient-Based Cocktail Discovery: Enter your available ingredients and find out what cocktails you can create.")
                            FeaturePoint(text: "Expand Your Cocktail Repertoire: Get suggestions for cocktails that require one or two additional ingredients.")
                            FeaturePoint(text: "Detailed Recipes and Instructions: Each cocktail comes with detailed preparation instructions.")
                            FeaturePoint(text: "Save Your Favorites: Keep track of the cocktails you love.")
                            FeaturePoint(text: "Learn and Experiment: Learn about new ingredients, cocktail history, and mixing techniques.")
                        }
                        
                        Text("Thanks for downloading the Cabinet Cocktails today and start mixing like a pro! Cheers to your next unforgettable cocktail.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 40)
                }
            }.padding(.vertical, 40)
        }
    }
}


struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.top)
    }
}

struct FeaturePoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
