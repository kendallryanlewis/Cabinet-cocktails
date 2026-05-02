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
                    Text("Your cocktail companion is ready to pour.")
                        .font(.bodyText)
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Get Started button
                        Button(action: {
                            session.setWelcomeCompleted()
                            isPresented = false
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
}

#Preview {
    WelcomePopupView(isPresented: .constant(true))
        .environmentObject(SessionStore())
}
