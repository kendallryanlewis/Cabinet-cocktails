//
//  HistoryView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @State private var selectedPeriod: TimePeriod = .allTime
    @State private var searchText = ""
    @State private var showStatistics = false
    @State private var showClearConfirmation = false
    @State private var selectedDrink: DrinkDetails?
    
    var filteredHistory: [CocktailHistoryItem] {
        let periodFiltered = historyManager.getHistory(for: selectedPeriod)
        
        if searchText.isEmpty {
            return periodFiltered
        } else {
            return historyManager.searchHistory(query: searchText).filter { item in
                periodFiltered.contains(where: { $0.id == item.id })
            }
        }
    }
    
    var groupedHistory: [(date: Date, items: [CocktailHistoryItem])] {
        historyManager.groupedByDate(filteredHistory)
    }
    
    private var backgroundGradient: some View {
        AppBackground()
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerTopSection
            searchBar
            periodFilters
        }
        .padding()
    }
    
    private var headerTopSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("History")
                    .font(.cocktailTitle)
                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                
                Text("\(historyManager.historyItems.count) cocktail\(historyManager.historyItems.count == 1 ? "" : "s") made")
                    .font(.bodyText)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
            
            Spacer()
            
            Button(action: { showStatistics = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.iconMini)
                        .foregroundColor(COLOR_WARM_AMBER)
                    
                    Text("Stats")
                        .font(.caption)
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            
            TextField("Search history", text: $searchText)
                .font(.bodyText)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                .tint(COLOR_WARM_AMBER)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(12)
        .background(AdaptiveColors.cardBackground(for: colorScheme))
        .cornerRadius(12)
    }
    
    private var periodFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodFilterButton(
                        title: period.rawValue,
                        isSelected: selectedPeriod == period,
                        count: historyManager.getHistory(for: period).count,
                        action: { selectedPeriod = period }
                    )
                }
            }
        }
    }
    
    private var historyContent: some View {
        Group {
            if filteredHistory.isEmpty {
                emptyFilteredView
            } else {
                historyListView
            }
        }
    }
    
    private var emptyFilteredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.iconMedium)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            
            Text("No cocktails found")
                .font(.bodyText)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            
            Button(action: {
                searchText = ""
                selectedPeriod = .allTime
            }) {
                Text("Clear Filters")
                    .font(.bodyText)
                    .foregroundColor(COLOR_WARM_AMBER)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var historyListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(groupedHistory, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(sectionTitle(for: group.date))
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .padding(.horizontal, 20)
                        
                        ForEach(group.items) { item in
                            HistoryItemCard(
                                item: item,
                                onTap: {
                                    if let drink = DrinkManager.shared.allDrinks?.first(where: { $0.idDrink == item.drinkId }) {
                                        selectedDrink = drink
                                    }
                                },
                                onDelete: {
                                    historyManager.deleteHistoryItem(item)
                                }
                            )
                        }
                    }
                }
                
                Button(action: {
                    showClearConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All History")
                    }
                    .font(.bodyText)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AdaptiveColors.cardBackground(for: colorScheme))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            if historyManager.historyItems.isEmpty {
                EmptyHistoryView()
            } else {
                VStack(spacing: 0) {
                    headerView
                    historyContent
                }
            }
        }
        .sheet(isPresented: $showStatistics) {
            HistoryStatisticsView()
        }
        .sheet(isPresented: .constant(selectedDrink != nil), onDismiss: { selectedDrink = nil }) {
            if let drink = selectedDrink {
                DetailsView(cocktail: drink.strDrink, hideCloseButton: false) {
                    selectedDrink = nil
                }
            }
        }
        .alert("Clear History?", isPresented: $showClearConfirmation) {
            Button("Clear All", role: .destructive) {
                historyManager.clearHistory()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all \(historyManager.historyItems.count) cocktails from your history.")
        }
    }
    
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day name
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Empty History View
struct EmptyHistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.iconLarge)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            
            VStack(spacing: 8) {
                Text("No History Yet")
                    .font(.sectionHeader)
                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                
                Text("Start making cocktails and they'll appear here")
                    .font(.bodyText)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Period Filter Button
struct PeriodFilterButton: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.bodyText)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? COLOR_CHARCOAL : AdaptiveColors.textPrimary(for: colorScheme))
                
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(isSelected ? COLOR_CHARCOAL : AdaptiveColors.textSecondary(for: colorScheme))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? COLOR_WARM_AMBER : AdaptiveColors.cardBackground(for: colorScheme))
            .cornerRadius(20)
        }
    }
}

// MARK: - History Item Card
struct HistoryItemCard: View {
    @Environment(\.colorScheme) var colorScheme
    let item: CocktailHistoryItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Cocktail Image
                if let drink = DrinkManager.shared.allDrinks?.first(where: { $0.idDrink == item.drinkId }),
                   let thumbURL = drink.strDrinkThumb,
                   let url = URL(string: thumbURL) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        Rectangle()
                            .fill(COLOR_CHARCOAL)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(AdaptiveColors.cardBackground(for: colorScheme))
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        
                        Image(systemName: "wineglass")
                            .foregroundColor(COLOR_WARM_AMBER)
                            .font(.iconMini)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.cocktailName)
                        .font(.bodyText)
                        .fontWeight(.semibold)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(timeAgo(from: item.dateMade))
                    }
                    .font(.caption)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    
                    // Rating
                    if let rating = item.rating {
                        HStack(spacing: 2) {
                            ForEach(0..<rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.captionSmall)
                                    .foregroundColor(COLOR_WARM_AMBER)
                            }
                        }
                    }
                    
                    // Notes preview
                    if let notes = item.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            .lineLimit(1)
                            .italic()
                    }
                }
                
                Spacer()
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        .font(.navTitle)
                }
            }
            .padding(12)
            .background(AdaptiveColors.cardBackground(for: colorScheme))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - History Statistics View
struct HistoryStatisticsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @State private var showExportSheet = false
    
    var statistics: HistoryStatistics {
        historyManager.getStatistics()
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
                        // Overview Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.sectionHeader)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                StatCard(title: "Total Made", value: "\(statistics.totalCocktailsMade)", color: COLOR_WARM_AMBER)
                                StatCard(title: "Unique", value: "\(statistics.uniqueCocktails)", color: COLOR_WARM_AMBER)
                                StatCard(title: "This Week", value: "\(statistics.cocktailsThisWeek)", color: .green)
                                StatCard(title: "This Month", value: "\(statistics.cocktailsThisMonth)", color: .blue)
                            }
                        }
                        
                        // Streak
                        if statistics.currentStreak > 0 {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("Current Streak")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                }
                                
                                HStack {
                                    Text("\(statistics.currentStreak)")
                                        .font(.displayLarge)
                                        .foregroundColor(.orange)
                                    
                                    Text("day\(statistics.currentStreak == 1 ? "" : "s")")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Average Rating
                        if let avgRating = statistics.averageRating {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Average Rating")
                                    .font(.sectionHeader)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                
                                HStack(spacing: 4) {
                                    Text(String(format: "%.1f", avgRating))
                                        .font(.cocktailTitle)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.iconMini)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Top Cocktails
                        if !statistics.favoriteCocktails.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    Text("Top Cocktails")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(statistics.favoriteCocktails.enumerated()), id: \.offset) { index, favorite in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.headline)
                                                .foregroundColor(COLOR_WARM_AMBER)
                                                .frame(width: 30, alignment: .leading)
                                            
                                            Text(favorite.name)
                                                .font(.bodyText)
                                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                            
                                            Spacer()
                                            
                                            Text("\(favorite.count)×")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        }
                                        .padding(12)
                                        .background(COLOR_CHARCOAL_LIGHT)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Most Used Ingredients
                        if !statistics.mostUsedIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(COLOR_WARM_AMBER)
                                    Text("Most Used Ingredients")
                                        .font(.sectionHeader)
                                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(statistics.mostUsedIngredients.prefix(5).enumerated()), id: \.offset) { index, ingredient in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.headline)
                                                .foregroundColor(COLOR_WARM_AMBER)
                                                .frame(width: 30, alignment: .leading)
                                            
                                            Text(ingredient.ingredient)
                                                .font(.bodyText)
                                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                            
                                            Spacer()
                                            
                                            Text("\(ingredient.count)×")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        }
                                        .padding(12)
                                        .background(COLOR_CHARCOAL_LIGHT)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Export Button
                        Button(action: { showExportSheet = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export History")
                            }
                            .font(.bodyText)
                            .fontWeight(.semibold)
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .sheet(isPresented: $showExportSheet) {
                ShareSheet(items: [historyManager.exportHistoryAsText()])
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AdaptiveColors.cardBackground(for: colorScheme))
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
}
