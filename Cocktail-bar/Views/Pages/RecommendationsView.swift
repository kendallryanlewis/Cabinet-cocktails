//
//  RecommendationsView.swift
//  Cocktail-bar
//
//  Created by GitHub Copilot on 12/30/25.
//

import SwiftUI

struct RecommendationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var recommendationEngine = RecommendationEngine.shared
    @State private var selectedMode: RecommendationMode = .basedOnCabinet
    @State private var isRefreshing = false
    @State private var selectedDrink: String?
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Mode Selector
                modeSelector
                
                // Recommendations List
                if recommendationEngine.isLoading {
                    loadingView
                } else if let recommendations = recommendationEngine.recommendations[selectedMode],
                          !recommendations.isEmpty {
                    recommendationsList(recommendations)
                } else {
                    emptyStateView
                }
            }
        }
        .sheet(isPresented: .constant(selectedDrink != nil), onDismiss: { selectedDrink = nil }) {
            if let drinkName = selectedDrink {
                DetailsView(cocktail: drinkName, hideCloseButton: false) {
                    selectedDrink = nil
                }
            }
        }
        .onAppear {
            Task {
                await recommendationEngine.generateRecommendations()
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("For You")
                        .font(.cocktailTitle)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                    
                    if let lastRefresh = recommendationEngine.lastRefreshDate {
                        Text("Updated \(lastRefresh, style: .relative) ago")
                            .font(.caption)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                }
                
                Spacer()
                
                // Refresh Button
                Button(action: {
                    Task {
                        isRefreshing = true
                        await recommendationEngine.refreshRecommendations()
                        isRefreshing = false
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.cardTitle)
                        .foregroundColor(COLOR_WARM_AMBER)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
                .disabled(isRefreshing)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
    }
    
    // MARK: - Mode Selector
    private var modeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecommendationMode.allCases) { mode in
                    ModeFilterButton(
                        mode: mode,
                        isSelected: selectedMode == mode,
                        count: recommendationEngine.recommendations[mode]?.count ?? 0
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMode = mode
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(AdaptiveColors.cardBackground(for: colorScheme))
    }
    
    // MARK: - Recommendations List
    private func recommendationsList(_ recommendations: [CocktailRecommendation]) -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(recommendations) { recommendation in
                    RecommendationCard(recommendation: recommendation) {
                        selectedDrink = recommendation.drink.strDrink
                    }
                }
            }
            .padding(20)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            SwiftUI.ProgressView()
                .scaleEffect(1.5)
                .accentColor(COLOR_WARM_AMBER)
            
            Text("Analyzing your preferences...")
                .font(.bodyText)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedMode.icon)
                .font(.iconLarge)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            
            Text("No Recommendations Yet")
                .font(.sectionHeader)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
            
            Text(emptyStateMessage)
                .font(.bodyText)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateMessage: String {
        switch selectedMode {
        case .basedOnCabinet:
            return "Add ingredients to your cabinet to get personalized recommendations"
        case .youMightLike:
            return "Start making cocktails to build your taste profile"
        case .trending:
            return "Check back later for trending cocktails"
        case .similar:
            return "Mark some cocktails as made to find similar drinks"
        }
    }
}

// MARK: - Mode Filter Button
struct ModeFilterButton: View {
    @Environment(\.colorScheme) var colorScheme
    let mode: RecommendationMode
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.buttonSmall)
                
                Text(mode.rawValue)
                    .font(.buttonSmall)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(isSelected ? AdaptiveColors.cardBackground(for: colorScheme) : COLOR_WARM_AMBER)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? COLOR_WARM_AMBER : AdaptiveColors.background(for: colorScheme))
                        )
                }
            }
            .foregroundColor(isSelected ? AdaptiveColors.cardBackground(for: colorScheme) : AdaptiveColors.textPrimary(for: colorScheme))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? COLOR_WARM_AMBER : AdaptiveColors.cardBackground(for: colorScheme))
            )
        }
    }
}

// MARK: - Recommendation Card
struct RecommendationCard: View {
    @Environment(\.colorScheme) var colorScheme
    let recommendation: CocktailRecommendation
    let action: () -> Void
    
    @State private var imageLoaded = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Cocktail Image
                AsyncImage(url: URL(string: recommendation.drink.strDrinkThumb ?? "")) { phase in
                    switch phase {
                    case .empty:
                        SwiftUI.ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onAppear { imageLoaded = true }
                    case .failure:
                        Image("GenericAlcohol")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(recommendation.drink.strDrink)
                        .font(.cardTitle)
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text(recommendation.reason)
                            .font(.bodySmall)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            .lineLimit(1)
                    }
                    
                    if let category = recommendation.drink.strCategory {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(COLOR_WARM_AMBER).opacity(0.15)
                            )
                    }
                    
                    // Score Indicator
                    HStack(spacing: 4) {
                        Text("\(Int(recommendation.score))%")
                            .font(.buttonSmall)
                            .foregroundColor(scoreColor(for: recommendation.score))
                        
                        Text("match")
                            .font(.caption)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.buttonSmall)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AdaptiveColors.cardBackground(for: colorScheme))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return COLOR_WARM_AMBER
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview
struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsView()
    }
}
