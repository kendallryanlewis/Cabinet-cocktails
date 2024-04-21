//
//  UserHeader.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/14/24.
//

import SwiftUI

struct UserHeader: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isMenuOpen: Bool
    var user:User
    var body: some View {
        HStack() {
            // User Information
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(user.username)!")
                    .font(.title2)
                    .bold()
                Text(user.email)
                    .font(.caption)
            }.foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : .white)
                .shadow(color: Color.darkGray, radius: 3, x: 0, y: 2)
            Spacer()
        }
    }
}
