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
            LinearGradient(
                gradient: colorScheme == .dark ?
                    Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings")
                            .font(.cocktailTitle)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("Personalize your experience")
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    
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
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                TextField("Enter your name", text: $username)
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .padding(12)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(8)
                                    .autocapitalization(.words)
                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.ingredientText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                TextField("your@email.com", text: $email)
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .padding(12)
                                    .background(COLOR_CHARCOAL_LIGHT)
                                    .cornerRadius(8)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                        }
                        .padding(20)
                        .background(COLOR_CHARCOAL)
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
                    .padding(.horizontal)
                    
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
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
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
                            .background(COLOR_CHARCOAL)
                            .cornerRadius(12)
                            
                            // Experience Level
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Experience Level")
                                    .font(.ingredientText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
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
                            .background(COLOR_CHARCOAL)
                            .cornerRadius(12)
                            
                            // Quick links to detailed preference pages
                            VStack(spacing: 0) {
                                NavigationLink(destination: FavoriteSpiritsView()) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                        Text("Favorite Spirits")
                                            .font(.bodyText)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Spacer()
                                        Text("\(preferencesManager.preferences.favoriteSpirits.count)")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                                
                                NavigationLink(destination: AllergiesView()) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.red)
                                        Text("Allergies")
                                            .font(.bodyText)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Spacer()
                                        Text("\(preferencesManager.preferences.allergies.count)")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                                
                                NavigationLink(destination: DislikedIngredientsView()) {
                                    HStack {
                                        Image(systemName: "hand.thumbsdown")
                                            .foregroundColor(.orange)
                                        Text("Disliked Ingredients")
                                            .font(.bodyText)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Spacer()
                                        Text("\(preferencesManager.preferences.dislikedIngredients.count)")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(16)
                                }
                                
                                Divider().background(COLOR_TEXT_SECONDARY.opacity(0.3))
                                
                                NavigationLink(destination: DietaryRestrictionsView()) {
                                    HStack {
                                        Image(systemName: "leaf.fill")
                                            .foregroundColor(.green)
                                        Text("Dietary Restrictions")
                                            .font(.bodyText)
                                            .foregroundColor(COLOR_TEXT_PRIMARY)
                                        Spacer()
                                        Text("\(preferencesManager.preferences.dietaryRestrictions.count)")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(COLOR_TEXT_SECONDARY)
                                    }
                                    .padding(16)
                                }
                            }
                            .background(COLOR_CHARCOAL)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
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
                        .background(COLOR_CHARCOAL)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
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
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.bodyText)
                .foregroundColor(COLOR_TEXT_PRIMARY)
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
