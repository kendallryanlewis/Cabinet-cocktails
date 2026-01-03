//
//  PremiumGateView.swift
//  Cocktail-bar
//
//  Premium feature gate wrapper
//

import SwiftUI

struct PremiumGateView<Content: View>: View {
    @EnvironmentObject var premiumManager: PremiumManager
    let feature: PremiumFeature
    let source: String
    let content: Content
    
    @State private var showPaywall = false
    
    init(feature: PremiumFeature, source: String = "general", @ViewBuilder content: () -> Content) {
        self.feature = feature
        self.source = source
        self.content = content()
    }
    
    var body: some View {
        Group {
            if premiumManager.hasAccess(to: feature) {
                content
            } else {
                lockedView
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: feature, source: source)
                .environmentObject(premiumManager)
        }
    }
    
    private var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(COLOR_WARM_AMBER)
            
            Text("Premium Feature")
                .font(.title2.bold())
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            Text(featureDescription)
                .font(.body)
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showPaywall = true
            } label: {
                Text("Unlock Premium")
                    .font(.headline)
                    .foregroundColor(COLOR_CHARCOAL)
                    .frame(maxWidth: 200)
                    .padding()
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [COLOR_CHARCOAL, COLOR_CHARCOAL_LIGHT]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var featureDescription: String {
        switch feature {
        case .unlimitedCabinet:
            return "Upgrade to add unlimited ingredients to your cabinet"
        case .unlimitedFavorites:
            return "Upgrade to save unlimited favorite cocktails"
        case .unlimitedCollections:
            return "Upgrade to create unlimited collections"
        case .offlineMode:
            return "Upgrade to access recipes offline"
        case .customRecipes:
            return "Upgrade to create and share your own recipes"
        case .costTracking:
            return "Upgrade to track ingredient costs and budget"
        case .batchCalculator:
            return "Upgrade to scale recipes for parties"
        case .advancedSearch:
            return "Upgrade for advanced search filters"
        case .exportFeatures:
            return "Upgrade to export recipes as PDFs"
        case .educationalContent:
            return "Upgrade to access all educational content"
        case .ingredientSubstitutions:
            return "Upgrade for smart ingredient substitutions"
        case .seasonalContent:
            return "Upgrade to access exclusive seasonal cocktails"
        case .shoppingList:
            return "Upgrade to use the shopping list"
        case .expirationTracking:
            return "Upgrade to track ingredient expiration"
        }
    }
}

// MARK: - Premium Badge
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption2)
            Text("PRO")
                .font(.caption2.bold())
        }
        .foregroundColor(COLOR_CHARCOAL)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(COLOR_WARM_AMBER)
        .cornerRadius(4)
    }
}

// MARK: - Limit Warning Banner
struct LimitWarningBanner: View {
    let message: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(COLOR_WARM_AMBER)
                    Text("Limit Reached")
                        .font(.headline)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                }
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            Spacer()
            
            Button(action: action) {
                Text("Upgrade")
                    .font(.caption.bold())
                    .foregroundColor(COLOR_CHARCOAL)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
