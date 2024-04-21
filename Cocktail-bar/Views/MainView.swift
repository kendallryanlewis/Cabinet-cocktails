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
    case logout
}

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    @State private var isMenuOpen = true
    @State var newUser = LocalStorageManager.shared.getWelcome()
    @State var openPopover = false
    @State var viewPage: pages = .home
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) : Gradient(colors: [ LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]), startPoint: .topTrailing, endPoint: .leading)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            GenericBackground()
                .opacity(!isMenuOpen && viewPage != .mixology ? 0.05 : 1)
            // Main content view
            ZStack {
                switch viewPage {
                    case .cabinet:
                        TopShelfView(isMenuOpen: $isMenuOpen).opacity(isMenuOpen ? 0 : 1)
                    case .signatures:
                        SignaturesView(isMenuOpen: $isMenuOpen, viewPage: $viewPage).opacity(isMenuOpen ? 0 : 1)
                    case .mixology:
                        MixologyView(isMenuOpen: $isMenuOpen)
                            .opacity(isMenuOpen ? 0 : 1)
                    case .quick:
                        SearchView(isMenuOpen: $isMenuOpen).opacity(isMenuOpen ? 0 : 1)
                    case .contact:
                        ContactView(isMenuOpen: $isMenuOpen).opacity(isMenuOpen ? 0 : 1)
                    case .about:
                        AboutView(isMenuOpen: $isMenuOpen).opacity(isMenuOpen ? 0 : 1)
                    case .home:
                        MenuView(isOpen: $isMenuOpen, viewPage: $viewPage)
                            .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.size.width)
                            .zIndex(1)
                            .opacity(isMenuOpen ? 1 : 0)
                            .onTapGesture {
                                withAnimation {
                                    isMenuOpen.toggle()
                                }
                            }
                    default:
                        MenuView(isOpen: $isMenuOpen, viewPage: $viewPage)
                            .offset(x: isMenuOpen ? 0 : -UIScreen.main.bounds.size.width)
                            .zIndex(1)
                            .opacity(isMenuOpen ? 1 : 0)
                            //.background(Color.white.opacity(isMenuOpen ? 0.6 : 0))
                            .onTapGesture {
                                withAnimation {
                                    isMenuOpen.toggle()
                                }
                            }
                }
                VStack{
                    if(session.userSession != nil){
                        if(!isMenuOpen){
                            Button(action: {
                                withAnimation {
                                    if(!isMenuOpen){
                                        viewPage = .home
                                    }
                                    isMenuOpen.toggle()
                                }
                            }) {
                                HStack{
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 30, height: 30)
                                            .shadow(color: Color.darkGray, radius: 5, x: 0, y: 2)
                                        Image(systemName: isMenuOpen ? "xmark.circle" : "house.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(colorScheme == .dark ? .gray : COLOR_SECONDARY)
                                            .padding(5)
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            }
                        }else{
                            UserHeader(isMenuOpen: $isMenuOpen, user: session.userSession!)
                                .padding(.horizontal)
                        }
                    }else{
                        Text(APP_NAME)
                    }
                    Spacer()
                }.padding(40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: 0)
        }.onAppear(){
            // set all drinks in intial set up
            DrinkManager.shared.setUp()
            LocalStorageManager.shared.showWelcome(show: false)
         }
        .sheet(isPresented: $newUser) {
            WebView(url: URL(string: "\(WEBSITE_URL)/Cabinet-cocktails")!)
        }
    }
}

#Preview {
    MainView()
}
