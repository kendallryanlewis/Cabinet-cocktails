//
//  SubscriptionManagementView.swift
//  Cocktail-bar
//
//  Manage subscriptions, view premium status, and restore purchases
//

import SwiftUI
import StoreKit

struct SubscriptionManagementView: View {
    @EnvironmentObject var premiumManager: PremiumManager
    @Environment(\.dismiss) var dismiss
    @State private var showPaywall = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [COLOR_CHARCOAL, COLOR_CHARCOAL_LIGHT]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Premium Status Card
                        premiumStatusCard
                        
                        // Features Access
                        featuresAccessSection
                        
                        // Manage Subscription
                        if premiumManager.isPremium {
                            manageSubscriptionSection
                        }
                        
                        // Upgrade/Purchase Options
                        if !premiumManager.isPremium {
                            upgradeSection
                        }
                        
                        // Restore Purchases
                        restoreSection
                        
                        // Support
                        supportSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Premium Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(premiumManager)
        }
    }
    
    // MARK: - Premium Status Card
    private var premiumStatusCard: some View {
        VStack(spacing: 16) {
            // Icon
            Image(systemName: premiumManager.isPremium ? "crown.fill" : "lock.fill")
                .font(.system(size: 50))
                .foregroundColor(COLOR_WARM_AMBER)
            
            // Status
            Text(premiumManager.isPremium ? "Premium Active" : "Free Plan")
                .font(.title2.bold())
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            // Details
            if premiumManager.isPremium {
                if let statusText = premiumManager.subscriptionStatusText() {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                
                Text("You have access to all premium features")
                    .font(.body)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
            } else {
                Text("Upgrade to unlock all features")
                    .font(.body)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(16)
    }
    
    // MARK: - Features Access Section
    private var featuresAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.headline)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            VStack(spacing: 8) {
                FeatureAccessRow(
                    title: "Cabinet Items",
                    status: premiumManager.hasUnlimitedCabinet() ? "Unlimited" : "20 max",
                    isUnlocked: premiumManager.hasUnlimitedCabinet()
                )
                
                FeatureAccessRow(
                    title: "Favorites",
                    status: premiumManager.hasUnlimitedFavorites() ? "Unlimited" : "10 max",
                    isUnlocked: premiumManager.hasUnlimitedFavorites()
                )
                
                FeatureAccessRow(
                    title: "Collections",
                    status: premiumManager.hasUnlimitedCollections() ? "Unlimited" : "1 max",
                    isUnlocked: premiumManager.hasUnlimitedCollections()
                )
                
                FeatureAccessRow(
                    title: "Offline Mode",
                    status: premiumManager.canAccessOfflineMode() ? "Enabled" : "Locked",
                    isUnlocked: premiumManager.canAccessOfflineMode()
                )
                
                FeatureAccessRow(
                    title: "Custom Recipes",
                    status: premiumManager.canCreateCustomRecipes() ? "Enabled" : "Locked",
                    isUnlocked: premiumManager.canCreateCustomRecipes()
                )
                
                FeatureAccessRow(
                    title: "Cost Tracking",
                    status: premiumManager.canAccessCostTracking() ? "Enabled" : "Locked",
                    isUnlocked: premiumManager.canAccessCostTracking()
                )
                
                FeatureAccessRow(
                    title: "Batch Calculator",
                    status: premiumManager.canUseBatchCalculator() ? "Enabled" : "Locked",
                    isUnlocked: premiumManager.canUseBatchCalculator()
                )
                
                FeatureAccessRow(
                    title: "Export Features",
                    status: premiumManager.canExportRecipes() ? "Enabled" : "Locked",
                    isUnlocked: premiumManager.canExportRecipes()
                )
            }
            .padding()
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Manage Subscription Section
    private var manageSubscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manage")
                .font(.headline)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            Button {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    Task {
                        try? await AppStore.showManageSubscriptions(in: windowScene)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(COLOR_WARM_AMBER)
                    
                    Text("Manage Subscription")
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .padding()
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Upgrade Section
    private var upgradeSection: some View {
        VStack(spacing: 12) {
            Button {
                showPaywall = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                        .font(.headline)
                }
                .foregroundColor(COLOR_CHARCOAL)
                .frame(maxWidth: .infinity)
                .padding()
                .background(COLOR_WARM_AMBER)
                .cornerRadius(12)
            }
            
            Text("Unlock all features with a one-time purchase or subscription")
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Restore Section
    private var restoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Already Purchased?")
                .font(.headline)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            Button {
                Task {
                    await premiumManager.restorePurchases()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundColor(COLOR_WARM_AMBER)
                    
                    Text("Restore Purchases")
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    Spacer()
                    
                    if premiumManager.isLoading {
                        SwiftUI.ProgressView()
                            .tint(COLOR_WARM_AMBER)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }
                .padding()
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(12)
            }
            .disabled(premiumManager.isLoading)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(COLOR_WARM_AMBER)
                    
                    Text("Subscription Help")
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                .padding()
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Feature Access Row
struct FeatureAccessRow: View {
    let title: String
    let status: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.circle.fill")
                .foregroundColor(isUnlocked ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.5))
            
            Text(title)
                .foregroundColor(COLOR_TEXT_PRIMARY)
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
        }
    }
}

// MARK: - Preview
#Preview {
    SubscriptionManagementView()
        .environmentObject(PremiumManager())
}
