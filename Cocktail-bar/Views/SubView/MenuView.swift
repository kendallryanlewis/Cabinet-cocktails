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

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            UserHeader()
            Spacer()
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(){
                    Text("Quick")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
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
                        MenuItem(title: "Quick", action: {
                            withAnimation { viewPage = .quick; isOpen.toggle() }
                        })
                        MenuItem(title: "Recommendations", action: {
                            withAnimation { viewPage = .recommendations; isOpen.toggle() }
                        })
                        MenuItem(title: "Seasonal Cocktails", action: {
                            withAnimation { viewPage = .seasonal; isOpen.toggle() }
                        })
                        MenuItem(title: "Educational", action: {
                            withAnimation { viewPage = .educational; isOpen.toggle() }
                        })
                    }
                    .padding(.leading, 24)
                    .transition(.opacity)
                    .opacity(hasAppeared ? 1 : 0)
                }

                                // Main Navigation Items
                HStack(){
                    Text("‍Cabinet")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    .font(.largeTitle).bold()
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            if !cabinetExpanded {
                                discoverExpanded = false
                            }
                            cabinetExpanded.toggle()
                            // Don't close menu, just toggle dropdown
                        }
                    }
                
                // Cabinet dropdown items (appear under the title)
                if cabinetExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        MenuItem(title: "Cabinet", action: {
                            withAnimation { viewPage = .cabinet; isOpen.toggle() }
                        })
                        MenuItem(title: "Shopping List", action: {
                            withAnimation { viewPage = .shoppingList; isOpen.toggle() }
                        })
                        MenuItem(title: "My Recipes", action: {
                            withAnimation { viewPage = .customRecipes; isOpen.toggle() }
                        })
                        MenuItem(title: "Cost Tracking", action: {
                            withAnimation { viewPage = .costTracking; isOpen.toggle() }
                        })
                        MenuItem(title: "Bar Equipment", action: {
                            withAnimation { viewPage = .barEquipment; isOpen.toggle() }
                        })
                    }
                    .padding(.leading, 24)
                    .transition(.opacity)
                    .opacity(hasAppeared ? 1 : 0)
                }
                
                HStack(){
                    Text("‍Mixology")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
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
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
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
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(x: hasAppeared ? 0 : -30)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .history
                            // Don't close menu, allow toggling from any view
                        }
                    }
                    
                HStack(){
                    Text("About")
                    Spacer()
                }.font(.headline)
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
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
                        .font(.system(size: 16))
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
    let title: String
    var icon: String? = nil
    var iconColor: Color = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}
