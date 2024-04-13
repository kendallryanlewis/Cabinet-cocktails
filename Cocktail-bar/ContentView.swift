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
            NavigationView {
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

#Preview {
    ContentView()
}

struct LoadingScreen: View {
    @State private var isVisible = true

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                Image("LoadingScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipped()
                Spacer()
            }
            LinearGradient(gradient: Gradient(colors: [LINEAR_TOP, LINEAR_BOTTOM]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all).opacity(0.1)
        }
    }
}
