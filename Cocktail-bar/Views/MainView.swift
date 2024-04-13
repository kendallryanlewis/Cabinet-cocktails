//
//  MainView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/10/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @State private var isMenuOpen = false
    @State var openPopover = false

    var body: some View {
        ZStack {
            // Main content view
            ZStack {
                GenericBackground()
                DashboardView(isMenuOpen: $isMenuOpen)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: 0)
            
            // Menu view
            MenuView(isOpen: $isMenuOpen)
                .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.size.width)
                .zIndex(1)
                //.background(Color.white.opacity(isMenuOpen ? 0.6 : 0))
                .onTapGesture {
                    withAnimation {
                        isMenuOpen.toggle()
                    }
                }
        }.onAppear(){
            // set all drinks in intial set up
            DrinkManager.shared.setUp()
        }
    }
}

#Preview {
    MainView()
}
