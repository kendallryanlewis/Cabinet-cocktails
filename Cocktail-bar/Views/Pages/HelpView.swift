//
//  HelpView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct HelpView: View {
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
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HELP")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Text("Help & Support")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("Learn how to make the most of your cocktail experience")
                            .font(.system(size: 14))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)

                    // Tutorial Button
                    Button(action: { showTutorial = true }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(COLOR_WARM_AMBER.opacity(0.14))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "graduationcap.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(COLOR_WARM_AMBER)
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Interactive Tutorial")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Text("Take a guided tour of all features")
                                    .font(.system(size: 13))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        .padding(16)
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    // Help Sections
                    VStack(alignment: .leading, spacing: 0) {
                        let sections = HelpSection.allCases
                        ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                            HelpSectionCard(
                                section: section,
                                isExpanded: expandedSection == section,
                                isLast: index == sections.count - 1,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedSection = expandedSection == section ? nil : section
                                    }
                                }
                            )
                        }
                    }
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    // Contact & Support
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CONTACT & SUPPORT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            contactRow(icon: "envelope.fill", title: "Email Support", subtitle: "support@cabinetcocktails.com", urlString: "mailto:support@cabinetcocktails.com?subject=Cabinet%20Cocktails%20Support", isLast: false)
                            contactRow(icon: "bubble.left.and.bubble.right.fill", title: "Send Feedback", subtitle: "Help us improve the app", urlString: "mailto:feedback@cabinetcocktails.com?subject=App%20Feedback", isLast: false)
                            contactRow(icon: "exclamationmark.triangle.fill", title: "Report a Bug", subtitle: "Let us know about issues", urlString: "mailto:bugs@cabinetcocktails.com?subject=Bug%20Report", isLast: true)
                        }
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 48)
                }
            }
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
    }

    @ViewBuilder
    private func contactRow(icon: String, title: String, subtitle: String, urlString: String, isLast: Bool) -> some View {
        Button(action: {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(COLOR_WARM_AMBER.opacity(0.14))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)

        if !isLast {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.leading, 66)
        }
    }
}

// MARK: - Help Section Card
struct HelpSectionCard: View {
    let section: HelpView.HelpSection
    let isExpanded: Bool
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(COLOR_WARM_AMBER.opacity(0.14))
                            .frame(width: 36, height: 36)
                        Image(systemName: iconForSection(section))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                    Text(section.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)

                let items = contentForSection(section)
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HelpItemView(item: item, isLast: index == items.count - 1)
                    }
                }
                .padding(.vertical, 4)
            }

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 66)
            }
        }
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
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
                Text(item.description)
                    .font(.system(size: 13))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.leading, 16)
            }
        }
    }
}

#Preview {
    HelpView()
}
