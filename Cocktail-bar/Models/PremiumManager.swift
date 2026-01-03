//
//  PremiumManager.swift
//  Cocktail-bar
//
//  Manages in-app purchases, subscriptions, and premium feature access
//

import Foundation
import StoreKit
import Combine

// MARK: - Product Identifiers
enum ProductID: String, CaseIterable {
    // One-Time Purchases
    case proLifetime = "com.cocktailbar.pro.lifetime"
    
    // Subscriptions
    case monthlySubscription = "com.cocktailbar.subscription.monthly"
    case annualSubscription = "com.cocktailbar.subscription.annual"
    
    // Feature Packs
    case essentialPack = "com.cocktailbar.pack.essential"
    case creatorPack = "com.cocktailbar.pack.creator"
    case professionalPack = "com.cocktailbar.pack.professional"
    
    var displayName: String {
        switch self {
        case .proLifetime: return "Cocktail Bar Pro"
        case .monthlySubscription: return "Premium Monthly"
        case .annualSubscription: return "Premium Annual"
        case .essentialPack: return "Essential Pack"
        case .creatorPack: return "Creator Pack"
        case .professionalPack: return "Professional Pack"
        }
    }
    
    var description: String {
        switch self {
        case .proLifetime:
            return "Lifetime access to all premium features"
        case .monthlySubscription:
            return "Monthly access to all premium features"
        case .annualSubscription:
            return "Annual access to all premium features (Save 50%)"
        case .essentialPack:
            return "Unlimited storage and offline mode"
        case .creatorPack:
            return "Custom recipe creator and sharing"
        case .professionalPack:
            return "Cost tracking and batch calculator"
        }
    }
}

// MARK: - Premium Feature
enum PremiumFeature {
    case unlimitedCabinet
    case unlimitedFavorites
    case unlimitedCollections
    case offlineMode
    case customRecipes
    case costTracking
    case batchCalculator
    case advancedSearch
    case exportFeatures
    case educationalContent
    case ingredientSubstitutions
    case seasonalContent
    case shoppingList
    case expirationTracking
}

// MARK: - Premium Manager
@MainActor
class PremiumManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProducts: Set<String> = []
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var activeSubscription: Product.SubscriptionInfo.Status?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    private let FREE_CABINET_LIMIT = 20
    private let FREE_FAVORITES_LIMIT = 10
    private let FREE_COLLECTIONS_LIMIT = 1
    
    // MARK: - Initialization
    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            let loadedProducts = try await Product.products(for: productIDs)
            
            // Sort products by type and price
            products = loadedProducts.sorted { product1, product2 in
                if product1.type != product2.type {
                    return product1.type.rawValue < product2.type.rawValue
                }
                return product1.price < product2.price
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
            print("❌ Error loading products: \(error)")
        }
    }
    
    // MARK: - Purchase Handling
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            isLoading = false
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Update purchased products
                await updatePurchasedProducts()
                
                // Finish the transaction
                await transaction.finish()
                
                return transaction
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                return nil
                
            case .pending:
                print("⏳ Purchase pending approval")
                return nil
                
            @unknown default:
                print("⚠️ Unknown purchase result")
                return nil
            }
        } catch {
            isLoading = false
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            isLoading = false
            print("❌ Error restoring purchases: \(error)")
        }
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Add to purchased products
                purchased.insert(transaction.productID)
                
                // Check if it's an active subscription
                if transaction.productType == .autoRenewable {
                    if let subscription = products.first(where: { $0.id == transaction.productID })?.subscription {
                        let status = try await subscription.status.first
                        if case .verified(let renewalInfo) = status?.renewalInfo,
                           case .verified(let transaction) = status?.transaction,
                           renewalInfo.willAutoRenew || transaction.expirationDate ?? Date() > Date() {
                            activeSubscription = status
                        }
                    }
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }
        
        purchasedProducts = purchased
        updatePremiumStatus()
    }
    
    // MARK: - Premium Status
    private func updatePremiumStatus() {
        // User is premium if they have:
        // 1. Lifetime Pro purchase
        // 2. Active subscription
        // 3. Complete bundle
        
        let hasLifetimePro = purchasedProducts.contains(ProductID.proLifetime.rawValue)
        let hasActiveSubscription = activeSubscription != nil
        
        isPremium = hasLifetimePro || hasActiveSubscription
    }
    
    // MARK: - Transaction Verification
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    
                    await self.updatePurchasedProducts()
                    
                    await transaction.finish()
                } catch {
                    print("❌ Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Feature Access Checks
    
    /// Check if user has access to unlimited cabinet
    func hasUnlimitedCabinet() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.essentialPack.rawValue)
    }
    
    /// Check cabinet limit for free users
    func canAddToCabinet(currentCount: Int) -> Bool {
        if hasUnlimitedCabinet() {
            return true
        }
        return currentCount < FREE_CABINET_LIMIT
    }
    
    /// Get cabinet limit
    func getCabinetLimit() -> Int? {
        return hasUnlimitedCabinet() ? nil : FREE_CABINET_LIMIT
    }
    
    /// Check if user has access to unlimited favorites
    func hasUnlimitedFavorites() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.essentialPack.rawValue)
    }
    
    /// Check favorites limit for free users
    func canAddToFavorites(currentCount: Int) -> Bool {
        if hasUnlimitedFavorites() {
            return true
        }
        return currentCount < FREE_FAVORITES_LIMIT
    }
    
    /// Get favorites limit
    func getFavoritesLimit() -> Int? {
        return hasUnlimitedFavorites() ? nil : FREE_FAVORITES_LIMIT
    }
    
    /// Check if user has access to unlimited collections
    func hasUnlimitedCollections() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.essentialPack.rawValue)
    }
    
    /// Check collections limit for free users
    func canCreateCollection(currentCount: Int) -> Bool {
        if hasUnlimitedCollections() {
            return true
        }
        return currentCount < FREE_COLLECTIONS_LIMIT
    }
    
    /// Get collections limit
    func getCollectionsLimit() -> Int? {
        return hasUnlimitedCollections() ? nil : FREE_COLLECTIONS_LIMIT
    }
    
    /// Check if user can access offline mode
    func canAccessOfflineMode() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.essentialPack.rawValue)
    }
    
    /// Check if user can create custom recipes
    func canCreateCustomRecipes() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.creatorPack.rawValue)
    }
    
    /// Check if user can access cost tracking
    func canAccessCostTracking() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.professionalPack.rawValue)
    }
    
    /// Check if user can use batch calculator
    func canUseBatchCalculator() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.professionalPack.rawValue)
    }
    
    /// Check if user can export recipes
    func canExportRecipes() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.creatorPack.rawValue)
    }
    
    /// Check if user can access advanced search
    func canAccessAdvancedSearch() -> Bool {
        return isPremium
    }
    
    /// Check if user can access educational content
    func canAccessEducationalContent() -> Bool {
        return isPremium
    }
    
    /// Check if user can access ingredient substitutions
    func canAccessIngredientSubstitutions() -> Bool {
        return isPremium
    }
    
    /// Check if user can access seasonal content
    func canAccessSeasonalContent() -> Bool {
        return isPremium
    }
    
    /// Check if user can access shopping list
    func canAccessShoppingList() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.professionalPack.rawValue)
    }
    
    /// Check if user can access expiration tracking
    func canAccessExpirationTracking() -> Bool {
        return isPremium || purchasedProducts.contains(ProductID.professionalPack.rawValue)
    }
    
    /// Check if user has access to specific feature
    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .unlimitedCabinet:
            return hasUnlimitedCabinet()
        case .unlimitedFavorites:
            return hasUnlimitedFavorites()
        case .unlimitedCollections:
            return hasUnlimitedCollections()
        case .offlineMode:
            return canAccessOfflineMode()
        case .customRecipes:
            return canCreateCustomRecipes()
        case .costTracking:
            return canAccessCostTracking()
        case .batchCalculator:
            return canUseBatchCalculator()
        case .advancedSearch:
            return canAccessAdvancedSearch()
        case .exportFeatures:
            return canExportRecipes()
        case .educationalContent:
            return canAccessEducationalContent()
        case .ingredientSubstitutions:
            return canAccessIngredientSubstitutions()
        case .seasonalContent:
            return canAccessSeasonalContent()
        case .shoppingList:
            return canAccessShoppingList()
        case .expirationTracking:
            return canAccessExpirationTracking()
        }
    }
    
    // MARK: - Product Helpers
    
    /// Get product by ID
    func product(for id: ProductID) -> Product? {
        return products.first { $0.id == id.rawValue }
    }
    
    /// Check if product is purchased
    func isPurchased(_ productID: ProductID) -> Bool {
        return purchasedProducts.contains(productID.rawValue)
    }
    
    /// Get subscription status text
    func subscriptionStatusText() -> String? {
        guard let subscription = activeSubscription else {
            return nil
        }
        
        switch subscription.state {
        case .subscribed:
            return "Active"
        case .expired:
            return "Expired"
        case .inGracePeriod:
            return "Grace Period"
        case .inBillingRetryPeriod:
            return "Billing Issue"
        case .revoked:
            return "Revoked"
        default:
            return nil
        }
    }
}

// MARK: - Store Error
enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
