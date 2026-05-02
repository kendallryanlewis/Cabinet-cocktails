//
//  UserHeader.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 4/14/24.
//

import SwiftUI

struct UserHeader: View {
    var body: some View {
        HStack() {
            Text("Cabinet Cocktails")
                .font(.title2)
                .bold()
                .foregroundColor(COLOR_TEXT_PRIMARY)
            Spacer()
        }
    }
}
