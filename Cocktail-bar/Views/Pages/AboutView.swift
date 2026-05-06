//
//  AboutView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/5/24.
//

import SwiftUI

struct AboutView: View {
    @Binding var isMenuOpen: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var showPremiumSheet = false

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // ── Header ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ABOUT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                        Text("Cabinet Cocktails")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("Your personal bartending companion")
                            .font(.system(size: 14))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 20)

                    // ── App Intro Card ──────────────────────────────────
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(COLOR_WARM_AMBER.opacity(0.14))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "wineglass.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(COLOR_WARM_AMBER)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cabinet Cocktails")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                    .font(.system(size: 13))
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                            }
                        }

                        Text("Cabinet Cocktails transforms your home bartending experience. Whether you're a cocktail aficionado or a newcomer to mixology, we help you craft delightful drinks with what you already have.")
                            .font(.system(size: 15))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .lineSpacing(5)
                    }
                    .padding(20)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)

                    // ── Upgrade to Premium Button ───────────────────────
                    Button(action: { showPremiumSheet = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                            Text("Upgrade to Premium")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    // ── What We Offer ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 14) {
                        Text("WHAT WE OFFER")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)
                            .padding(.horizontal, 20)

                        VStack(spacing: 1) {
                            AboutFeatureRow(icon: "magnifyingglass",              title: "Discover Cocktails",         subtitle: "Browse 600+ recipes from classics to modern creations")
                            AboutFeatureRow(icon: "sparkles",                     title: "Personalized Picks",         subtitle: "Get recommendations based on your cabinet")
                            AboutFeatureRow(icon: "chart.line.uptrend.xyaxis",    title: "Expand Your Skills",         subtitle: "Find cocktails just one or two ingredients away")
                            AboutFeatureRow(icon: "cart.fill",                    title: "Smart Shopping Lists",       subtitle: "Build lists from the recipes you want to make")
                            AboutFeatureRow(icon: "clock.fill",                   title: "Cocktail History",           subtitle: "Track what you've mixed and when", isLast: true)
                        }
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                        .padding(.horizontal, 20)
                    }

                    // ── Closing ─────────────────────────────────────────
                    VStack(spacing: 6) {
                        Text("Cheers 🥃")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        Text("Thanks for using Cabinet Cocktails. Here's to your next unforgettable cocktail.")
                            .font(.system(size: 14))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 48)
                }
            }
        }
        .sheet(isPresented: $showPremiumSheet) {
            SubscriptionManagementView()
        }
    }
}

// MARK: - Feature Row
struct AboutFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(COLOR_WARM_AMBER.opacity(0.14))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if !isLast {
                Divider()
                    .background(Color.white.opacity(0.06))
                    .padding(.leading, 66)
            }
        }
    }
}

// MARK: - Legacy sub-views kept for any remaining references
struct AboutFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    var body: some View {
        AboutFeatureRow(icon: icon, title: title, subtitle: description)
    }
}

struct FeaturePoint: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(COLOR_WARM_AMBER)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(COLOR_TEXT_PRIMARY)
        }
    }
}

#Preview {
    AboutView(isMenuOpen: .constant(false))
}
