//
//  AppBackground.swift
//  Cocktail-bar
//
//  Unified background component for consistent theming across all views
//

import SwiftUI

/// A unified background view — clean dark gradient
struct AppBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.clear, COLOR_CHARCOAL.opacity(0.3), COLOR_CHARCOAL]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

/// A card background — always dark
struct CardBackground: View {
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(COLOR_CHARCOAL_LIGHT)
    }
}

/// View modifier for applying consistent text colors
struct AdaptiveTextColor: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var isPrimary: Bool = true
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(
                isPrimary ?
                    AdaptiveColors.textPrimary(for: colorScheme) :
                    AdaptiveColors.textSecondary(for: colorScheme)
            )
    }
}

extension View {
    /// Apply primary text color that adapts to light/dark mode
    func adaptiveTextColor() -> some View {
        modifier(AdaptiveTextColor(isPrimary: true))
    }
    
    /// Apply secondary text color that adapts to light/dark mode
    func adaptiveSecondaryTextColor() -> some View {
        modifier(AdaptiveTextColor(isPrimary: false))
    }
}

/// A menu-specific background
struct MenuBackground: View {
    var body: some View {
        ZStack {
            AppBackground().opacity(0.7)
        }
    }
}

#Preview("Dark Mode") {
    ZStack {
        AppBackground()
        VStack(spacing: 20) {
            Text("Cabinet Cocktails")
                .font(.cocktailTitle)
                .adaptiveTextColor()
            
            Text("Your personal bartending companion")
                .font(.bodyText)
                .adaptiveSecondaryTextColor()
            
            CardBackground()
                .frame(height: 100)
                .padding()
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ZStack {
        AppBackground()
        VStack(spacing: 20) {
            Text("Cabinet Cocktails")
                .font(.cocktailTitle)
                .adaptiveTextColor()
            
            Text("Your personal bartending companion")
                .font(.bodyText)
                .adaptiveSecondaryTextColor()
            
            CardBackground()
                .frame(height: 100)
                .padding()
        }
    }
    .preferredColorScheme(.light)
}
