//
//  MenuView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/10/23.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var premiumManager: PremiumManager
    @Binding var isOpen: Bool
    @Binding var viewPage: pages
    
    @State private var discoverExpanded = false
    @State private var cabinetExpanded = false
    @State private var hasAppeared = false
    
    // Menu text colors - adapt to light/dark mode
    private var menuTitleColor: Color {
        colorScheme == .dark ? COLOR_WARM_AMBER : Color(hex: "#4A4A4A")
    }
    private var menuTextColor: Color { colorScheme == .dark ? .white : Color(hex: "#4A4A4A")  }
    private var menuSecondaryColor: Color { colorScheme == .dark ? .white : Color(hex: "#4A4A4A") }
    private var menuItemBackground: Color { colorScheme == .dark ? .clear : Color(hex: "#3A3A3C") }

    var body: some View {
        VStack(alignment: .leading, spacing: EdgeInsets.sectionSpacing) {
            UserHeader()
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(){
                    Text("Quick")
                    Spacer()
                }.foregroundColor(menuTitleColor)
                    .font(.largeTitle).bold()
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            if !discoverExpanded {
                                cabinetExpanded = false
                            }
                            discoverExpanded.toggle()
                        }
                    }
                
                // Discover dropdown items (appear under the title)
                if discoverExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        MenuItem(title: "Quick", textColor: menuSecondaryColor, action: {
                            withAnimation { viewPage = .quick; isOpen.toggle() }
                        })
                        MenuItem(title: "Recommendations", textColor: menuSecondaryColor, isLocked: !premiumManager.isPremium, action: {
                            withAnimation { viewPage = premiumManager.isPremium ? .recommendations : .premium; isOpen.toggle() }
                        })
                        MenuItem(title: "Seasonal Cocktails", textColor: menuSecondaryColor, isLocked: !premiumManager.hasAccess(to: .seasonalContent), action: {
                            withAnimation { viewPage = premiumManager.hasAccess(to: .seasonalContent) ? .seasonal : .premium; isOpen.toggle() }
                        })
                        MenuItem(title: "Educational", textColor: menuSecondaryColor, isLocked: !premiumManager.hasAccess(to: .educationalContent), action: {
                            withAnimation { viewPage = premiumManager.hasAccess(to: .educationalContent) ? .educational : .premium; isOpen.toggle() }
                        })
                    }
                    .padding(.leading, EdgeInsets.horizontalPadding)
                    .transition(.opacity)
                    .opacity(hasAppeared ? 1 : 0)
                }

                // Main Navigation Items
                HStack(){
                    Text("‍Cabinet")
                    Spacer()
                }.foregroundColor(menuTitleColor)
                    .font(.largeTitle).bold()
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            if !cabinetExpanded {
                                discoverExpanded = false
                            }
                            cabinetExpanded.toggle()
                        }
                    }
                
                // Cabinet dropdown items (appear under the title)
                if cabinetExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        MenuItem(title: "Cabinet", textColor: menuSecondaryColor, action: {
                            withAnimation { viewPage = .cabinet; isOpen.toggle() }
                        })
                        MenuItem(title: "Shopping List", textColor: menuSecondaryColor, isLocked: !premiumManager.hasAccess(to: .shoppingList), action: {
                            withAnimation { viewPage = premiumManager.hasAccess(to: .shoppingList) ? .shoppingList : .premium; isOpen.toggle() }
                        })
                        MenuItem(title: "My Recipes", textColor: menuSecondaryColor, isLocked: !premiumManager.hasAccess(to: .customRecipes), action: {
                            withAnimation { viewPage = premiumManager.hasAccess(to: .customRecipes) ? .customRecipes : .premium; isOpen.toggle() }
                        })
                        MenuItem(title: "Cost Tracking", textColor: menuSecondaryColor, isLocked: !premiumManager.hasAccess(to: .costTracking), action: {
                            withAnimation { viewPage = premiumManager.hasAccess(to: .costTracking) ? .costTracking : .premium; isOpen.toggle() }
                        })
                        MenuItem(title: "Bar Equipment", textColor: menuSecondaryColor, isLocked: !premiumManager.isPremium, action: {
                            withAnimation { viewPage = premiumManager.isPremium ? .barEquipment : .premium; isOpen.toggle() }
                        })
                    }
                    .padding(.leading, EdgeInsets.horizontalPadding)
                    .transition(.opacity)
                    .opacity(hasAppeared ? 1 : 0)
                }
                
                HStack(){
                    Text("‍Mixology")
                    Spacer()
                }.foregroundColor(menuTitleColor)
                    .font(.largeTitle)
                    .bold()
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .mixology
                            isOpen.toggle()
                        }
                    }
                
                HStack(){
                    Text("‍Signatures")
                    Spacer()
                }.foregroundColor(menuTitleColor)
                    .font(.largeTitle).bold()
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .signatures
                            isOpen.toggle()
                        }
                    }
                    
                // Bottom Menu Items (Always Visible)
                HStack(){
                    HStack {
                        Text(premiumManager.isPremium ? "Premium Status" : "Upgrade to Premium")
                        if !premiumManager.isPremium {
                            Image(systemName: "crown.fill")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                    Spacer()
                }.font(.headline)
                    .foregroundColor(menuTextColor)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .premium
                            isOpen.toggle()
                        }
                    }
                
                HStack(){
                    Text("Settings")
                    Spacer()
                }.font(.headline)
                    .foregroundColor(menuTextColor)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .settings
                            isOpen.toggle()
                        }
                    }
                
                HStack(){
                    Text("History")
                    Spacer()
                }.font(.headline)
                    .foregroundColor(menuTextColor)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .history
                            isOpen.toggle()
                        }
                    }
                    
                HStack(){
                    Text("About")
                    Spacer()
                }.font(.headline)
                    .foregroundColor(menuTextColor)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .about
                            isOpen.toggle()
                        }
                    }

                HStack(){
                    Text("Help")
                    Spacer()
                }.font(.headline)
                    .foregroundColor(menuTextColor)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .help
                            isOpen.toggle()
                        }
                    }
            }
        }.padding(EdgeInsets.mainBorder)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(MenuBackground())
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                hasAppeared = true
            }
        }
    }
}

// MARK: - Menu Section Component
struct MenuSection<Content: View>: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let animationDelay: Double
    let hasAppeared: Bool
    let content: Content
    
    init(title: String, icon: String, isExpanded: Binding<Bool>, animationDelay: Double = 0, hasAppeared: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.animationDelay = animationDelay
        self.hasAppeared = hasAppeared
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .font(.bodyText)
                        .foregroundColor(COLOR_WARM_AMBER)
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.vertical, 8)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    content
                }
                .padding(.leading, 24)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
        .opacity(hasAppeared ? 1 : 0)
        .offset(x: hasAppeared ? 0 : -30)
        .animation(.easeOut(duration: 0.5).delay(animationDelay), value: hasAppeared)
    }
}

// MARK: - Menu Item Component
struct MenuItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    var icon: String? = nil
    var iconColor: Color = .white
    var textColor: Color = .white
    var isLocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.bodySmall)
                        .foregroundColor(isLocked ? (colorScheme == .dark ? COLOR_TEXT_SECONDARY : Color(hex: "#666666")) : iconColor)
                }
                Text(title)
                    .font(.body)
                    .foregroundColor(isLocked ? (colorScheme == .dark ? COLOR_TEXT_SECONDARY : Color(hex: "#666666")) : textColor)
                Spacer()
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
