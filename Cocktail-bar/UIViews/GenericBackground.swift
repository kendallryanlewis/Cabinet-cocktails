//
//  GenericBackground.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct GenericBackground: View {
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
            .ignoresSafeArea()
            LinearGradient(
                gradient: Gradient(colors: [.clear, .clear, .clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.25), LINEAR_BOTTOM.opacity(0.45), LINEAR_BOTTOM.opacity(0.65), LINEAR_BOTTOM.opacity(0.85), LINEAR_BOTTOM.opacity(0.95), LINEAR_BOTTOM, LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .opacity(0.8)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview{
    GenericBackground()
}
