//
//  DetailsView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/11/23.
//

import SwiftUI
import AVKit
import WebKit


enum DetailsSheet: Identifiable, Hashable {
    case markAsMade, batchCalculator, substitutions, addToCollection, videoMix
    case paywall(PremiumFeature)
    var id: Int { hashValue }
}

struct DetailsView: View {
    @State var cocktail: String
    @State var hideCloseButton: Bool
    @State private var tagArray: [String]?
    @State var cocktailDetails: DrinkDetails?
    @State private var isFilled = false
    @State private var isSaved = false
    @State private var isLoading = true
    @State private var activeSheet: DetailsSheet?
    @State private var showShoppingListToast = false
    @State private var showMarkAsMadePanel = false
    @State private var markAsMadeRating = 0
    @State private var markAsMadeNotes = ""
    @State private var currentInstructionStep = 0
    @EnvironmentObject private var premiumManager: PremiumManager
    @StateObject private var historyManager = CocktailHistoryManager.shared
    @StateObject private var substitutionManager = SubstitutionManager.shared
    @StateObject private var collectionManager = CollectionManager.shared
    @StateObject private var shoppingListManager = ShoppingListManager.shared
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()
            if isLoading {
                SwiftUI.ProgressView().scaleEffect(1.5).tint(COLOR_WARM_AMBER)
            } else if let details = cocktailDetails {
                detailsContent(details)
            } else {
                errorState
            }
        }
        .task(id: cocktail) {
            isLoading = true
            cocktailDetails = DrinkManager.shared.findDrinkByName(name: cocktail)
            isFilled = LocalStorageManager.shared.retrieveFavoriteItems().contains(where: { $0.name == cocktail })
            isSaved = collectionManager.collections.contains(where: { $0.cocktails.contains(where: { $0.drinkId == (cocktailDetails?.idDrink ?? "") }) })
            isLoading = false
        }
        .sheet(item: $activeSheet, onDismiss: {
            isSaved = collectionManager.collections.contains(where: { $0.cocktails.contains(where: { $0.drinkId == (cocktailDetails?.idDrink ?? "") }) })
        }) { sheet in
            sheetContent(sheet)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private func detailsContent(_ details: DrinkDetails) -> some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection(details)
                    actionBar(details)
                    VStack(spacing: 32) {
                        metadataAndStats(details)
                        ingredientsSection(details)
                        instructionsSection(details)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 60)
                }
            }
            .ignoresSafeArea(edges: .top)
            .overlay(shoppingListToast, alignment: .bottom)

        }
    }

    // MARK: - Hero

    @ViewBuilder
    private func heroSection(_ details: DrinkDetails) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let urlStr = details.strDrinkThumb, let url = URL(string: urlStr) {
                CachedAsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    COLOR_CHARCOAL
                }
                .frame(height: 420)
                .clipped()
            } else {
                COLOR_CHARCOAL.frame(height: 420)
            }

            LinearGradient(
                colors: [.clear, .clear, Color.black.opacity(0.5), Color.black.opacity(0.92)],
                startPoint: .top, endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 14) {
                Text(details.strDrink)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                HStack(spacing: 10) {
                    // Love
                    Button {
                        if isFilled {
                            let idx = removeFromFavorites()
                            if idx >= 0 { LocalStorageManager.shared.removeFavoriteItem(at: idx) }
                            isFilled = false
                        } else {
                            LocalStorageManager.shared.addFavoriteItem(newItem: addToFavorites(detail: details))
                            isFilled = true
                        }
                    } label: {
                        heroActionIcon(systemName: isFilled ? "heart.fill" : "heart", isActive: isFilled)
                    }
                    // Save
                    Button { activeSheet = .addToCollection } label: {
                        heroActionIcon(systemName: isSaved ? "bookmark.fill" : "bookmark", isActive: isSaved)
                    }
                    // Share
                    ShareLink(item: details.strDrink + " — a cocktail recipe from Cabinet Cocktails!") {
                        heroActionIcon(systemName: "square.and.arrow.up")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .frame(height: 420)
    }

    // MARK: - Action Bar

    @ViewBuilder
    private func actionBar(_ details: DrinkDetails) -> some View {
        HStack(spacing: 0) {
            actionButton(icon: "scalemass", label: "Batch") {
                if premiumManager.hasAccess(to: .batchCalculator) {
                    activeSheet = .batchCalculator
                } else {
                    activeSheet = .paywall(.batchCalculator)
                }
            }
            actionDivider
            actionButton(icon: "arrow.triangle.2.circlepath", label: "Substitute") {
                if premiumManager.hasAccess(to: .ingredientSubstitutions) {
                    activeSheet = .substitutions
                } else {
                    activeSheet = .paywall(.ingredientSubstitutions)
                }
            }
        }
        .background(COLOR_CHARCOAL_LIGHT)
    }

    @ViewBuilder
    private func heroActionIcon(systemName: String, isActive: Bool = false) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 40, height: 40)
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isActive ? COLOR_WARM_AMBER : .white)
        }
    }

    private var actionDivider: some View {
        Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 36)
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 18))
                Text(label).font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isActive ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
    }

    // MARK: - Metadata + Stats

    @ViewBuilder
    private func metadataAndStats(_ details: DrinkDetails) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 24) {
                if let glass = details.strGlass, !glass.isEmpty {
                    metaTag(label: "Serving", value: glass)
                }
                if !details.strAlcoholic.isEmpty {
                    metaTag(label: "Taste", value: details.strAlcoholic)
                }
                Spacer()
            }

            let all = buildIngredients(from: details)
            let alcoholCount = all.filter { isAlcoholicIngredient($0.0) }.count
            let total = all.count
            let complexity = min(total, 10)
            let strength = min(alcoholCount, 5)

            HStack(spacing: 0) {
                statBadge(value: "\(strength)/5", topLabel: "Strength", bottomLabel: strengthLabel(strength))
                statBadge(value: "\(complexity)/10", topLabel: "Complexity", bottomLabel: complexityLabel(complexity))
                statBadge(value: "\(alcoholCount)", topLabel: "Alcoholic", bottomLabel: "ingredients")
            }
        }
    }

    @ViewBuilder
    private func metaTag(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label + ":").font(.system(size: 13)).foregroundColor(COLOR_TEXT_SECONDARY)
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundColor(COLOR_TEXT_PRIMARY)
        }
    }

    @ViewBuilder
    private func statBadge(value: String, topLabel: String, bottomLabel: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().stroke(COLOR_WARM_AMBER, lineWidth: 2).frame(width: 76, height: 76)
                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .multilineTextAlignment(.center)
            }
            VStack(spacing: 2) {
                Text(topLabel).font(.system(size: 11, weight: .semibold)).foregroundColor(COLOR_TEXT_SECONDARY)
                Text(bottomLabel).font(.system(size: 11)).foregroundColor(COLOR_TEXT_SECONDARY)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Ingredients

    @ViewBuilder
    private func ingredientsSection(_ details: DrinkDetails) -> some View {
        let all = buildIngredients(from: details)
        let grouped = groupIngredients(all)
        let missingCount = getMissingIngredientsCount(details: details)

        VStack(alignment: .leading, spacing: 20) {
            Text("Ingredients")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(COLOR_TEXT_PRIMARY)

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    if !grouped.alcohol.isEmpty { ingredientGroup(title: "Alcohol:", items: grouped.alcohol) }
                    if !grouped.mixer.isEmpty   { ingredientGroup(title: "Juice:", items: grouped.mixer) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    if !grouped.garnish.isEmpty { ingredientGroup(title: "Garnish:", items: grouped.garnish) }
                    if !grouped.other.isEmpty   { ingredientGroup(title: "Other:", items: grouped.other) }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                for (name, _) in all {
                    shoppingListManager.addItem(ingredient: name, fromCocktails: [details.strDrink])
                }
                withAnimation(.easeInOut) { showShoppingListToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut) { showShoppingListToast = false }
                }
            } label: {
                Text(missingCount > 0 ? "Add \(missingCount) missing to shopping list" : "Add to shopping list")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(30)
            }
        }
    }

    @ViewBuilder
    private func ingredientGroup(title: String, items: [(String, String?)]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(COLOR_TEXT_PRIMARY)
            ForEach(Array(items.enumerated()), id: \.offset) { _, pair in
                Text((pair.1 != nil ? pair.1! + " " : "") + pair.0)
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Instructions

    @ViewBuilder
    private func instructionsSection(_ details: DrinkDetails) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How to make it")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(COLOR_TEXT_PRIMARY)

            if let videoURL = details.strVideo, !videoURL.isEmpty {
                Button { activeSheet = .videoMix } label: {
                    ZStack {
                        if let urlStr = details.strDrinkThumb, let url = URL(string: urlStr) {
                            CachedAsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: { COLOR_CHARCOAL_LIGHT }
                            .frame(height: 180).clipped()
                        } else {
                            COLOR_CHARCOAL_LIGHT.frame(height: 180)
                        }
                        Color.black.opacity(0.35)
                        Circle().fill(Color.white).frame(width: 52, height: 52)
                        Image(systemName: "play.fill").font(.system(size: 20)).foregroundColor(.black).offset(x: 2)
                    }
                    .frame(height: 180).cornerRadius(14).clipped()
                }
            }

            if let instructions = details.strInstructions, !instructions.isEmpty {
                let steps = parseInstructions(instructions)
                if !steps.isEmpty {
                    inlineStepWizard(steps: steps)
                }
            }

            markAsMadePanel(details)
        }
    }

    // MARK: - Inline Step Wizard

    @ViewBuilder
    private func inlineStepWizard(steps: [String]) -> some View {
        let total = steps.count
        let current = min(currentInstructionStep, total - 1)
        let step = steps[current]

        VStack(spacing: 16) {
            // Progress capsule + counter
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.10)).frame(height: 5)
                        Capsule()
                            .fill(COLOR_WARM_AMBER)
                            .frame(width: geo.size.width * CGFloat(current + 1) / CGFloat(total), height: 5)
                            .animation(.spring(response: 0.4), value: current)
                    }
                }
                .frame(height: 5)
                Text("Step \(current + 1) of \(total)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Step card
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(COLOR_WARM_AMBER.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Text("\(current + 1)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
                Text(step)
                    .font(.system(size: 16))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(16)

            // Prev / Next
            HStack(spacing: 12) {
                Button {
                    withAnimation { currentInstructionStep = max(0, current - 1) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left").font(.system(size: 12, weight: .semibold))
                        Text("Previous").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(current == 0 ? COLOR_TEXT_SECONDARY.opacity(0.3) : COLOR_TEXT_PRIMARY)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(12)
                }
                .disabled(current == 0)

                Button {
                    if current == total - 1 {
                        withAnimation { showMarkAsMadePanel = true }
                    } else {
                        withAnimation { currentInstructionStep = min(total - 1, current + 1) }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if current == total - 1 {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 14, weight: .semibold))
                        }
                        Text(current == total - 1 ? "Mark as Made" : "Next").font(.system(size: 14, weight: .semibold))
                        if current < total - 1 {
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                        }
                    }
                    .foregroundColor(current == total - 1 ? .black : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(current == total - 1 ? COLOR_WARM_AMBER : COLOR_WARM_AMBER)
                    .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Mark As Made Panel

    @ViewBuilder
    private func markAsMadePanel(_ details: DrinkDetails) -> some View {
        VStack(spacing: 0) {
            // ── Trigger button ────────────────────────────────────────────────
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    showMarkAsMadePanel.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: showMarkAsMadePanel ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 15, weight: .medium))
                    Text(showMarkAsMadePanel ? "Log this cocktail" : "Mark as Made")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: showMarkAsMadePanel ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(COLOR_WARM_AMBER)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(COLOR_WARM_AMBER.opacity(0.12))
                .cornerRadius(showMarkAsMadePanel ? 14 : 12)
            }

            // ── Expanded log form ─────────────────────────────────────────────
            if showMarkAsMadePanel {
                VStack(alignment: .leading, spacing: 20) {

                    // Times made
                    let count = historyManager.getCocktailCount(for: details.strDrink)
                    if count > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath").font(.system(size: 12))
                            Text("Made \(count) time\(count == 1 ? "" : "s") before")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(COLOR_WARM_AMBER.opacity(0.8))
                    }

                    // Rating
                    VStack(alignment: .leading, spacing: 10) {
                        Text("RATING")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        HStack(spacing: 14) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    markAsMadeRating = (markAsMadeRating == star) ? 0 : star
                                } label: {
                                    Image(systemName: star <= markAsMadeRating ? "star.fill" : "star")
                                        .font(.system(size: 28))
                                        .foregroundColor(star <= markAsMadeRating ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.3))
                                }
                            }
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        ZStack(alignment: .topLeading) {
                            if markAsMadeNotes.isEmpty {
                                Text("How did it turn out?")
                                    .font(.system(size: 15))
                                    .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.45))
                                    .padding(12)
                            }
                            TextEditor(text: $markAsMadeNotes)
                                .font(.system(size: 15))
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .tint(COLOR_WARM_AMBER)
                                .scrollContentBackground(.hidden)
                                .padding(6)
                        }
                        .frame(minHeight: 90)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }

                    // Save button
                    Button {
                        historyManager.addToHistory(
                            cocktailName: details.strDrink,
                            drinkId: details.idDrink,
                            rating: markAsMadeRating > 0 ? markAsMadeRating : nil,
                            notes: markAsMadeNotes.isEmpty ? nil : markAsMadeNotes,
                            ingredients: extractIngredients(from: details)
                        )
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMarkAsMadePanel = false
                            markAsMadeRating = 0
                            markAsMadeNotes = ""
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 15, weight: .semibold))
                            Text("Save to History").font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(COLOR_CHARCOAL)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Error + Toast

    private var errorState: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 44)).foregroundColor(COLOR_WARM_AMBER)
            Text("Cocktail not found").font(.system(size: 16, weight: .medium)).foregroundColor(COLOR_TEXT_SECONDARY)
        }
    }

    private var shoppingListToast: some View {
        Group {
            if showShoppingListToast {
                HStack(spacing: 10) {
                    Image(systemName: "cart.badge.plus").foregroundColor(COLOR_WARM_AMBER)
                    Text("Added to shopping list").font(.system(size: 14, weight: .medium)).foregroundColor(COLOR_TEXT_PRIMARY)
                }
                .padding(.horizontal, 20).padding(.vertical, 13)
                .background(COLOR_CHARCOAL_LIGHT).cornerRadius(24)
                .shadow(color: .black.opacity(0.5), radius: 12)
                .padding(.bottom, 36)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Sheet Router

    @ViewBuilder
    private func sheetContent(_ sheet: DetailsSheet) -> some View {
        if let details = cocktailDetails {
            switch sheet {
            case .markAsMade:
                EmptyView()
            case .batchCalculator:
                BatchCalculatorView(drink: details)
            case .substitutions:
                SubstitutionSuggestionsView(drink: details)
            case .addToCollection:
                AddToCollectionView(drinkId: details.idDrink, drinkName: details.strDrink, drinkThumb: details.strDrinkThumb)
            case .videoMix:
                DetailsSubView(cocktailDetails: details, tagArray: tagArray ?? [])
            case .paywall(let feature):
                PaywallView(feature: feature, source: "details")
            }
        }
    }

    // MARK: - Helpers

    private func buildIngredients(from details: DrinkDetails) -> [(String, String?)] {
        let pairs: [(String?, String?)] = [
            (details.strIngredient1, details.strMeasure1), (details.strIngredient2, details.strMeasure2),
            (details.strIngredient3, details.strMeasure3), (details.strIngredient4, details.strMeasure4),
            (details.strIngredient5, details.strMeasure5), (details.strIngredient6, details.strMeasure6),
            (details.strIngredient7, details.strMeasure7), (details.strIngredient8, details.strMeasure8),
            (details.strIngredient9, details.strMeasure9), (details.strIngredient10, details.strMeasure10),
            (details.strIngredient11, details.strMeasure11), (details.strIngredient12, details.strMeasure12),
            (details.strIngredient13, details.strMeasure13), (details.strIngredient14, details.strMeasure14),
            (details.strIngredient15, details.strMeasure15),
        ]
        return pairs.compactMap { name, measure in
            guard let n = name, !n.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            let m = measure.flatMap { s -> String? in let t = s.trimmingCharacters(in: .whitespaces); return t.isEmpty ? nil : t }
            return (n, m)
        }
    }

    private struct GroupedIngredients {
        var alcohol: [(String, String?)] = []
        var mixer: [(String, String?)] = []
        var garnish: [(String, String?)] = []
        var other: [(String, String?)] = []
    }

    private func groupIngredients(_ pairs: [(String, String?)]) -> GroupedIngredients {
        var result = GroupedIngredients()
        let garnishWords = ["garnish", "twist", "slice", "wedge", "sprig", "peel", "zest", "wheel", "leaf", "cherry", "olive", "rim", "dried"]
        let mixerWords = ["juice", "soda", "water", "syrup", "bitters", "cream", "milk", "cola", "ginger beer", "tonic", "lemonade", "tea", "coffee", "puree", "cider", "grenadine"]
        for pair in pairs {
            let n = pair.0.lowercased()
            if garnishWords.contains(where: { n.contains($0) }) { result.garnish.append(pair) }
            else if mixerWords.contains(where: { n.contains($0) }) { result.mixer.append(pair) }
            else { result.alcohol.append(pair) }
        }
        return result
    }

    private func isAlcoholicIngredient(_ name: String) -> Bool {
        let n = name.lowercased()
        let nonAlcoholic = ["juice", "soda", "water", "syrup", "cream", "milk", "cola", "tonic",
                            "lemonade", "tea", "coffee", "garnish", "twist", "slice", "wedge",
                            "sprig", "peel", "cherry", "olive", "bitters", "grenadine", "dried"]
        return !nonAlcoholic.contains(where: { n.contains($0) })
    }

    private func strengthLabel(_ score: Int) -> String {
        switch score {
        case 0: return "None"
        case 1: return "Light"
        case 2...3: return "Medium"
        case 4: return "Strong"
        default: return "Killer"
        }
    }

    private func complexityLabel(_ score: Int) -> String {
        switch score {
        case 0...3: return "Simple"
        case 4...6: return "Medium"
        case 7...8: return "Hard"
        default: return "Expert"
        }
    }

    private func parseInstructions(_ text: String) -> [String] {
        text.components(separatedBy: ". ")
            .flatMap { $0.components(separatedBy: "\n") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count > 5 }
    }

    func addToFavorites(detail: DrinkDetails) -> Ingredient {
        Ingredient(name: detail.strDrink, image: detail.strDrinkThumb ?? "", type: .alcohol, category: detail.strCategory)
    }

    func removeFromFavorites() -> Int {
        LocalStorageManager.shared.retrieveFavoriteItems().firstIndex(where: { $0.name == cocktail }) ?? -1
    }

    func extractIngredients(from details: DrinkDetails) -> [String] {
        [details.strIngredient1, details.strIngredient2, details.strIngredient3,
         details.strIngredient4, details.strIngredient5, details.strIngredient6,
         details.strIngredient7, details.strIngredient8, details.strIngredient9,
         details.strIngredient10, details.strIngredient11, details.strIngredient12,
         details.strIngredient13, details.strIngredient14, details.strIngredient15]
            .compactMap { $0 }.filter { !$0.isEmpty }
    }

    func getMissingIngredientsCount(details: DrinkDetails) -> Int {
        let cab = LocalStorageManager.shared.retrieveTopShelfItems().map { $0.lowercased() }
        return extractIngredients(from: details).filter { ing in
            let n = ing.lowercased()
            return !cab.contains(where: { $0.contains(n) || n.contains($0) })
        }.count
    }
}


struct DetailsSubView: View {
    @State var cocktailDetails: DrinkDetails
    @State var tagArray: [String]
    var body: some View {
        if cocktailDetails.strVideo != nil {
            WebVideoView(urlString: cocktailDetails.strVideo!).frame(height: .infinity)
        }
    }
}

// MARK: - Mark as Made Sheet
struct MarkAsMadeSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var historyManager = CocktailHistoryManager.shared

    let cocktailName: String
    let drinkId: String
    let ingredients: [String]

    @State private var rating: Int = 0
    @State private var notes: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // ── Identity ──────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 6) {
                            Text("LOGGING")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            Text(cocktailName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            let count = historyManager.getCocktailCount(for: cocktailName)
                            if count > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 11))
                                    Text("Made \(count) time\(count == 1 ? "" : "s") before")
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(COLOR_WARM_AMBER)
                            }
                        }

                        // ── Rating ────────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            Text("RATING")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            HStack(spacing: 18) {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        rating = (rating == star) ? 0 : star
                                    } label: {
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .font(.system(size: 30))
                                            .foregroundColor(star <= rating ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.35))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        // ── Notes ─────────────────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOTES")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                                .kerning(1)
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("How did it turn out?")
                                        .font(.system(size: 15))
                                        .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.5))
                                        .padding(14)
                                }
                                TextEditor(text: $notes)
                                    .font(.system(size: 15))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .tint(COLOR_WARM_AMBER)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                            }
                            .frame(minHeight: 110)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(14)
                        }

                        // ── Save ──────────────────────────────────────────────
                        Button {
                            historyManager.addToHistory(
                                cocktailName: cocktailName,
                                drinkId: drinkId,
                                rating: rating > 0 ? rating : nil,
                                notes: notes.isEmpty ? nil : notes,
                                ingredients: ingredients
                            )
                            isPresented = false
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Save to History")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_WARM_AMBER)
                            .cornerRadius(14)
                        }

                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                }
            }
            .navigationTitle("Log Cocktail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
        }
    }
}

// MARK: - Extension for Drink Initializer
extension DetailsView {
    init(drink: Drink) {
        self.init(
            cocktail: drink.strDrink,
            hideCloseButton: false,
            dismiss: {}
        )
    }
}


#Preview {
    MainView()
}
