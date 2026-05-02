//
//  ContentView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/13/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State private var showMain = false
    @State private var splashOpacity = 1.0

    var body: some View {
        ZStack {
            if showMain {
                MainView()
            }
            if splashOpacity > 0 {
                LoadingScreen()
                    .opacity(splashOpacity)
                    .ignoresSafeArea()
            }
        }
        .task {
            // Brief pause so the splash image is seen, then fade it out
            try? await Task.sleep(nanoseconds: 900_000_000)
            showMain = true
            withAnimation(.easeInOut(duration: 0.4)) {
                splashOpacity = 0.0
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
