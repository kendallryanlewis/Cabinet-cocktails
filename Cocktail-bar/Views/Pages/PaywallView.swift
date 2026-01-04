//
//  PaywallView.swift
//  Cocktail-bar
//
//  Premium upgrade paywall with feature comparison and purchase options
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    let feature: PremiumFeature?
    let source: String
    
    init(feature: PremiumFeature? = nil, source: String = "general") {
        self.feature = feature
        self.source = source
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [COLOR_CHARCOAL, COLOR_CHARCOAL_LIGHT]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerSection
                    
                    // Feature Highlights
                    featuresSection
                    
                    // Pricing Options
                    if !premiumManager.products.isEmpty {
                        pricingSection
                    } else {
                        SwiftUI.ProgressView()
                            .tint(COLOR_WARM_AMBER)
                    }
                    
                    // Feature Comparison
                    comparisonSection
                    
                    // Restore Purchases
                    restoreButton
                    
                    // Footer
                    footerSection
                }
                .padding()
            }
        }
        .alert("Purchase Successful! 🎉", isPresented: $showSuccess) {
            Button("Continue") {
                dismiss()
            }
        } message: {
            Text("You now have access to all premium features. Enjoy!")
        }
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .padding()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: "crown.fill")
                .font(.iconLarge)
                .foregroundStyle(
                    LinearGradient(
                        colors: [COLOR_WARM_AMBER, COLOR_WARM_AMBER.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Title
            Text("Upgrade to Premium")
                .font(.cocktailTitle)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
            
            // Subtitle
            if let feature = feature {
                Text(featureMessage(for: feature))
                    .font(.body)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            } else {
                Text("Unlock all features and master the art of mixology")
                    .font(.body)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(icon: "infinity", title: "Unlimited Everything", description: "Cabinet, favorites, and collections")
            FeatureRow(icon: "wifi.slash", title: "Offline Mode", description: "Access recipes anywhere, anytime")
            FeatureRow(icon: "pencil.and.list.clipboard", title: "Custom Recipes", description: "Create and share your cocktails")
            FeatureRow(icon: "dollarsign.circle", title: "Cost Tracking", description: "Budget your bar expenses")
            FeatureRow(icon: "scalemass", title: "Batch Calculator", description: "Scale recipes for parties")
            FeatureRow(icon: "square.and.arrow.up", title: "Export Features", description: "Share recipes as PDFs")
            FeatureRow(icon: "graduationcap", title: "Educational Content", description: "Learn bartending techniques")
            FeatureRow(icon: "sparkles", title: "Smart Substitutions", description: "AI-powered alternatives")
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT.opacity(0.5))
        .cornerRadius(16)
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.title3.bold())
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(premiumManager.products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    isPurchasing: isPurchasing,
                    onSelect: {
                        selectedProduct = product
                    },
                    onPurchase: {
                        Task {
                            await purchaseProduct(product)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Comparison Section
    private var comparisonSection: some View {
        VStack(spacing: 16) {
            Text("Free vs Premium")
                .font(.title3.bold())
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ComparisonRow(feature: "Browse Recipes", free: true, premium: true)
                ComparisonRow(feature: "Cabinet Items", free: "20", premium: "Unlimited")
                ComparisonRow(feature: "Favorites", free: "10", premium: "Unlimited")
                ComparisonRow(feature: "Collections", free: "1", premium: "Unlimited")
                ComparisonRow(feature: "Offline Mode", free: false, premium: true)
                ComparisonRow(feature: "Custom Recipes", free: false, premium: true)
                ComparisonRow(feature: "Cost Tracking", free: false, premium: true)
                ComparisonRow(feature: "Batch Calculator", free: false, premium: true)
                ComparisonRow(feature: "Export Features", free: false, premium: true)
                ComparisonRow(feature: "Educational Content", free: "Basic", premium: "Full Access")
            }
            .padding()
            .background(COLOR_CHARCOAL_LIGHT.opacity(0.5))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Restore Button
    private var restoreButton: some View {
        Button {
            Task {
                await restorePurchases()
            }
        } label: {
            Text("Restore Purchases")
                .font(.callout)
                .foregroundColor(COLOR_WARM_AMBER)
        }
        .disabled(isPurchasing)
    }
    
    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("✓ One-time purchase, lifetime access")
                .font(.caption)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            Text("✓ All future updates included")
                .font(.caption)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            Text("✓ Cancel subscription anytime")
                .font(.caption)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Functions
    
    private func featureMessage(for feature: PremiumFeature) -> String {
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
            return "Upgrade to create custom recipes"
        case .costTracking:
            return "Upgrade to track ingredient costs"
        case .batchCalculator:
            return "Upgrade to scale recipes for parties"
        case .advancedSearch:
            return "Upgrade for advanced search filters"
        case .exportFeatures:
            return "Upgrade to export recipes and collections"
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
    
    private func purchaseProduct(_ product: Product) async {
        isPurchasing = true
        
        do {
            let transaction = try await premiumManager.purchase(product)
            
            if transaction != nil {
                showSuccess = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isPurchasing = false
    }
    
    private func restorePurchases() async {
        isPurchasing = true
        
        await premiumManager.restorePurchases()
        
        if premiumManager.isPremium {
            showSuccess = true
        } else {
            errorMessage = "No previous purchases found"
            showError = true
        }
        
        isPurchasing = false
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
            }
            
            Spacer()
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    @Environment(\.colorScheme) var colorScheme
    let product: Product
    let isSelected: Bool
    let isPurchasing: Bool
    let onSelect: () -> Void
    let onPurchase: () -> Void
    
    @State private var showDetails = false
    
    var body: some View {
        Button {
            onSelect()
            showDetails.toggle()
        } label: {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(product.displayName)
                                .font(.headline)
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            
                            if isBestValue {
                                Text("BEST VALUE")
                                    .font(.caption2.bold())
                                    .foregroundColor(COLOR_CHARCOAL)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(COLOR_WARM_AMBER)
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.title3.bold())
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        if let period = subscriptionPeriod {
                            Text(period)
                                .font(.caption2)
                                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        }
                    }
                }
                
                if showDetails {
                    Divider()
                        .background(AdaptiveColors.textSecondary(for: colorScheme).opacity(0.3))
                    
                    Text(productDetails)
                        .font(.caption)
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    onPurchase()
                } label: {
                    HStack {
                        if isPurchasing {
                            SwiftUI.ProgressView()
                                .tint(.white)
                        }
                        Text(isPurchasing ? "Processing..." : "Subscribe Now")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(COLOR_WARM_AMBER)
                    .foregroundColor(COLOR_CHARCOAL)
                    .cornerRadius(12)
                }
                .disabled(isPurchasing)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(COLOR_CHARCOAL_LIGHT.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? COLOR_WARM_AMBER : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var isBestValue: Bool {
        return product.type == .autoRenewable &&
               product.subscription?.subscriptionPeriod.unit == .year
    }
    
    private var subscriptionPeriod: String? {
        guard let subscription = product.subscription else { return nil }
        
        switch subscription.subscriptionPeriod.unit {
        case .day:
            return "per day"
        case .week:
            return "per week"
        case .month:
            return subscription.subscriptionPeriod.value == 1 ? "per month" : "per \(subscription.subscriptionPeriod.value) months"
        case .year:
            return "per year"
        @unknown default:
            return nil
        }
    }
    
    private var productDetails: String {
        if product.type == .autoRenewable {
            return "Automatically renews. Cancel anytime from your account settings."
        } else {
            return "One-time purchase with lifetime access to all premium features."
        }
    }
}

// MARK: - Comparison Row
struct ComparisonRow: View {
    @Environment(\.colorScheme) var colorScheme
    let feature: String
    let free: Any
    let premium: Any
    
    var body: some View {
        HStack {
            Text(feature)
                .font(.subheadline)
                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
            
            Spacer()
            
            // Free column
            comparisonValue(free)
                .frame(width: 80)
            
            // Premium column
            comparisonValue(premium)
                .frame(width: 80)
        }
    }
    
    @ViewBuilder
    private func comparisonValue(_ value: Any) -> some View {
        if let bool = value as? Bool {
            Image(systemName: bool ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(bool ? COLOR_WARM_AMBER : AdaptiveColors.textSecondary(for: colorScheme).opacity(0.5))
        } else if let string = value as? String {
            Text(string)
                .font(.caption)
                .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
        .environmentObject(PremiumManager())
}
