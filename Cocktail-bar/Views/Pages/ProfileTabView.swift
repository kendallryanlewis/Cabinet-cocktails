//
//  ProfileTabView.swift
//  Cabinet Cocktails
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var premiumManager: PremiumManager

    @Binding var showHistory:        Bool
    @Binding var showRecommendations: Bool
    @Binding var showEducational:    Bool
    @Binding var showSeasonal:       Bool
    @Binding var showPreferences:    Bool
    @Binding var showCustomRecipes:  Bool
    @Binding var showCostTracking:   Bool
    @Binding var showBarEquipment:   Bool
    @Binding var showHelp:           Bool
    @Binding var showAbout:          Bool
    @Binding var showContact:        Bool
    @Binding var showCollections:    Bool
    @Binding var showPremium:        Bool
    @Binding var showExpiration:     Bool

    private struct Item: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
        let locked: Bool
        let action: () -> Void
    }

    var body: some View {
        ZStack(alignment: .top) {
            COLOR_BACKGROUND.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // ── Header ────────────────────────────────────────────────
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(COLOR_CHARCOAL_LIGHT)
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 34))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        Text("Your Profile")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)

                        if premiumManager.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 11))
                                Text("Premium Member")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(COLOR_WARM_AMBER)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(COLOR_WARM_AMBER.opacity(0.12))
                            .clipShape(Capsule())
                        } else {
                            Button {
                                showPremium = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 11))
                                    Text("Upgrade to Premium")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundColor(COLOR_WARM_AMBER)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(COLOR_WARM_AMBER.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                    // ── Sections ──────────────────────────────────────────────
                    profileSection(title: "Library") {
                        profileRow(icon: "books.vertical.fill", title: "Collections", subtitle: "Your saved cocktails", locked: !premiumManager.hasAccess(to: .unlimitedCollections)) { if premiumManager.hasAccess(to: .unlimitedCollections) { showCollections = true } else { showPremium = true } }
                        profileRow(icon: "clock.fill", title: "History", subtitle: "Cocktails you've made", locked: !premiumManager.isPremium) { if premiumManager.isPremium { showHistory = true } else { showPremium = true } }
                        profileRow(icon: "square.and.pencil",      title: "Custom Recipes",         subtitle: "Your created drinks",    locked: !premiumManager.hasAccess(to: .customRecipes)) { if premiumManager.hasAccess(to: .customRecipes) { showCustomRecipes = true } else { showPremium = true } }
                    }

                    profileSection(title: "Discover") {
                        profileRow(icon: "sparkles",               title: "Recommendations",        subtitle: "Picks just for you",     locked: !premiumManager.isPremium) { if premiumManager.isPremium { showRecommendations = true } else { showPremium = true } }
                        profileRow(icon: "leaf.fill",              title: "Seasonal Cocktails",     subtitle: "What's trending now",    locked: !premiumManager.hasAccess(to: .seasonalContent)) { if premiumManager.hasAccess(to: .seasonalContent) { showSeasonal = true } else { showPremium = true } }
                        profileRow(icon: "graduationcap.fill",     title: "Educational",            subtitle: "Learn techniques",       locked: !premiumManager.hasAccess(to: .educationalContent)) { if premiumManager.hasAccess(to: .educationalContent) { showEducational = true } else { showPremium = true } }
                    }

                    profileSection(title: "Tools") {
                        profileRow(icon: "calendar.badge.clock",   title: "Expiration Tracking",    subtitle: "Track ingredient freshness") { showExpiration = true }
                        profileRow(icon: "dollarsign.circle.fill", title: "Cost Tracking",          subtitle: "Track your spending",    locked: !premiumManager.hasAccess(to: .costTracking)) { if premiumManager.hasAccess(to: .costTracking) { showCostTracking = true } else { showPremium = true } }
                        profileRow(icon: "fork.knife",             title: "Bar Equipment",          subtitle: "Manage your tools",      locked: !premiumManager.isPremium) { if premiumManager.isPremium { showBarEquipment = true } else { showPremium = true } }
                    }

                    profileSection(title: "Account") {
                        profileRow(icon: "gearshape.fill",           title: "Preferences",           subtitle: "App & taste settings")     { showPreferences = true }
                        profileRow(icon: "questionmark.circle.fill", title: "Help",                  subtitle: "Support & FAQs")           { showHelp = true }
                        profileRow(icon: "info.circle.fill",     title: "About",                 subtitle: "Version & legal")          { showAbout = true }
                        profileRow(icon: "envelope.fill",        title: "Contact",               subtitle: "Get in touch")             { showContact = true }
                    }

                    Spacer().frame(height: 110) // tab bar clearance
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: Helpers

    @ViewBuilder
    private func profileSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1.0)
                .padding(.leading, 4)
                .padding(.bottom, 4)
                .padding(.top, 24)

            VStack(spacing: 0) {
                content()
            }
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
        }
    }

    @ViewBuilder
    private func profileRow(icon: String, title: String, subtitle: String, locked: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(COLOR_WARM_AMBER.opacity(locked ? 0.06 : 0.14))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(locked ? COLOR_TEXT_SECONDARY : COLOR_WARM_AMBER)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(locked ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                Spacer()
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.clear)
        }
        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 66)
    }
}
