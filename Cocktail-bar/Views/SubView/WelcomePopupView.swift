//
//  WelcomePopupView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/29/24.
//

import SwiftUI

struct WelcomePopupView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @Binding var isPresented: Bool
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var subscribeToNewsletter: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome to")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text(APP_NAME)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                }
                .padding(.top, 32)
                
                Text("Let's personalize your experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Form
                VStack(spacing: 16) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Enter your name", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email (Optional)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("your@email.com", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Newsletter toggle
                    if !email.isEmpty {
                        Toggle(isOn: $subscribeToNewsletter) {
                            Text("Subscribe to cocktail recipes newsletter")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .tint(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                    }
                }
                .padding(.horizontal, 32)
                
                // Buttons
                VStack(spacing: 12) {
                    // Save button
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(colorScheme == .dark ? COLOR_SECONDARY : COLOR_PRIMARY)
                            .cornerRadius(12)
                    }
                    
                    // Skip button
                    Button(action: {
                        session.setWelcomeCompleted()
                        isPresented = false
                    }) {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "#1C1C1E") : Color.white)
            )
            .padding(40)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private func saveProfile() {
        let finalUsername = username.isEmpty ? "Guest" : username
        session.saveProfile(username: finalUsername, email: email)
        
        // TODO: Send newsletter subscription to your backend if subscribeToNewsletter is true
        if subscribeToNewsletter && !email.isEmpty {
            // Add your newsletter subscription logic here
            print("Newsletter subscription for: \(email)")
        }
        
        session.setWelcomeCompleted()
        isPresented = false
    }
}

#Preview {
    WelcomePopupView(isPresented: .constant(true))
        .environmentObject(SessionStore())
}
