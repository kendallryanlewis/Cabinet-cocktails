//
//  UserHeader.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/14/24.
//

import SwiftUI

struct UserHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        HStack() {
            // User Information
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(session.username)!")
                    .font(.title2)
                    .bold()
                if !session.email.isEmpty {
                    Text(session.email)
                        .font(.caption)
                }
            }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .white)
                .shadow(color: Color.darkGray, radius: 3, x: 0, y: 2)
            Spacer()
        }
    }
}
