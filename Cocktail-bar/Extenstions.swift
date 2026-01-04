//
//  Extenstions.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/10/23.
//

import SwiftUI

extension EdgeInsets {
    static let mainBorder = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
    static let mainTop = EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
    static let mainBottom = EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
    static let standardPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    static let smallPadding = EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    static let largePadding = EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
    
    // Consistent horizontal padding for all views
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

extension View {
    func blurBackground(style: UIBlurEffect.Style) -> some View {
        ZStack {
            self

            VisualEffectView(style: style)
                .opacity(0.9) // Adjust opacity as needed
        }
    }
    
    /// Custom placeholder modifier for TextField with custom color
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    /// Apply consistent horizontal padding across all views
    func standardHorizontalPadding() -> some View {
        self.padding(.horizontal, EdgeInsets.horizontalPadding)
    }
    
    /// Apply consistent vertical padding
    func standardVerticalPadding() -> some View {
        self.padding(.vertical, EdgeInsets.verticalPadding)
    }
    
    /// Apply consistent card padding
    func cardPadding() -> some View {
        self.padding(EdgeInsets.cardPadding)
    }
}

struct VisualEffectView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

extension Color {
    /// Create a Color from a hex color code.
    /// - Parameters:
    ///   - hex: The hex color code (e.g., "#RRGGBB" or "#AARRGGBB").
    /// - Returns: A Color instance.
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
    
    static let darkGray = Color(red: 0.33, green: 0.33, blue: 0.33)
}
extension Array {
    func combinations(ofCount count: Int) -> [[Element]] {
        guard count > 0 else { return [[]] }
        guard !isEmpty else { return [] }

        if count == 1 {
            return map { [$0] }
        } else {
            let head = self[0]
            let tail = Array(self.dropFirst())
            let withoutHead = tail.combinations(ofCount: count)
            let withHead = tail.combinations(ofCount: count - 1).map { [head] + $0 }
            return withHead + withoutHead
        }
    }
}
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var set = Set<Element>()
        var result = [Element]()
        for element in self {
            if !set.contains(element) {
                set.insert(element)
                result.append(element)
            }
        }
        return result
    }
}
extension DrinkDetails {
    func containsIngredient(_ ingredient: String) -> Bool {
        // Check if any of the drink's ingredient properties contains the provided ingredient
        let ingredientProperties = Mirror(reflecting: self).children.compactMap { $0.value as? String }
        return ingredientProperties.contains { $0 == ingredient }
    }

    
    /// Generates all possible ingredient combinations for the drink.
    func allPossibleIngredientCombinations(withIngredients ingredients: [String]) -> [[String]] {
        // Create an array to store all possible ingredient combinations
        var allCombinations: [[String]] = []
        
        // Generate combinations of different lengths
        for length in 1...ingredients.count {
            // Generate combinations of current length
            let combinations = ingredients.combinations(ofCount: length)
            for combination in combinations {
                // Check if the combination is a subset of the drink's ingredients
                if combination.allSatisfy({ self.containsIngredient($0) }) {
                    allCombinations.append(combination)
                }
            }
        }
        
        return allCombinations
    }
}
