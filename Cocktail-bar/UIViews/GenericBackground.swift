//
//  GenericBackground.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct GenericBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack{
            GeometryReader { geometry in
                Image("LoadingScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [.clear,.clear,.clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.25), LINEAR_BOTTOM.opacity(0.45), LINEAR_BOTTOM.opacity(0.65), LINEAR_BOTTOM.opacity(0.85), LINEAR_BOTTOM.opacity(0.95), LINEAR_BOTTOM, LINEAR_BOTTOM]) : Gradient(colors: [.clear,.clear,.clear,.clear,.clear,.clear, LIGHT_LINEAR_BOTTOM.opacity(0.05), LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.25), LIGHT_LINEAR_BOTTOM.opacity(0.45), LIGHT_LINEAR_BOTTOM.opacity(0.65), LIGHT_LINEAR_BOTTOM.opacity(0.85), LIGHT_LINEAR_BOTTOM.opacity(0.95)]), startPoint: .topTrailing, endPoint: .leading).opacity(0.8)
                .edgesIgnoringSafeArea(.all)
        } //.edgesIgnoringSafeArea(.all)
        /*ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                Image("MainView")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    //.frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
            }.opacity(0.6)
            LinearGradient(gradient: Gradient(colors: [LINEAR_TOP, LINEAR_BOTTOM]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all).opacity(0.1)
        }*/
    }
}

#Preview{
    GenericBackground()
}
