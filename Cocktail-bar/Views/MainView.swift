//
//  MainView.swift
//  VisAG
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

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var premiumManager: PremiumManager
    @State private var isMenuOpen = true
    @State var showWelcomePopup = false
    @State var showFirstTimeCabinet = false
    @State var openPopover = false
    @State var viewPage: pages = .home
    
    // Sheet presentation states
    @State private var showCabinet = false
    @State private var showSignatures = false
    @State private var showMixology = false
    @State private var showQuick = false
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showContact = false
    @State private var showShoppingList = false
    @State private var showHistory = false
    @State private var showRecommendations = false
    @State private var showEducational = false
    @State private var showSeasonal = false
    @State private var showPreferences = false
    @State private var showCustomRecipes = false
    @State private var showCostTracking = false
    @State private var showBarEquipment = false
    @State private var showHelp = false
    @State private var showTutorial = false
    @State private var showPremium = false
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) : Gradient(colors: [ LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]), startPoint: .topTrailing, endPoint: .leading)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            GenericBackground()
                .opacity(!isMenuOpen ? 0.05 : 1)
            // Main content view
            switch viewPage {
                case .home, .cabinet, .signatures, .mixology, .quick, .contact, .about, .settings, .shoppingList, .history, .recommendations, .educational, .seasonal, .preferences, .customRecipes, .costTracking, .barEquipment, .help, .premium:
                    MenuView(isOpen: $isMenuOpen, viewPage: $viewPage)
                        .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.size.width)
                        .zIndex(1)
                        .opacity(isMenuOpen ? 1 : 0)
                default:
                    MenuView(isOpen: $isMenuOpen, viewPage: $viewPage)
                        .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.size.width)
                        .zIndex(1)
                        .opacity(isMenuOpen ? 1 : 0)
            }
        }
        .onAppear(){
            // set all drinks in initial set up
            DrinkManager.shared.setUp()
            // Show welcome popup for new users
            if !session.hasCompletedWelcome() {
                showWelcomePopup = true
            }
            // Show first-time cabinet prompt if cabinet is empty
            if LocalStorageManager.shared.retrieveTopShelfItems().isEmpty && session.hasCompletedWelcome() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showFirstTimeCabinet = true
                }
            }
            // Show tutorial for first-time users
            if !hasCompletedTutorial && session.hasCompletedWelcome() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showTutorial = true
                }
            }
         }
        .onChange(of: viewPage) { newPage in
            // Handle page changes and trigger sheet presentations
            switch newPage {
            case .cabinet:
                showCabinet = true
                viewPage = .home
            case .signatures:
                showSignatures = true
                viewPage = .home
            case .mixology:
                showMixology = true
                viewPage = .home
            case .quick:
                showQuick = true
                viewPage = .home
            case .settings:
                showSettings = true
                viewPage = .home
            case .about:
                showAbout = true
                viewPage = .home
            case .contact:
                showContact = true
                viewPage = .home
            case .shoppingList:
                showShoppingList = true
                viewPage = .home
            case .history:
                showHistory = true
                viewPage = .home
            case .recommendations:
                showRecommendations = true
                viewPage = .home
            case .educational:
                showEducational = true
                viewPage = .home
            case .seasonal:
                showSeasonal = true
                viewPage = .home
            case .preferences:
                showPreferences = true
                viewPage = .home
            case .customRecipes:
                showCustomRecipes = true
                viewPage = .home
            case .costTracking:
                showCostTracking = true
                viewPage = .home
            case .barEquipment:
                showBarEquipment = true
                viewPage = .home
            case .help:
                showHelp = true
                viewPage = .home
            case .premium:
                showPremium = true
                viewPage = .home
            default:
                break
            }
        }
        .sheet(isPresented: $showCabinet) {
            TopShelfView(isMenuOpen: .constant(false))
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showCabinet) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showSignatures) {
            SignaturesView(isMenuOpen: .constant(false), viewPage: $viewPage)
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showSignatures) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showMixology) {
            MixologyView(isMenuOpen: .constant(false), viewPage: $viewPage)
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showMixology) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showQuick) {
            SearchView(isMenuOpen: .constant(false))
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showQuick) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isMenuOpen: .constant(false))
        }
        .onChange(of: showSettings) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showAbout) {
            AboutView(isMenuOpen: .constant(false))
        }
        .onChange(of: showAbout) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showContact) {
            ContactView(isMenuOpen: .constant(false))
        }
        .onChange(of: showContact) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showShoppingList) {
            ShoppingListView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showShoppingList) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showHistory) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showRecommendations) {
            RecommendationsView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showRecommendations) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showEducational) {
            EducationalContentView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showEducational) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showSeasonal) {
            SeasonalCocktailsView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showSeasonal) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showPreferences) {
            UserPreferencesView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showPreferences) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showCustomRecipes) {
            CustomRecipesListView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showCustomRecipes) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showCostTracking) {
            CostTrackingView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showCostTracking) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showBarEquipment) {
            BarEquipmentView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showBarEquipment) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showHelp) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .sheet(isPresented: $showTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showPremium) {
            SubscriptionManagementView()
                .presentationDragIndicator(.visible)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .onChange(of: showPremium) { isShowing in
            if !isShowing { isMenuOpen = true }
        }
        .fullScreenCover(isPresented: $showWelcomePopup) {
            WelcomePopupView(isPresented: $showWelcomePopup)
        }
        .sheet(isPresented: $showFirstTimeCabinet) {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                FirstTimeCabinetPrompt(
                    onOpenCabinet: {
                        showFirstTimeCabinet = false
                        showCabinet = true
                    },
                    onSkip: {
                        showFirstTimeCabinet = false
                    }
                )
            }
        }
    }
}

#Preview {
    MainView()
}
