//
//  GenericButton.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct GenericButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? Color.darkGray : .white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? COLOR_PRIMARY : Color.darkGray)
                .cornerRadius(3).bold()
        }
    }
}
