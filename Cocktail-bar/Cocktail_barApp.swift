//
//  Cocktail_barApp.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/13/24.
//

import SwiftUI

@main
struct Cocktail_barApp: App {
    let session = SessionStore() // Create an instance of SessionStore
    let systemSettings = SystemSettingsManager() // Create an instance of SystemSettingsManager
    @StateObject private var premiumManager = PremiumManager() // Premium features manager
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(systemSettings)
                .environmentObject(premiumManager)
        }
    }
}
