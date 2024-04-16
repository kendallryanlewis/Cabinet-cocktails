//
//  SearchBar.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/17/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
        }
    }
}

#Preview {
    MainView()
}
