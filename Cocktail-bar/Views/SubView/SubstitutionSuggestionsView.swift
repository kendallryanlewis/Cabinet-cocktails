//
//  SubstitutionSuggestionsView.swift
//  Cocktail-bar
//

import SwiftUI

// MARK: - Substitution Suggestions View
struct SubstitutionSuggestionsView: View {
    let drink: DrinkDetails
    @StateObject private var substitutionManager = SubstitutionManager.shared

    @State private var suggestions: [SubstitutionSuggestion] = []
    @State private var selectedSuggestion: SubstitutionSuggestion?

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()

                if suggestions.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {

                            // Subtitle
                            Text("Tap an ingredient to see swap options from your bar.")
                                .font(.system(size: 14))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)

                            // Cards
                            VStack(spacing: 0) {
                                ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                                    Button { selectedSuggestion = suggestion } label: {
                                        SubstitutionRow(suggestion: suggestion, isLast: index == suggestions.count - 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(14)
                            .padding(.horizontal, 20)

                            Spacer(minLength: 48)
                        }
                    }
                }
            }
            .navigationTitle("Substitutions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
        }
        .onAppear { loadSuggestions() }
        // ── Use .sheet(item:) so the suggestion is always non-nil when sheet opens ──
        .sheet(item: $selectedSuggestion) { suggestion in
            SubstitutionDetailView(suggestion: suggestion)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(COLOR_CHARCOAL_LIGHT).frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
            VStack(spacing: 6) {
                Text("You have all ingredients!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                Text("No substitutions needed for \(drink.strDrink).")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 60)
    }

    // MARK: - Data Loading

    private func loadSuggestions() {
        let missing = getMissingIngredients()
        let inventory = LocalStorageManager.shared.retrieveTopShelfItems()
        suggestions = substitutionManager.findSuggestions(for: missing, userInventory: inventory)
    }

    private func getMissingIngredients() -> [String] {
        let inventory = LocalStorageManager.shared.retrieveTopShelfItems().map { $0.lowercased() }
        return drink.getIngredients().filter { ingredient in
            let lower = ingredient.lowercased()
            return !inventory.contains(where: { $0.contains(lower) || lower.contains($0) })
        }
    }
}

// MARK: - Substitution Row (in-list)
struct SubstitutionRow: View {
    let suggestion: SubstitutionSuggestion
    var isLast: Bool = false

    private var difficultyColor: Color {
        switch suggestion.substitution.difficulty {
        case .easy: return .green
        case .moderate: return .orange
        case .challenging: return .red
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Amber icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(COLOR_WARM_AMBER.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.missingIngredient)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    if let recommended = suggestion.recommendedAlternative {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").font(.system(size: 9)).foregroundColor(COLOR_WARM_AMBER)
                            Text(recommended.name)
                                .font(.system(size: 13))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    } else {
                        Text("\(suggestion.substitution.alternatives.count) options available")
                            .font(.system(size: 13))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }

                Spacer()

                // Difficulty chip
                Text(suggestion.substitution.difficulty.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(difficultyColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor.opacity(0.12))
                    .cornerRadius(8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 70)
            }
        }
    }
}

// MARK: - Substitution Detail View
struct SubstitutionDetailView: View {
    let suggestion: SubstitutionSuggestion
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // ── Missing ingredient header ─────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MISSING INGREDIENT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            Text(suggestion.missingIngredient)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            HStack(spacing: 8) {
                                Text(suggestion.substitution.category.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(COLOR_WARM_AMBER)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(COLOR_WARM_AMBER.opacity(0.12))
                                    .cornerRadius(8)
                                if suggestion.substitution.preservesOriginalFlavor {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.seal.fill").font(.system(size: 11))
                                        Text("Flavor preserved").font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green.opacity(0.10))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                        // ── Alternatives list ─────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SUBSTITUTES")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach(Array(suggestion.substitution.alternatives.enumerated()), id: \.element.id) { index, alternative in
                                    let isAvailable = suggestion.availableAlternatives.contains(where: { $0.id == alternative.id })
                                    let isRecommended = suggestion.recommendedAlternative?.id == alternative.id
                                    let isLast = index == suggestion.substitution.alternatives.count - 1

                                    AlternativeDetailRow(
                                        alternative: alternative,
                                        isAvailable: isAvailable,
                                        isRecommended: isRecommended,
                                        isLast: isLast
                                    )
                                }
                            }
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(14)
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 48)
                    }
                }
            }
            .navigationTitle("Swap Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
        }
    }
}

// MARK: - Alternative Detail Row
struct AlternativeDetailRow: View {
    let alternative: SubstitutionAlternative
    let isAvailable: Bool
    let isRecommended: Bool
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Status icon
                Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isRecommended ? COLOR_WARM_AMBER : isAvailable ? .green : COLOR_TEXT_SECONDARY.opacity(0.3))
                    .frame(width: 24)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(alternative.name)
                            .font(.system(size: 15, weight: isRecommended ? .bold : .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        if isRecommended {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }

                    // Ratio
                    Text(alternative.displayRatio())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(COLOR_WARM_AMBER)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(COLOR_WARM_AMBER.opacity(0.12))
                        .cornerRadius(6)

                    if let notes = alternative.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 12))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .italic()
                    }

                    if let flavor = alternative.flavorProfile, !flavor.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "leaf.fill").font(.system(size: 10))
                            Text(flavor).font(.system(size: 12))
                        }
                        .foregroundColor(COLOR_WARM_AMBER.opacity(0.7))
                    }

                    if !isAvailable {
                        Text("Not in your cabinet")
                            .font(.system(size: 11))
                            .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.5))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if !isLast {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 54)
            }
        }
    }
}

// MARK: - Compact Substitution Badge (kept for compatibility)
struct SubstitutionBadge: View {
    let missingCount: Int
    let hasSubstitutes: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.2.circlepath").font(.caption)
            Text("\(missingCount) substitutes").font(.caption).fontWeight(.medium)
        }
        .foregroundColor(hasSubstitutes ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(hasSubstitutes ? COLOR_WARM_AMBER.opacity(0.2) : Color.white.opacity(0.07))
        .cornerRadius(12)
    }
}

// MARK: - AlternativeRow alias kept for backward compat
struct AlternativeRow: View {
    let alternative: SubstitutionAlternative
    let isAvailable: Bool
    let isRecommended: Bool
    var body: some View {
        AlternativeDetailRow(alternative: alternative, isAvailable: isAvailable, isRecommended: isRecommended)
    }
}
