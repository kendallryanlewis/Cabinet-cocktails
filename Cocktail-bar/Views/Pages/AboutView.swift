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
        ZStack {
            LinearGradient(
                gradient: colorScheme == .dark ?
                    Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(COLOR_WARM_AMBER)
                            Text("About")
                                .font(.cocktailTitle)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                        }
                        Text("Your personal bartending companion")
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
                    // App Name Card
                    VStack(spacing: 16) {
                        Text("Cabinet Cocktails")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text("Welcome to Cabinet Cocktails, the innovative iOS app designed to transform your home bartending experience. Whether you're a cocktail aficionado or a newcomer eager to explore the world of mixology, our app is your personal guide to crafting delightful drinks with what you have.")
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(24)
                    .background(COLOR_CHARCOAL)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Features Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("What We Offer")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            AboutFeatureCard(
                                icon: "magnifyingglass.circle.fill",
                                title: "Discover New Cocktails",
                                description: "Explore an extensive database of cocktail recipes from classic favorites to modern concoctions, ensuring there's something for every taste and occasion."
                            )
                            
                            AboutFeatureCard(
                                icon: "star.circle.fill",
                                title: "Personalized Recommendations",
                                description: "Tell us what ingredients you have, and we'll provide a curated list of cocktails you can make without needing to step out for additional supplies."
                            )
                            
                            AboutFeatureCard(
                                icon: "chart.line.uptrend.xyaxis.circle.fill",
                                title: "Expand Your Skills",
                                description: "Discover cocktails that are just one or two ingredients away, helping you gradually build your bar and skills."
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Key Features List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Features")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeaturePoint(icon: "checkmark.circle.fill", text: "Ingredient-based cocktail discovery")
                            FeaturePoint(icon: "checkmark.circle.fill", text: "Detailed recipes and instructions")
                            FeaturePoint(icon: "checkmark.circle.fill", text: "Save your favorite cocktails")
                            FeaturePoint(icon: "checkmark.circle.fill", text: "Track your ingredient cabinet")
                            FeaturePoint(icon: "checkmark.circle.fill", text: "Smart mixology suggestions")
                        }
                    }
                    .padding(20)
                    .background(COLOR_CHARCOAL)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Closing Message
                    VStack(spacing: 8) {
                        Text("Cheers! 🥃")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(COLOR_WARM_AMBER)
                        Text("Thanks for using Cabinet Cocktails. Here's to your next unforgettable cocktail!")
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 60)
                }
            }
        }
    }
}


// MARK: - About Feature Card
struct AboutFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.cardTitle)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                Text(description)
                    .font(.ingredientText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(COLOR_CHARCOAL)
        .cornerRadius(12)
    }
}

struct FeaturePoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(COLOR_WARM_AMBER)
            Text(text)
                .font(.bodyText)
                .foregroundColor(COLOR_TEXT_PRIMARY)
        }
    }
}
