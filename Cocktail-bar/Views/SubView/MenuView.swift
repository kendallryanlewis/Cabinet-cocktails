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
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            VStack(spacing:5){
                NavigationLink(destination: SearchView()) {
                    HStack(){
                        Text("‍Quick")
                        Spacer()
                    }.font(.largeTitle).bold()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                NavigationLink(destination: TopShelfView()) {
                    HStack(){
                        Text("‍Cabinet")
                        Spacer()
                    }.font(.largeTitle).bold()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                NavigationLink(destination: MixologyView()) {
                    HStack(){
                        Text("Mixology")
                        Spacer()
                    }.font(.largeTitle).bold()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                NavigationLink(destination: SignaturesView()) {
                    HStack(){
                        Text("Signatures")
                        Spacer()
                    }.font(.largeTitle).bold()
                }.padding([.bottom]).foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                NavigationLink(destination: ContactView()) {
                    HStack(){
                        Text("Contact")
                        Spacer()
                    }.font(.headline)
                }
                NavigationLink(destination: AboutView()) {
                    HStack(){
                        Text("About")
                        Spacer()
                    }.font(.headline)
                }
                Button(action: {
                    session.signOut()
                }, label: {
                    HStack(){
                        Text("Logout!")
                        Spacer()
                    }.font(.headline)
                })
            }.foregroundColor(colorScheme == .dark ? .white : COLOR_SECONDARY)
        }.padding(EdgeInsets.mainBorder)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            LinearGradient(gradient: colorScheme == .dark ? Gradient(colors: [.clear, LINEAR_BOTTOM.opacity(0.15), LINEAR_BOTTOM.opacity(0.25), LINEAR_BOTTOM.opacity(0.45), LINEAR_BOTTOM.opacity(0.65), LINEAR_BOTTOM.opacity(0.85), LINEAR_BOTTOM.opacity(0.95), LINEAR_BOTTOM, LINEAR_BOTTOM]) : Gradient(colors: [.clear, LIGHT_LINEAR_BOTTOM.opacity(0.05), LIGHT_LINEAR_BOTTOM.opacity(0.15), LIGHT_LINEAR_BOTTOM.opacity(0.25), LIGHT_LINEAR_BOTTOM.opacity(0.45), LIGHT_LINEAR_BOTTOM.opacity(0.65), LIGHT_LINEAR_BOTTOM.opacity(0.85), LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]), startPoint: .topTrailing, endPoint: .leading)
        )
        .foregroundColor(.white)
    }
}
