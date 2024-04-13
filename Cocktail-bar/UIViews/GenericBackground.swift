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
        if(colorScheme != .dark){
            LinearGradient(colors: [LIGHT_LINEAR_TOP, LIGHT_LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        }else{
            LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        }
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
