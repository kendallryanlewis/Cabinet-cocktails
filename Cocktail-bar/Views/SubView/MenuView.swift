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
    @Binding var viewPage: pages

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            VStack(spacing:5){
                HStack(){
                    Text("‍Quick")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    .font(.largeTitle).bold()
                    .onTapGesture {
                        withAnimation {
                            viewPage = .quick
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("‍Cabinet")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    .font(.largeTitle).bold()
                    .onTapGesture {
                        withAnimation {
                            viewPage = .cabinet
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("‍Mixology")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    .font(.largeTitle)
                    .bold()
                    .onTapGesture {
                        withAnimation {
                            viewPage = .mixology
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("‍Signatures")
                    Spacer()
                }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .darkGray)
                    .font(.largeTitle).bold()
                    .onTapGesture {
                        withAnimation {
                            viewPage = .signatures
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("Contact")
                    Spacer()
                }.font(.headline)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .contact
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("About")
                    Spacer()
                }.font(.headline)
                    .onTapGesture {
                        withAnimation {
                            viewPage = .about
                            isOpen.toggle()
                        }
                    }
                HStack(){
                    Text("Logout!")
                    Spacer()
                }.font(.headline)
                    .onTapGesture {
                        session.signOut()
                    }
            }.foregroundColor(colorScheme == .dark ? .white : .white)
                .shadow(color: Color.darkGray, radius: 5, x: 0, y: 2)
        }.padding(EdgeInsets.mainBorder)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
