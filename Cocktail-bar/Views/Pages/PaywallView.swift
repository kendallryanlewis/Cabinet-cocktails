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
            AppBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Title
                    Text("Cabinet Cocktails Premium")
                        .font(.largeTitle.bold())
                        .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                    
                    // Plans Section
                    VStack(spacing: 30) {
                        // Monthly Plan
                        VStack(spacing: 4) {
                            Text("Monthly Plan")
                                .font(.title2.bold())
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            HStack(alignment: .bottom, spacing: 2) {
                                Text(monthlyPrice)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(COLOR_WARM_AMBER)
                                Text("/ month")
                                    .font(.title3)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    .padding(.bottom, 6)
                            }
                        }
                        
                        // Yearly Plan
                        VStack(spacing: 4) {
                            Text("Yearly Plan")
                                .font(.title2.bold())
                                .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                            HStack(alignment: .bottom, spacing: 2) {
                                Text(yearlyPrice)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(COLOR_WARM_AMBER)
                                Text("/ year")
                                    .font(.title3)
                                    .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                                    .padding(.bottom, 6)
                            }
                        }
                    }
                    
                    // Includes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Includes:")
                            .font(.title3.bold())
                            .foregroundColor(AdaptiveColors.textPrimary(for: colorScheme))
                        
                        Text("• Unlimited cabinet items")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Unlimited favorites")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Unlimited collections")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Offline mode")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Custom recipes")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Cost tracking")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Batch calculator")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        Text("• Export features")
                            .font(.body)
                            .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Legal Disclaimer
                    Text("Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. Payment is charged to your Apple ID account at confirmation of purchase.")
                        .font(.caption)
                        .foregroundColor(AdaptiveColors.textSecondary(for: colorScheme))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                    
                    // Links and Restore Purchases
                    HStack(spacing: 20) {
                        Link("Terms of Use", destination: URL(string: "https://www.kndl-inc.com/terms")!)
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .underline()
                        
                        Link("Privacy Policy", destination: URL(string: "https://kndl-inc.com/privacy")!)
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                            .underline()
                        
                        Button {
                            Task {
                                await restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.caption)
                                .foregroundColor(COLOR_WARM_AMBER)
                                .underline()
                        }
                        .disabled(isPurchasing)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
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
    
    private var monthlyPrice: String {
        if let monthly = premiumManager.sortedProducts.first(where: { $0.subscription?.subscriptionPeriod.unit == .month }) {
            return monthly.displayPrice
        }
        return "$2.99"
    }
    
    private var yearlyPrice: String {
        if let yearly = premiumManager.sortedProducts.first(where: { $0.subscription?.subscriptionPeriod.unit == .year }) {
            return yearly.displayPrice
        }
        return "$19.99"
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
                    .fill(AdaptiveColors.cardBackground(for: colorScheme))
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
