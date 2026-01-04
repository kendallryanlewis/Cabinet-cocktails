//
//  SettingsView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/29/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @StateObject private var preferencesManager = UserPreferencesManager.shared
    @Binding var isMenuOpen: Bool
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showSavedAlert = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings")
                            .font(.cocktailTitle)
                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        Text("Personalize your experience")
                            .font(.bodyText)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                    .padding(.horizontal, 20)
                    
                    // Profile Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profile")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        VStack(spacing: 16) {
                            // Username field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.ingredientText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                TextField("Enter your name", text: $username)
                                    .font(.bodyText)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    .padding(12)
                                    .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                    .cornerRadius(8)
                                    .autocapitalization(.words)
                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.ingredientText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                TextField("your@email.com", text: $email)
                                    .font(.bodyText)
                                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                    .padding(12)
                                    .background(AdaptiveColors.secondaryCardBackground(for: colorScheme))
                                    .cornerRadius(8)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                        }
                        .padding(20)
                        .background(AdaptiveColors.cardBackground(for: colorScheme))
                        .cornerRadius(12)
                        
                        // Save button
                        Button(action: {
                            saveProfile()
                        }) {
                            Text("Save Changes")
                                .font(.bodyText)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_CHARCOAL)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(COLOR_WARM_AMBER)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preferences")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        VStack(spacing: 12) {
                            // Drink Strength
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Drink Strength Preference")
                                    .font(.ingredientText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                Picker("Preferred Strength", selection: $preferencesManager.preferences.preferredStrength) {
                                    ForEach([DrinkStrength.light, .medium, .strong, .veryStrong], id: \.self) { strength in
                                        Text(strength.rawValue).tag(strength)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: preferencesManager.preferences.preferredStrength) { _ in
                                    preferencesManager.save()
                                }
                            }
                            .padding(16)
                            .background(AdaptiveColors.cardBackground(for: colorScheme))
                            .cornerRadius(12)
                            
                            // Experience Level
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Experience Level")
                                    .font(.ingredientText)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                Picker("Your Experience", selection: $preferencesManager.preferences.experienceLevel) {
                                    ForEach([DifficultyLevel.beginner, .intermediate, .advanced, .expert], id: \.self) { level in
                                        Text(level.rawValue).tag(level)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: preferencesManager.preferences.experienceLevel) { _ in
                                    preferencesManager.save()
                                }
                            }
                            .padding(16)
                            .background(AdaptiveColors.cardBackground(for: colorScheme))
                            .cornerRadius(12)
                            
                            // Quick links to detailed preference pages
                            VStack(spacing: 0) {
                                NavigationLink(destination: FavoriteSpiritsView()) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                        Text("Favorite Spirits")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        Spacer()
                                        Text("\(preferencesManager.preferences.favoriteSpirits.count)")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(AdaptiveColors.textSecondary(for: colorScheme).opacity(0.3))
                                
                                NavigationLink(destination: AllergiesView()) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text("Allergies")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        Spacer()
                                        Text("\(preferencesManager.preferences.allergies.count)")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(AdaptiveColors.textSecondary(for: colorScheme).opacity(0.3))
                                
                                NavigationLink(destination: DislikedIngredientsView()) {
                                    HStack {
                                        Image(systemName: "hand.thumbsdown")
                                            .foregroundColor(.orange)
                                        Text("Disliked Ingredients")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        Spacer()
                                        Text("\(preferencesManager.preferences.dislikedIngredients.count)")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(AdaptiveColors.textSecondary(for: colorScheme).opacity(0.3))
                                
                                NavigationLink(destination: DietaryRestrictionsView()) {
                                    HStack {
                                        Image(systemName: "leaf.fill")
                                            .foregroundColor(.green)
                                        Text("Dietary Restrictions")
                                            .font(.bodyText)
                                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                        Spacer()
                                        Text("\(preferencesManager.preferences.dietaryRestrictions.count)")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    }
                                    .padding(16)
                                }
                            }
                            .background(AdaptiveColors.cardBackground(for: colorScheme))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Information")
                            .font(.sectionHeader)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        VStack(spacing: 0) {
                            SettingsRow(title: "Version", value: "1.0.0")
                            Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                            SettingsRow(title: "Total Cocktails", value: "\(DrinkManager.shared.allDrinks?.count ?? 0)")
                            Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                            SettingsRow(title: "Your Cabinet", value: "\(LocalStorageManager.shared.retrieveTopShelfItems().count)")
                            Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                            SettingsRow(title: "Favorites", value: "\(LocalStorageManager.shared.retrieveFavoriteItems().count)")
                        }
                        .padding(20)
                        .background(AdaptiveColors.cardBackground(for: colorScheme))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 60)
                }
            }
        }
        .onAppear {
            // Load current values
            username = session.username
            email = session.email
        }
        .alert("Profile Updated", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been saved successfully.")
        }
    }
    
    private func saveProfile() {
        let finalUsername = username.isEmpty ? "Guest" : username
        session.saveProfile(username: finalUsername, email: email)
        showSavedAlert = true
    }
}

struct SettingsRow: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.bodyText)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
            Spacer()
            Text(value)
                .font(.bodyText)
                .fontWeight(.semibold)
                .foregroundColor(COLOR_WARM_AMBER)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView(isMenuOpen: .constant(false))
        .environmentObject(SessionStore())
}
