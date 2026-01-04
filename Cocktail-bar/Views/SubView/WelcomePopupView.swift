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
    @State private var hasAppeared: Bool = false
    
    var body: some View {
        ZStack {
            // Background using unified app background
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header with icon
                    VStack(spacing: 20) {
                        // App icon/logo area
                        ZStack {
                            Circle()
                                .fill(AdaptiveColors.cardBackground(for: colorScheme))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "wineglass.fill")
                                .font(.displayLarge)
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .opacity(hasAppeared ? 1 : 0)
                        .scaleEffect(hasAppeared ? 1 : 0.8)
                        
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            Text(APP_NAME)
                                .font(.cocktailTitle)
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                    }
                    .padding(.top, 60)
                    
                    // Subtitle
                    Text("Let's personalize your experience")
                        .font(.bodyText)
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                    
                    // Form Card
                    VStack(spacing: 24) {
                        // Username field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.ingredientText)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            
                            TextField("Enter your name", text: $username)
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AdaptiveColors.background(for: colorScheme))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(COLOR_WARM_AMBER.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .autocapitalization(.words)
                        }
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Email (Optional)")
                                .font(.ingredientText)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                            
                            TextField("your@email.com", text: $email)
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AdaptiveColors.background(for: colorScheme))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(COLOR_WARM_AMBER.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Newsletter toggle
                        if !email.isEmpty {
                            HStack(spacing: 12) {
                                Toggle("", isOn: $subscribeToNewsletter)
                                    .labelsHidden()
                                    .tint(COLOR_WARM_AMBER)
                                
                                Text("Subscribe to cocktail recipes newsletter")
                                    .font(.caption)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AdaptiveColors.cardBackground(for: colorScheme))
                    )
                    .padding(.horizontal, 20)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 30)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Get Started button
                        Button(action: {
                            saveProfile()
                        }) {
                            HStack(spacing: 10) {
                                Text("Get Started")
                                    .font(.buttonText)
                                Image(systemName: "arrow.right")
                                    .font(.buttonSmall)
                            }
                            .foregroundColor(colorScheme == .dark ? COLOR_CHARCOAL : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(COLOR_WARM_AMBER)
                            )
                        }
                        
                        // Skip button
                        Button(action: {
                            session.setWelcomeCompleted()
                            isPresented = false
                        }) {
                            Text("Skip for now")
                                .font(.bodyText)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 24)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 30)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                hasAppeared = true
            }
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
