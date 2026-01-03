//
//  TextField.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct GenericTextField: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    //.foregroundColor(colorScheme == .light ? COLOR_PRIMARY : .white)
            }
            if isSecure {
                SecureField("", text: $text)
            } else {
                TextField("", text: $text)
            }
        }
        .padding()
        .background(colorScheme == .light ? .white.opacity(0.5) : COLOR_PRIMARY.opacity(0.5))
        .cornerRadius(5.0)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.white.opacity(0.6), lineWidth: 2) // Border
        )
        .padding(.bottom, 10)
    }
}
