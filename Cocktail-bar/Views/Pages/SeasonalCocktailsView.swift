//
//  SeasonalCocktailsView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct SeasonalCocktailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var seasonalManager = SeasonalCocktailManager.shared
    @StateObject private var drinkManager = DrinkManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    Picker("View Mode", selection: $selectedTab) {
                        Text("Seasonal").tag(0)
                        Text("Holidays").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        SeasonalRecommendationsView()
                            .tag(0)
                        
                        HolidayCocktailsView()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Seasonal Cocktails")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AdaptiveColors.background(for: colorScheme), for: .navigationBar)
        }
    }
}

// MARK: - Seasonal Recommendations View
struct SeasonalRecommendationsView: View {
    @StateObject private var seasonalManager = SeasonalCocktailManager.shared
    @StateObject private var drinkManager = DrinkManager()
    
    var currentSeasonCocktails: [DrinkDetails] {
        seasonalManager.filterCocktailsBySeason(drinkManager.allDrinks ?? [])
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current Season Header
                SeasonHeaderCard(season: seasonalManager.currentSeason)
                    .padding(.horizontal, 20)
                
                // Season Description
                if let recommendation = seasonalManager.seasonalRecommendations[seasonalManager.currentSeason] {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Flavors")
                            .font(.headline)
                        
                        Text(recommendation.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Flavor Tags
                        FlavorTagsView(flavors: recommendation.flavors)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                // Seasonal Cocktails
                VStack(alignment: .leading, spacing: 12) {
                    Text("Perfect for \(seasonalManager.currentSeason.rawValue)")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    if currentSeasonCocktails.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "leaf")
                                .font(.iconMedium)
                                .foregroundColor(.gray)
                            
                            Text("No seasonal cocktails found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(currentSeasonCocktails.prefix(10)) { cocktail in
                                    NavigationLink(destination: DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {})) {
                                        SeasonalCocktailCard(cocktail: cocktail)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                // All Seasons
                ForEach(Season.allCases.filter { $0 != seasonalManager.currentSeason }, id: \.self) { season in
                    let seasonCocktails = seasonalManager.filterCocktailsBySeason(drinkManager.allDrinks ?? [])
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: season.icon)
                                .foregroundColor(seasonColor(season))
                            
                            Text(season.rawValue)
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        
                        if !seasonCocktails.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(seasonCocktails.prefix(10)) { cocktail in
                                        NavigationLink(destination: DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {})) {
                                            SeasonalCocktailCard(cocktail: cocktail)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    func seasonColor(_ season: Season) -> Color {
        switch season {
        case .spring: return .green
        case .summer: return .orange
        case .fall: return .brown
        case .winter: return .blue
        }
    }
}

// MARK: - Season Header Card
struct SeasonHeaderCard: View {
    let season: Season
    
    var body: some View {
        HStack {
            Image(systemName: season.icon)
                .font(.displayMedium)
                .foregroundColor(seasonColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Season")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(season.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [seasonColor.opacity(0.2), seasonColor.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    var seasonColor: Color {
        switch season {
        case .spring: return .green
        case .summer: return .orange
        case .fall: return .brown
        case .winter: return .blue
        }
    }
}

// MARK: - Flavor Tags View
struct FlavorTagsView: View {
    let flavors: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(flavors, id: \.self) { flavor in
                    Text(flavor)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Seasonal Cocktail Card
struct SeasonalCocktailCard: View {
    let cocktail: DrinkDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            AsyncImage(url: URL(string: cocktail.strDrinkThumb ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 150, height: 150)
            .cornerRadius(12)
            .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.strDrink)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(cocktail.strCategory ?? "Cocktail")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 150, alignment: .leading)
        }
    }
}

// MARK: - Holiday Cocktails View
struct HolidayCocktailsView: View {
    @StateObject private var seasonalManager = SeasonalCocktailManager.shared
    @StateObject private var drinkManager = DrinkManager()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Upcoming Holidays
                if !seasonalManager.upcomingHolidays.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Holidays")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        ForEach(seasonalManager.upcomingHolidays, id: \.self) { holiday in
                            HolidaySection(holiday: holiday)
                        }
                    }
                }
                
                // All Holidays
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Holidays")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    ForEach(Holiday.allCases.filter { !seasonalManager.upcomingHolidays.contains($0) }, id: \.self) { holiday in
                        HolidaySection(holiday: holiday)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Holiday Section
struct HolidaySection: View {
    @StateObject private var seasonalManager = SeasonalCocktailManager.shared
    @StateObject private var drinkManager = DrinkManager()
    let holiday: Holiday
    
    var holidayCocktails: [DrinkDetails] {
        seasonalManager.filterCocktailsByHoliday(drinkManager.allDrinks ?? [], holiday: holiday)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: holiday.icon)
                    .foregroundColor(.purple)
                
                Text(holiday.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(holidayCocktails.count) drinks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            if !holidayCocktails.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(holidayCocktails.prefix(10)) { cocktail in
                            NavigationLink(destination: DetailsView(cocktail: cocktail.strDrink, hideCloseButton: true, dismiss: {})) {
                                SeasonalCocktailCard(cocktail: cocktail)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            } else {
                Text("No cocktails found for this holiday")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }
}
