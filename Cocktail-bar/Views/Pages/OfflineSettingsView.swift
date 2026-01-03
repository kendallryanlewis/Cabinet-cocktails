//
//  OfflineSettingsView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct OfflineSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var cacheManager = OfflineCacheManager.shared
    @State private var showClearCacheAlert = false
    @State private var isCachingFavorites = false
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: cacheManager.isOfflineMode ? "wifi.slash" : "wifi")
                                .font(.system(size: 60))
                                .foregroundColor(cacheManager.isOfflineMode ? .orange : COLOR_WARM_AMBER)
                            
                            Text("Offline Mode")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            Text(cacheManager.isOfflineMode ? "No internet connection" : "Connected to internet")
                                .font(.subheadline)
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        
                        // Sync Status Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: syncStatusIcon)
                                    .foregroundColor(syncStatusColor)
                                Text("Sync Status")
                                    .font(.headline)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                Spacer()
                                Text(syncStatusText)
                                    .font(.subheadline)
                                    .foregroundColor(syncStatusColor)
                            }
                            
                            if let lastSync = cacheManager.lastSyncDate {
                                HStack {
                                    Text("Last synced:")
                                        .font(.caption)
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                    Spacer()
                                    Text(formatDate(lastSync))
                                        .font(.caption)
                                        .foregroundColor(COLOR_TEXT_PRIMARY)
                                }
                            }
                            
                            if !cacheManager.isOfflineMode && cacheManager.syncStatus != .syncing {
                                Button(action: {
                                    Task {
                                        await cacheManager.syncWithServer()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Sync Now")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(COLOR_CHARCOAL)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(COLOR_WARM_AMBER)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Cache Statistics
                        VStack(spacing: 16) {
                            Text("Cache Statistics")
                                .font(.headline)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            StatRow(icon: "doc.on.doc", label: "Cached Cocktails", value: "\(cacheManager.cachedCocktailsCount)")
                            StatRow(icon: "photo", label: "Cached Images", value: "\(cacheManager.getCachedImageCount())")
                            StatRow(icon: "exclamationmark.triangle", label: "Stale Items", value: "\(cacheManager.getStaleCount())")
                            StatRow(icon: "internaldrive", label: "Cache Size", value: cacheManager.getCacheSize())
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Cache Actions
                        VStack(spacing: 12) {
                            Text("Cache Management")
                                .font(.headline)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: {
                                isCachingFavorites = true
                                Task {
                                    let favoriteIngredients = LocalStorageManager.shared.retrieveFavoriteItems()
                                    let favoriteNames = Set(favoriteIngredients.map { $0.name })
                                    let favoriteDrinks = (DrinkManager.shared.allDrinks ?? []).filter { drink in
                                        favoriteNames.contains(drink.strDrink)
                                    }
                                    await cacheManager.cacheAllFavorites(favoriteDrinks)
                                    isCachingFavorites = false
                                }
                            }) {
                                HStack {
                                    if isCachingFavorites {
                                        SwiftUI.ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: COLOR_CHARCOAL))
                                    } else {
                                        Image(systemName: "star.fill")
                                    }
                                    Text(isCachingFavorites ? "Caching..." : "Cache All Favorites")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(COLOR_CHARCOAL)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(COLOR_WARM_AMBER.opacity(isCachingFavorites ? 0.5 : 1.0))
                                .cornerRadius(10)
                            }
                            .disabled(isCachingFavorites || cacheManager.isOfflineMode)
                            
                            Button(action: {
                                showClearCacheAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear All Cache")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                            }
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Info Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Offline Mode")
                                .font(.headline)
                                .foregroundColor(COLOR_TEXT_PRIMARY)
                            
                            InfoRow(icon: "checkmark.circle", text: "Access cached cocktails without internet")
                            InfoRow(icon: "arrow.down.circle", text: "Automatic sync when connection restored")
                            InfoRow(icon: "clock", text: "Cached data refreshes every 30 days")
                            InfoRow(icon: "photo", text: "Images stored locally for fast loading")
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Offline Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .alert("Clear Cache", isPresented: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    cacheManager.clearCache()
                }
            } message: {
                Text("This will remove all cached cocktails and images. You'll need to re-download them.")
            }
        }
    }
    
    private var syncStatusIcon: String {
        switch cacheManager.syncStatus {
        case .synced: return "checkmark.circle.fill"
        case .syncing: return "arrow.triangle.2.circlepath"
        case .needsSync: return "exclamationmark.circle.fill"
        case .offline: return "wifi.slash"
        }
    }
    
    private var syncStatusColor: Color {
        switch cacheManager.syncStatus {
        case .synced: return .green
        case .syncing: return COLOR_WARM_AMBER
        case .needsSync: return .orange
        case .offline: return .red
        }
    }
    
    private var syncStatusText: String {
        switch cacheManager.syncStatus {
        case .synced: return "Synced"
        case .syncing: return "Syncing..."
        case .needsSync: return "Needs Sync"
        case .offline: return "Offline"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundColor(COLOR_TEXT_SECONDARY)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(COLOR_TEXT_PRIMARY)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(COLOR_TEXT_SECONDARY)
        }
    }
}

#Preview {
    OfflineSettingsView()
}
