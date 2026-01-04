//
//  Constants.swift
//  Sneakers App
//
//  Created by Kendall Lewis on 9/9/21.
//

import SwiftUI

let API_URL = "https://www.thecocktaildb.com/api/json/v2/9973533/"
let WEBSITE_URL = "https://www.kndl-inc.com/"

// Default App
let COMPANY_NAME = "KNDL"
let APP_NAME = "Cabinet Cocktails"

//Default Colors - Modern Dark Theme
let COLOR_WARM_AMBER = Color(hex: "#D4A574") // Warm accent for buttons, active states, highlights
let COLOR_CHARCOAL = Color(hex: "#1C1C1E") // Primary dark background
let COLOR_CHARCOAL_LIGHT = Color(hex: "#2C2C2E") // Cards, panels, elevated surfaces
let COLOR_TEXT_PRIMARY = Color(hex: "#FFFFFF") // Primary text
let COLOR_TEXT_SECONDARY = Color(hex: "#8E8E93") // Secondary text, captions

// Light Mode Colors
let COLOR_LIGHT_BACKGROUND = Color(hex: "#F5F0E8") // Light warm cream background
let COLOR_LIGHT_CARD = Color(hex: "#F5F0E8") // Tanish cards for light mode
let COLOR_LIGHT_TEXT_PRIMARY = Color(hex: "#1C1C1E") // Dark text for light mode
let COLOR_LIGHT_TEXT_SECONDARY = Color(hex: "#6B6B6B") // Secondary text for light mode

// Menu Background Colors (optimized for text readability)
let COLOR_MENU_DARK = Color(hex: "#1A1A1C") // Slightly darker charcoal for dark mode menu
let COLOR_MENU_LIGHT = Color(hex: "#3A3530") // Warm medium-dark brown for light mode menu

// Legacy colors (kept for backward compatibility during transition)
let COLOR_PRIMARY = COLOR_WARM_AMBER // Map old to new
let COLOR_SECONDARY = COLOR_WARM_AMBER // Map old to new
let COLOR_GOLD = Color(hex:"#8c5c29")
let LINEAR_TOP = COLOR_CHARCOAL
let LINEAR_BOTTOM = COLOR_CHARCOAL
let LIGHT_LINEAR_TOP = Color(hex: "FBF4E9")
let LIGHT_LINEAR_BOTTOM = Color(hex: "#DFD8CC")
let LOGO_FULL = "VM-graphiclogo-circle"

// MARK: - Layout Constants
// Standard padding values for consistent spacing throughout the app
struct LayoutConstants {
    static let screenHorizontalPadding: CGFloat = 20 // Standard horizontal padding from screen edges
    static let sectionSpacing: CGFloat = 32 // Space between major sections
    static let cardPadding: CGFloat = 20 // Padding inside cards
    static let elementSpacing: CGFloat = 16 // Space between related elements
    static let minimumBottomPadding: CGFloat = 80 // Bottom padding for scrollable content
}

// MARK: - Adaptive Color Helpers
// These provide automatic dark/light mode adaptation
struct AdaptiveColors {
    static func background(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? COLOR_CHARCOAL : COLOR_LIGHT_BACKGROUND
    }
    
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? COLOR_CHARCOAL_LIGHT : COLOR_LIGHT_CARD
    }
    
    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? COLOR_TEXT_PRIMARY : COLOR_LIGHT_TEXT_PRIMARY
    }
    
    static func textSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? COLOR_TEXT_SECONDARY : COLOR_LIGHT_TEXT_SECONDARY
    }
    
    // Helper for secondary card backgrounds (e.g., input fields, inner containers)
    static func secondaryCardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? COLOR_CHARCOAL_LIGHT : Color(hex: "#E8E1D5") // Slightly darker tan for light mode
    }
}

// Typography System - Modern Style (Unified)
extension Font {
    // Large display titles
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 32, weight: .bold, design: .default)
    
    // Titles and headers
    static let cocktailTitle = Font.system(size: 32, weight: .bold, design: .default)
    static let sectionHeader = Font.system(size: 24, weight: .semibold, design: .default)
    static let cardTitle = Font.system(size: 18, weight: .semibold, design: .default)
    static let navTitle = Font.system(size: 20, weight: .bold, design: .default)
    
    // Body and content text
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyText = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // Supporting text
    static let ingredientText = Font.system(size: 14, weight: .medium, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)
    
    // UI elements
    static let buttonText = Font.system(size: 16, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default)
    
    // Icons and special elements
    static let iconLarge = Font.system(size: 60, weight: .regular, design: .default)
    static let iconMedium = Font.system(size: 48, weight: .regular, design: .default)
    static let iconSmall = Font.system(size: 32, weight: .regular, design: .default)
    static let iconMini = Font.system(size: 24, weight: .regular, design: .default)
}

// Login | Registration Page
let TEXT_CREATE_AN_ACCOUNT = "Create an Account"
let TEXT_LOGIN_AN_ACCOUNT = "Login"
let TEXT_USERNAME = "Username"
let TEXT_EMAIL = "Email"
let TEXT_PASSWORD = "Password"
let TEXT_CONFRIM_PASSWORD = "Confirm Password"
let TEXT_TERMS_APPLY_TAG = "By creating an account you agree to our Terms of Service and Privacy Policy"
let TEXT_NEED_AN_ACCOUNT = "Don't have an account?"
let TEXT_SIGN_IN = "Sign in!"
let TEXT_SIGN_UP = "Sign up!"
let TEXT_CONSENT = "Agree and Continue"

// Generic Texts
let TEXT_DONE = "Done"
let SEARCH_TEXT = "Search All Drinks"

//Mixology Page
let MIXOLOGY_TEXT = "Mixology"
let MIXOLOGY_DESCRIPTION_TEXT = "It appears you have multiple cocktail options available. Click to view the complete list."
let VIEW_CART = "View Cabinet"
let COMBINATION_ERROR = "No Options available"

//Top shelf view
let TOPSHELF_TEXT = "Top Shelf"
let CABINET_TEXT = "Cabinet"
let ADD_REMOVE_CABINET = "Add and remove spirits to your collection."
let SEARCH_SHELF = "Add to cabinet"
let SEARCH_SHELF_RESULTS = "View Results"

//Logos
let IMAGE_LOGO = "AppIcon"
let IMAGE_USER_PLACEHOLDER = "user-placeholder"
let IMAGE_PHOTO = "plus.circle"

//Search / Quick mix
let QUICK_MIX_TEXT = "Quick Mix"
let QUICK_MIX_DESCRIPTION_TEXT = "Add the ingredients to see what drinks can be made with your selections."
let VIEW_MIXES = "View Mixes"
let VIEW_CABINET = "Add more to Cabinet"


let NO_COCKTAILS_FOUND = "Unfortunately, there are no options available for these items. Please try adding some different ingredients."
let COCKTAILS_TEXT = "Cocktails"

