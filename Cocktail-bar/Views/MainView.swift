//
//  MainView.swift
//  Cabinet Cocktails
//
//  Created by Kendall Lewis on 10/10/23.
//

import SwiftUI

enum pages: String, Codable {
    case home
    case cabinet
    case signatures
    case quick
    case mixology
    case contact
    case about
    case settings
    case shoppingList
    case history
    case recommendations
    case educational
    case seasonal
    case preferences
    case customRecipes
    case costTracking
    case barEquipment
    case help
    case premium
    case logout
}

// MARK: - Tab identifiers

enum MainTab: Int {
    case discover = 0
    case search    = 1
    case mix       = 2
    case shopping  = 3
    case profile   = 4
}

// MARK: - MainView

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var premiumManager: PremiumManager

    @State private var selectedTab: MainTab = .discover

    // Modals triggered from tab content (Profile tab, etc.)
    @State private var showHistory      = false
    @State private var showRecommendations = false
    @State private var showEducational  = false
    @State private var showSeasonal     = false
    @State private var showPreferences  = false
    @State private var showCustomRecipes = false
    @State private var showCostTracking = false
    @State private var showBarEquipment = false
    @State private var showHelp         = false
    @State private var showAbout        = false
    @State private var showContact      = false
    @State private var showCollections  = false
    @State private var showPremium      = false
    @State private var showExpiration   = false

    // First-run flows
    @State private var showWelcomePopup       = false
    @State private var showFirstTimeCabinet   = false
    @State private var showTutorial           = false
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            // ── Tab Content ─────────────────────────────────────────────────
            Group {
                switch selectedTab {
                case .discover:
                    DashboardView()
                case .search:
                    SearchView(isMenuOpen: .constant(false))
                case .mix:
                    MixologyView(isMenuOpen: .constant(false), viewPage: .constant(.home))
                case .shopping:
                    ShoppingListView()
                case .profile:
                    ProfileTabView(
                        showHistory:       $showHistory,
                        showRecommendations: $showRecommendations,
                        showEducational:   $showEducational,
                        showSeasonal:      $showSeasonal,
                        showPreferences:   $showPreferences,
                        showCustomRecipes: $showCustomRecipes,
                        showCostTracking:  $showCostTracking,
                        showBarEquipment:  $showBarEquipment,
                        showHelp:          $showHelp,
                        showAbout:         $showAbout,
                        showContact:       $showContact,
                        showCollections:   $showCollections,
                        showPremium:       $showPremium,
                        showExpiration:    $showExpiration
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 16)
        }
        // ── Sheets from Profile tab ──────────────────────────────────────────
        .sheet(isPresented: $showHistory)          { HistoryView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showRecommendations)  { RecommendationsView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showEducational)      { EducationalContentView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showSeasonal)         { SeasonalCocktailsView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showPreferences)      { UserPreferencesView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showCustomRecipes)    { CustomRecipesListView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showCostTracking)     { CostTrackingView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showBarEquipment)     { BarEquipmentView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showHelp)             { HelpView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showAbout)            { AboutView(isMenuOpen: .constant(false)) }
        .sheet(isPresented: $showContact)          { ContactView(isMenuOpen: .constant(false)) }
        .sheet(isPresented: $showCollections)      { CollectionsView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showPremium)          { SubscriptionManagementView().presentationDragIndicator(.visible) }
        .sheet(isPresented: $showExpiration)        { ExpirationManagementView().presentationDragIndicator(.visible) }
        // ── First-run flows ─────────────────────────────────────────────────
        .sheet(isPresented: $showTutorial)         { TutorialView() }
        .fullScreenCover(isPresented: $showWelcomePopup) {
            WelcomePopupView(isPresented: $showWelcomePopup)
        }
        .sheet(isPresented: $showFirstTimeCabinet) {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                FirstTimeCabinetPrompt(
                    onOpenCabinet: {
                        showFirstTimeCabinet = false
                        selectedTab = .profile // redirect to cabinet via profile
                    },
                    onSkip: { showFirstTimeCabinet = false }
                )
            }
        }
        .onAppear {
            DrinkManager.shared.setUp()
            if !session.hasCompletedWelcome() { showWelcomePopup = true }
            if LocalStorageManager.shared.retrieveTopShelfItems().isEmpty && session.hasCompletedWelcome() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showFirstTimeCabinet = true }
            }
            if !hasCompletedTutorial && session.hasCompletedWelcome() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showTutorial = true }
            }
        }
    }
}

// MARK: - Custom Bottom Tab Bar

struct BottomTabBar: View {
    @Binding var selectedTab: MainTab

    private let tabs: [(icon: String, activeIcon: String, label: String, tab: MainTab)] = [
        ("flame",           "flame.fill",        "Discover",  .discover),
        ("magnifyingglass", "magnifyingglass",    "Search",    .search),
        ("plus.circle",     "plus.circle.fill",  "Mix",       .mix),
        ("bag",             "bag.fill",          "Shopping",  .shopping),
        ("person",          "person.fill",       "Profile",   .profile),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tab.rawValue) { item in
                TabItemButton(
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.label,
                    tab: item.tab,
                    selectedTab: $selectedTab
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(COLOR_CHARCOAL)
                .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 8)
        )
        .padding(.horizontal, 16)
    }

    private var bottomPadding: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first
        let safeBottom = window?.safeAreaInsets.bottom ?? 0
        return safeBottom > 0 ? safeBottom : 16
    }
}

// Separate struct so SwiftUI diffs the binding independently per tab item
struct TabItemButton: View {
    let icon: String
    let activeIcon: String
    let label: String
    let tab: MainTab
    @Binding var selectedTab: MainTab

    var isActive: Bool { selectedTab == tab }
    var isMix: Bool { tab == .mix }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isMix {
                        Circle()
                            .fill(COLOR_WARM_AMBER)
                            .frame(width: 52, height: 52)
                        Image(systemName: isActive ? activeIcon : icon)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(COLOR_CHARCOAL)
                    } else {
                        if isActive {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(COLOR_WARM_AMBER.opacity(0.15))
                                .frame(width: 48, height: 36)
                        }
                        Image(systemName: isActive ? activeIcon : icon)
                            .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                            .foregroundColor(isActive ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                    }
                }
                .frame(height: isMix ? 52 : 36)

                /*Text(label)
                    .font(.system(size: 10, weight: isActive || isMix ? .semibold : .regular))
                    .foregroundColor(isActive || isMix ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)*/
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainView()
        .environmentObject(SessionStore())
        .environmentObject(SystemSettingsManager())
        .environmentObject(PremiumManager())
}


