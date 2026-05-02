//
//  HistoryView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @State private var selectedPeriod: TimePeriod = .allTime
    @State private var searchText = ""
    @State private var showStatistics = false
    @State private var showClearConfirmation = false
    @State private var selectedDrink: DrinkDetails?

    var filteredHistory: [CocktailHistoryItem] {
        let periodFiltered = historyManager.getHistory(for: selectedPeriod)
        if searchText.isEmpty { return periodFiltered }
        return historyManager.searchHistory(query: searchText).filter { item in
            periodFiltered.contains(where: { $0.id == item.id })
        }
    }

    var groupedHistory: [(date: Date, items: [CocktailHistoryItem])] {
        historyManager.groupedByDate(filteredHistory)
    }

    var body: some View {
        ZStack(alignment: .top) {
            COLOR_BACKGROUND.ignoresSafeArea()
            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────────
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HISTORY")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Text("Cocktail Log")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                    }
                    Spacer()
                    Button { showStatistics = true } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(COLOR_WARM_AMBER.opacity(0.14))
                                .frame(width: 40, height: 40)
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // ── Search bar ───────────────────────────────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                    TextField("Search history...", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .tint(COLOR_WARM_AMBER)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.07))
                .cornerRadius(13)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

                // ── Period filter chips ──────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Button { selectedPeriod = period } label: {
                                Text(period.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(selectedPeriod == period ? COLOR_CHARCOAL : COLOR_TEXT_SECONDARY)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedPeriod == period ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                // ── Content ──────────────────────────────────────────────────
                if historyManager.historyItems.isEmpty {
                    Spacer()
                    emptyHistoryView
                    Spacer()
                } else if filteredHistory.isEmpty {
                    Spacer()
                    emptyFilteredView
                    Spacer()
                } else {
                    historyListView
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
            Button("Clear All", role: .destructive) { historyManager.clearHistory() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all \(historyManager.historyItems.count) cocktails from your history.")
        }
    }

    // ── Empty states ─────────────────────────────────────────────────────────

    private var emptyHistoryView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(COLOR_CHARCOAL_LIGHT).frame(width: 72, height: 72)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 30))
                    .foregroundColor(COLOR_WARM_AMBER)
            }
            VStack(spacing: 6) {
                Text("No History Yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                Text("Start making cocktails and they'll appear here")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 60)
    }

    private var emptyFilteredView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(COLOR_TEXT_SECONDARY)
            Text("No cocktails found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(COLOR_TEXT_PRIMARY)
            Button {
                searchText = ""
                selectedPeriod = .allTime
            } label: {
                Text("Clear Filters")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(COLOR_WARM_AMBER)
            }
        }
        .padding(.vertical, 60)
    }

    // ── List ─────────────────────────────────────────────────────────────────

    private var historyListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(groupedHistory, id: \.date) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(sectionTitle(for: group.date).uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                            .padding(.horizontal, 20)
                        VStack(spacing: 0) {
                            ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                                HistoryItemRow(
                                    item: item,
                                    isLast: index == group.items.count - 1,
                                    onTap: {
                                        if let drink = DrinkManager.shared.allDrinks?.first(where: { $0.idDrink == item.drinkId }) {
                                            selectedDrink = drink
                                        }
                                    },
                                    onDelete: { historyManager.deleteHistoryItem(item) }
                                )
                            }
                        }
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }
                }

                Button {
                    showClearConfirmation = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                        Text("Clear All History")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 48)
            }
            .padding(.top, 4)
        }
    }

    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: date)
        }
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: date)
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: CocktailHistoryItem
    var isLast: Bool = false
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Thumbnail
                    if let drink = DrinkManager.shared.allDrinks?.first(where: { $0.idDrink == item.drinkId }),
                       let urlStr = drink.strDrinkThumb, let url = URL(string: urlStr) {
                        CachedAsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10).fill(COLOR_CHARCOAL).frame(width: 56, height: 56)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(COLOR_CHARCOAL).frame(width: 56, height: 56)
                            Image(systemName: "wineglass").foregroundColor(COLOR_WARM_AMBER).font(.system(size: 20))
                        }
                    }

                    // Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.cocktailName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Image(systemName: "clock").font(.system(size: 11))
                            Text(timeAgo(from: item.dateMade)).font(.system(size: 12))
                        }
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        if let rating = item.rating, rating > 0 {
                            HStack(spacing: 2) {
                                ForEach(0..<rating, id: \.self) { _ in
                                    Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(COLOR_WARM_AMBER)
                                }
                            }
                        }
                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 12))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .lineLimit(1)
                                .italic()
                        }
                    }

                    Spacer()

                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.4))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 84)
            }
        }
    }

    private func timeAgo(from date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty History View (kept for backward compat)
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(COLOR_CHARCOAL_LIGHT).frame(width: 72, height: 72)
                Image(systemName: "clock.arrow.circlepath").font(.system(size: 30)).foregroundColor(COLOR_WARM_AMBER)
            }
            VStack(spacing: 6) {
                Text("No History Yet")
                    .font(.system(size: 20, weight: .semibold)).foregroundColor(COLOR_TEXT_PRIMARY)
                Text("Start making cocktails and they'll appear here")
                    .font(.system(size: 14)).foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center).padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Stub views kept to avoid breaking other references
struct PeriodFilterButton: View {
    let title: String; let isSelected: Bool; let count: Int; let action: () -> Void
    var body: some View { EmptyView() }
}
struct HistoryItemCard: View {
    let item: CocktailHistoryItem; let onTap: () -> Void; let onDelete: () -> Void
    var body: some View { EmptyView() }
}
struct StatCard: View {
    let title: String; let value: String; let color: Color
    var body: some View { EmptyView() }
}

// MARK: - History Statistics View
struct HistoryStatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @State private var showExportSheet = false

    var statistics: HistoryStatistics { historyManager.getStatistics() }

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Overview stats
                        VStack(alignment: .leading, spacing: 10) {
                            Text("OVERVIEW")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                HistoryStatCard(title: "Total Made", value: "\(statistics.totalCocktailsMade)", color: COLOR_WARM_AMBER)
                                HistoryStatCard(title: "Unique", value: "\(statistics.uniqueCocktails)", color: COLOR_WARM_AMBER)
                                HistoryStatCard(title: "This Week", value: "\(statistics.cocktailsThisWeek)", color: .green)
                                HistoryStatCard(title: "This Month", value: "\(statistics.cocktailsThisMonth)", color: .blue)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Streak
                        if statistics.currentStreak > 0 {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill").foregroundColor(.orange).font(.system(size: 12, weight: .semibold))
                                    Text("STREAK").font(.system(size: 12, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY).kerning(1)
                                }
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("\(statistics.currentStreak)")
                                        .font(.system(size: 48, weight: .bold)).foregroundColor(.orange)
                                    Text("day\(statistics.currentStreak == 1 ? "" : "s") in a row")
                                        .font(.system(size: 16)).foregroundColor(COLOR_TEXT_SECONDARY)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                        }

                        // Average rating
                        if let avgRating = statistics.averageRating {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("AVERAGE RATING")
                                    .font(.system(size: 12, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY).kerning(1)
                                HStack(spacing: 8) {
                                    Text(String(format: "%.1f", avgRating))
                                        .font(.system(size: 32, weight: .bold)).foregroundColor(COLOR_WARM_AMBER)
                                    Image(systemName: "star.fill").font(.system(size: 18)).foregroundColor(COLOR_WARM_AMBER)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                        }

                        // Top cocktails
                        if !statistics.favoriteCocktails.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trophy.fill").foregroundColor(COLOR_WARM_AMBER).font(.system(size: 12, weight: .semibold))
                                    Text("TOP COCKTAILS").font(.system(size: 12, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY).kerning(1)
                                }
                                VStack(spacing: 0) {
                                    ForEach(Array(statistics.favoriteCocktails.enumerated()), id: \.offset) { index, favorite in
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text("\(index + 1)")
                                                    .font(.system(size: 14, weight: .bold)).foregroundColor(COLOR_WARM_AMBER).frame(width: 24)
                                                Text(favorite.name)
                                                    .font(.system(size: 15, weight: .medium)).foregroundColor(COLOR_TEXT_PRIMARY)
                                                Spacer()
                                                Text("\(favorite.count)x")
                                                    .font(.system(size: 13, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY)
                                            }
                                            .padding(.horizontal, 16).padding(.vertical, 14)
                                            if index < statistics.favoriteCocktails.count - 1 {
                                                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.leading, 52)
                                            }
                                        }
                                    }
                                }
                                .background(COLOR_CHARCOAL_LIGHT).cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                        }

                        // Most used ingredients
                        if !statistics.mostUsedIngredients.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "drop.fill").foregroundColor(COLOR_WARM_AMBER).font(.system(size: 12, weight: .semibold))
                                    Text("TOP INGREDIENTS").font(.system(size: 12, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY).kerning(1)
                                }
                                VStack(spacing: 0) {
                                    ForEach(Array(statistics.mostUsedIngredients.prefix(5).enumerated()), id: \.offset) { index, ingredient in
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text("\(index + 1)")
                                                    .font(.system(size: 14, weight: .bold)).foregroundColor(COLOR_WARM_AMBER).frame(width: 24)
                                                Text(ingredient.ingredient)
                                                    .font(.system(size: 15, weight: .medium)).foregroundColor(COLOR_TEXT_PRIMARY)
                                                Spacer()
                                                Text("\(ingredient.count)x")
                                                    .font(.system(size: 13, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY)
                                            }
                                            .padding(.horizontal, 16).padding(.vertical, 14)
                                            if index < min(4, statistics.mostUsedIngredients.count - 1) {
                                                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.leading, 52)
                                            }
                                        }
                                    }
                                }
                                .background(COLOR_CHARCOAL_LIGHT).cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                        }

                        // Export
                        Button { showExportSheet = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up").font(.system(size: 15, weight: .semibold))
                                Text("Export History").font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 48)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .sheet(isPresented: $showExportSheet) {
                ShareSheet(items: [historyManager.exportHistoryAsText()])
            }
        }
    }
}

// MARK: - History Stat Card
struct HistoryStatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(COLOR_TEXT_SECONDARY)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
}
