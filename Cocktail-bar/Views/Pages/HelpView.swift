//
//  HelpView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showTutorial = false
    @State private var expandedSection: HelpSection? = nil
    
    enum HelpSection: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case quickMix = "Quick Mix"
        case favorites = "Favorites & Collections"
        case features = "Advanced Features"
        case troubleshooting = "Troubleshooting"
    }
    
    var body: some View {
        NavigationView {
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
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Help & Support")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Text("Learn how to make the most of your cocktail experience")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Tutorial Button
                        Button(action: { showTutorial = true }) {
                            HStack {
                                Image(systemName: "graduationcap.fill")
                                    .font(.title2)
                                    .foregroundColor(COLOR_WARM_AMBER)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Interactive Tutorial")
                                        .font(.headline)
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                    
                                    Text("Take a guided tour of all features")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // Help Sections
                        ForEach(HelpSection.allCases, id: \.self) { section in
                            HelpSectionCard(
                                section: section,
                                isExpanded: expandedSection == section,
                                onTap: {
                                    withAnimation {
                                        expandedSection = expandedSection == section ? nil : section
                                    }
                                }
                            )
                        }
                        
                        // Contact Support
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contact & Support")
                                .font(.title2.bold())
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Text("We're here to help! Choose your preferred way to reach us.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Email Support
                            Button(action: {
                                if let url = URL(string: "mailto:support@cocktailapp.com?subject=Cocktail%20App%20Support") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.title3)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Email Support")
                                            .font(.headline)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Text("support@cocktailapp.com")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                            
                            // Feedback
                            Button(action: {
                                if let url = URL(string: "mailto:feedback@cocktailapp.com?subject=App%20Feedback") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .font(.title3)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Send Feedback")
                                            .font(.headline)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Text("Help us improve the app")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                            
                            // Report Bug
                            Button(action: {
                                if let url = URL(string: "mailto:bugs@cocktailapp.com?subject=Bug%20Report") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title3)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Report a Bug")
                                            .font(.headline)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Text("Let us know about issues")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTutorial) {
                TutorialView()
            }
        }
    }
}

// MARK: - Help Section Card
struct HelpSectionCard: View {
    let section: HelpView.HelpSection
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Image(systemName: iconForSection(section))
                        .font(.title3)
                        .foregroundColor(COLOR_WARM_AMBER)
                        .frame(width: 30)
                    
                    Text(section.rawValue)
                        .font(.headline)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(contentForSection(section), id: \.title) { item in
                        HelpItemView(item: item)
                    }
                }
                .padding()
                .background(COLOR_CHARCOAL.opacity(0.5))
            }
        }
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    func iconForSection(_ section: HelpView.HelpSection) -> String {
        switch section {
        case .gettingStarted: return "play.circle.fill"
        case .quickMix: return "wand.and.stars"
        case .favorites: return "heart.fill"
        case .features: return "star.fill"
        case .troubleshooting: return "wrench.and.screwdriver.fill"
        }
    }
    
    func contentForSection(_ section: HelpView.HelpSection) -> [HelpItem] {
        switch section {
        case .gettingStarted:
            return [
                HelpItem(title: "Add Your Ingredients", description: "Tap the cabinet icon and add the spirits and mixers you have at home."),
                HelpItem(title: "Browse Cocktails", description: "Explore thousands of cocktail recipes from the home screen."),
                HelpItem(title: "Find What You Can Make", description: "The app automatically shows cocktails you can make with your ingredients.")
            ]
        case .quickMix:
            return [
                HelpItem(title: "Select Ingredients", description: "Go to the Quick Mix tab and select ingredients you want to use."),
                HelpItem(title: "View Matches", description: "See all cocktails that use your selected ingredients."),
                HelpItem(title: "Filter Results", description: "Use filters to narrow down by category, glass type, or alcoholic content.")
            ]
        case .favorites:
            return [
                HelpItem(title: "Mark as Favorite", description: "Tap the heart icon on any cocktail to save it to your favorites."),
                HelpItem(title: "Create Collections", description: "Organize cocktails into custom collections for different occasions."),
                HelpItem(title: "Add to Signature Drinks", description: "Save your go-to cocktails for quick access from the menu.")
            ]
        case .features:
            return [
                HelpItem(title: "Step-by-Step Instructions", description: "Get detailed mixing instructions with timers for each cocktail."),
                HelpItem(title: "Batch Calculator", description: "Scale recipes up for parties or down for single servings."),
                HelpItem(title: "Ingredient Substitutions", description: "Find alternative ingredients when you're missing something."),
                HelpItem(title: "Cost Tracking", description: "Track the cost of ingredients and cocktails."),
                HelpItem(title: "Seasonal Recommendations", description: "Discover cocktails perfect for the current season or upcoming holidays.")
            ]
        case .troubleshooting:
            return [
                HelpItem(title: "Cocktails Not Loading", description: "Check your internet connection. The app requires connectivity to fetch new recipes."),
                HelpItem(title: "Ingredients Not Saving", description: "Make sure you've granted the app storage permissions in your device settings."),
                HelpItem(title: "Search Not Working", description: "Try clearing your search filters or restarting the app."),
                HelpItem(title: "Images Not Displaying", description: "Images may take a moment to load. Check your connection or try again later.")
            ]
        }
    }
}

// MARK: - Help Item
struct HelpItem {
    let title: String
    let description: String
}

struct HelpItemView: View {
    let item: HelpItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(COLOR_WARM_AMBER)
            
            Text(item.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    HelpView()
}
