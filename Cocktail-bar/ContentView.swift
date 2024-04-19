//
//  ContentView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack{
            LoadingScreen()
            Group {
                if(session.isLoggedIn){
                    MainView()
                }else{
                    LoginView()
                }
            } .opacity(opacity) // Apply the opacity
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation(.easeInOut(duration: 2)) {
                            opacity = opacity == 0.0 ? 1.0 : 0.0
                        }
                    }
                }
                .onAppear(){
                session.verifyUser()
            }
        }
    }
}
struct ContentView2: View {
    @EnvironmentObject var session: SessionStore
    @State private var opacity = 0.0

    var body: some View {
        ZStack{
            LoadingScreen()
            
            Group {
                if session.isLoggedIn {
                    MainView()
                } else {
                    LoginView()
                }
            }
        }
        .opacity(opacity) // Apply the opacity
        .onAppear {
            // Combine session verification and opacity animation
            session.verifyUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 2)) {
                    opacity = 1.0
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

struct LoadingScreen: View {
    @State private var isVisible = true

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("LoadingScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
