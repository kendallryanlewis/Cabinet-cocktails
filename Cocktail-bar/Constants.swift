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

// Legacy colors (kept for backward compatibility during transition)
let COLOR_PRIMARY = COLOR_WARM_AMBER // Map old to new
let COLOR_SECONDARY = COLOR_WARM_AMBER // Map old to new
let COLOR_GOLD = Color(hex:"#8c5c29")
let LINEAR_TOP = COLOR_CHARCOAL
let LINEAR_BOTTOM = COLOR_CHARCOAL
let LIGHT_LINEAR_TOP = Color(hex: "FBF4E9")
let LIGHT_LINEAR_BOTTOM = Color(hex: "#DFD8CC")
let LOGO_FULL = "VM-graphiclogo-circle"

// Typography System - Modern Editorial Style
extension Font {
    // Serif fonts for cocktail names and section headers (editorial feel)
    static let cocktailTitle = Font.system(size: 32, weight: .bold, design: .serif)
    static let sectionHeader = Font.system(size: 24, weight: .semibold, design: .serif)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .serif)
    
    // Sans-serif for UI and body text (clarity and precision)
    static let bodyText = Font.system(size: 16, weight: .regular, design: .rounded)
    static let ingredientText = Font.system(size: 14, weight: .medium, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // UI elements
    static let buttonText = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let navTitle = Font.system(size: 20, weight: .bold, design: .rounded)
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

