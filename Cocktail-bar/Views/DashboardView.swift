//
//  DashboardView.swift
//  Cabinet Cocktails
//
//  Created by Kendall Lewis on 10/11/23.
//

import SwiftUI

// MARK: - Dashboard / Discover Screen

struct DashboardView: View {
    @State private var popularDrinks: [Ingredient] = []
    @State private var currentPage = 0
    @State private var selectedCocktail: Ingredient? = nil

    var featuredDrinks: [Ingredient] { Array(popularDrinks.prefix(5)) }

    // Cocktails the user can make from their saved cabinet
    var cabinetCocktails: [DrinkDetails] {
        DrinkManager.shared.myDrinkPossibilities ?? []
    }

    var body: some View {
        ZStack(alignment: .top) {
            COLOR_BACKGROUND.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Hero Pager ──────────────────────────────────────────
                    ZStack(alignment: .bottomTrailing) {
                        if featuredDrinks.isEmpty {
                            // Skeleton / loading state
                            ZStack {
                                COLOR_CHARCOAL
                                SwiftUI.ProgressView().tint(COLOR_WARM_AMBER).scaleEffect(1.4)
                            }
                            .frame(height: UIScreen.main.bounds.height * 0.62)
                        } else {
                            TabView(selection: $currentPage) {
                                ForEach(Array(featuredDrinks.enumerated()), id: \.offset) { index, cocktail in
                                    FeaturedHeroCard(cocktail: cocktail)
                                        .tag(index)
                                        .contentShape(Rectangle())
                                        .onTapGesture { selectedCocktail = cocktail }
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(height: UIScreen.main.bounds.height * 0.62)
                        }

                        // ── Custom page dots (active = ringed dot) ──────────
                        if featuredDrinks.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(0..<featuredDrinks.count, id: \.self) { index in
                                    if index == currentPage {
                                        ZStack {
                                            Circle()
                                                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                                                .frame(width: 16, height: 16)
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 5, height: 5)
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.35))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }

                    // ── From Your Cabinet ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FROM YOUR CABINET")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            Text(cabinetCocktails.isEmpty
                                 ? "Add ingredients to see matches"
                                 : "\(cabinetCocktails.count) cocktail\(cabinetCocktails.count == 1 ? "" : "s") ready to make")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        if cabinetCocktails.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "cabinet")
                                    .font(.system(size: 36))
                                    .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.4))
                                Text("Your cabinet is empty")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                Text("Add spirits and mixers to discover cocktails you can make right now.")
                                    .font(.system(size: 13))
                                    .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                ForEach(cabinetCocktails) { cocktail in
                                    QuickMixCocktailCard(cocktail: cocktail) {
                                        selectedCocktail = Ingredient(name: cocktail.strDrink, image: cocktail.strDrinkThumb, type: .alcohol)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 100)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(item: $selectedCocktail) { cocktail in
            DetailsView(cocktail: cocktail.name, hideCloseButton: true, dismiss: { selectedCocktail = nil })
        }
        .onAppear { loadCocktails() }
    }

    // MARK: Networking

    private func loadCocktails() {
        fetchCocktails(from: "popular") { self.popularDrinks = $0 }
        // Compute cabinet matches after ensuring allDrinks is loaded
        if DrinkManager.shared.allDrinks == nil {
            Task {
                await DrinkManager.shared.fetchAllDrinks()
                DrinkManager.shared.onlyYourIngredients()
            }
        } else {
            DrinkManager.shared.onlyYourIngredients()
        }
    }

    private func fetchCocktails(from endpoint: String, completion: @escaping ([Ingredient]) -> Void) {
        guard let url = URL(string: "\(API_URL)/\(endpoint).php") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            if let response = try? JSONDecoder().decode(CocktailDBResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(response.drinks.compactMap {
                        Ingredient(name: $0.strDrink, image: $0.strDrinkThumb, type: .alcohol)
                    })
                }
            }
        }.resume()
    }
}

// MARK: - Featured Hero Card

struct FeaturedHeroCard: View {
    let cocktail: Ingredient

    // Seeded values for consistent strength/likes per drink name
    private var strengthDots: Int { max(1, min(5, abs(cocktail.name.hashValue % 5) + 1)) }
    private var strengthLabel: String {
        ["Mild", "Light", "Medium", "Strong", "Bold"][strengthDots - 1]
    }
    private var likesCount: Int { abs(cocktail.name.hashValue % 1800) + 200 }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed image
            GeometryReader { geo in
                if let rawURL = cocktail.image, let url = URL(string: rawURL) {
                    CachedAsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ZStack {
                            COLOR_CHARCOAL
                            SwiftUI.ProgressView().tint(COLOR_WARM_AMBER)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                } else {
                    COLOR_CHARCOAL.frame(width: geo.size.width, height: geo.size.height)
                }
            }

            // Dark gradient overlay — light at top, heavy toward bottom
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.2), Color.black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Text content pinned to bottom-left
            VStack(alignment: .leading, spacing: 0) {
                Text("Featured Recipes".uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .kerning(1.5)
                    .padding(.bottom, 10)

                Text(cocktail.name)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.bottom, 16)

                // Strength dots + label  ·  Likes
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < strengthDots
                                      ? COLOR_TEXT_PRIMARY
                                      : COLOR_TEXT_PRIMARY.opacity(0.22))
                                .frame(width: 7, height: 7)
                        }
                    }
                    Text(strengthLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(COLOR_TEXT_SECONDARY)

                    Spacer()

                    HStack(spacing: 5) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13))
                            .foregroundColor(COLOR_WARM_AMBER)
                        Text("\(likesCount)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48) // leave space above page dots overlay
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipped()
    }
}

// MARK: - Today Recipe Card  (2-col grid)

struct TodayRecipeCard: View {
    let cocktail: Ingredient

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let rawURL = cocktail.image, let url = URL(string: rawURL) {
                CachedAsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        COLOR_CHARCOAL_LIGHT
                        SwiftUI.ProgressView().tint(COLOR_WARM_AMBER)
                    }
                }
                .frame(height: 200)
                .clipped()
            } else {
                COLOR_CHARCOAL_LIGHT.frame(height: 200)
            }

            LinearGradient(
                colors: [.clear, .clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.type.rawValue.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
                    .kerning(0.8)
                Text(cocktail.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .frame(height: 200)
        .cornerRadius(14)
        .clipped()
    }
}

#Preview {
    DashboardView()
        .environmentObject(SessionStore())
        .environmentObject(SystemSettingsManager())
        .environmentObject(PremiumManager())
}
