//
//  TutorialView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
    @State private var currentPage = 0
    
    let pages: [TutorialPage] = [
        TutorialPage(
            icon: "house.fill",
            title: "Welcome to Cocktail Cabinet",
            description: "Your personal bartender in your pocket. Discover, create, and enjoy thousands of cocktail recipes.",
            color: Color(hex: "D4A574")
        ),
        TutorialPage(
            icon: "cabinet.fill",
            title: "Build Your Cabinet",
            description: "Add the spirits, mixers, and ingredients you have at home. We'll show you what cocktails you can make!",
            color: Color.blue
        ),
        TutorialPage(
            icon: "magnifyingglass",
            title: "Discover & Search",
            description: "Browse thousands of recipes, search by name or ingredient, and filter by your preferences.",
            color: Color.green
        ),
        TutorialPage(
            icon: "wand.and.stars",
            title: "Quick Mix",
            description: "Select multiple ingredients to instantly see all cocktails you can make with what you have.",
            color: Color.purple
        ),
        TutorialPage(
            icon: "heart.fill",
            title: "Save Your Favorites",
            description: "Mark cocktails as favorites, create custom collections, and organize recipes for any occasion.",
            color: Color.red
        ),
        TutorialPage(
            icon: "list.clipboard.fill",
            title: "Step-by-Step Instructions",
            description: "Get detailed mixing instructions with timers, batch calculations, and ingredient substitutions.",
            color: Color.orange
        ),
        TutorialPage(
            icon: "calendar.badge.clock",
            title: "Seasonal Suggestions",
            description: "Discover cocktails perfect for the current season, upcoming holidays, and special occasions.",
            color: Color.teal
        ),
        TutorialPage(
            icon: "checkmark.circle.fill",
            title: "You're All Set!",
            description: "Start exploring, mixing, and enjoying amazing cocktails. Tap 'Get Started' to begin your journey.",
            color: Color(hex: "D4A574")
        )
    ]
    
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
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                
                // Tutorial Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        TutorialPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page Indicator & Navigation
                VStack(spacing: 20) {
                    // Custom Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? COLOR_WARM_AMBER : Color.gray.opacity(0.3))
                                .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                hasCompletedTutorial = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            HStack {
                                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                if currentPage < pages.count - 1 {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Tutorial Page Model
struct TutorialPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Tutorial Page View
struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    TutorialView()
}
