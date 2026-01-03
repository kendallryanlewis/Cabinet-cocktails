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
            MainView()
                .opacity(opacity)
        }
        .task {
            // Animate opacity after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
                opacity = 1.0
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
