//
//  SystemSettingsManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/26/24.
//

import Foundation

import SwiftUI

class SystemSettingsManager: ObservableObject {
    @Published var LINEAR_TOP = Color(hex: "#353935")
    @Published var LINEAR_BOTTOM = Color(hex: "#28282B")
    
    init() {
        // Set the constant value based on the initial color scheme
        let colorScheme = UIApplication.shared.windows.first?.rootViewController?.traitCollection.userInterfaceStyle
        LINEAR_TOP = colorScheme == .dark ? Color(hex: "#353935") : .white
        LINEAR_BOTTOM = colorScheme == .dark ? Color(hex: "#28282B") : .white
        
        // Subscribe to changes in color scheme
        NotificationCenter.default.addObserver(self, selector: #selector(colorSchemeDidChange), name: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
    }
    
    @objc func colorSchemeDidChange() {
        let colorScheme = UIApplication.shared.windows.first?.rootViewController?.traitCollection.userInterfaceStyle
        LINEAR_TOP = colorScheme == .dark ? Color(hex: "#353935") : .white
        LINEAR_BOTTOM = colorScheme == .dark ? Color(hex: "#28282B") : .white
    }
}
