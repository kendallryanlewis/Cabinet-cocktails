//
//  AppBackground.swift
//  Cocktail-bar
//
//  Unified background component for consistent theming across all views
//

import SwiftUI

/// A unified background view that automatically adapts to light/dark mode
/// Use this in all views to ensure consistent theming throughout the app
struct AppBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        LinearGradient(
            gradient: colorScheme == .dark ?
            Gradient(colors: [.clear, COLOR_CHARCOAL.opacity(0.3), COLOR_CHARCOAL]) :
                Gradient(colors: [.clear, COLOR_LIGHT_BACKGROUND.opacity(0.3), COLOR_LIGHT_BACKGROUND]),
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

/// A card background that adapts to light/dark mode
struct CardBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colorScheme == .dark ? COLOR_CHARCOAL_LIGHT : COLOR_LIGHT_CARD)
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

/// A menu-specific background with a darker gradient that works well with light text
struct MenuBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base background
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
