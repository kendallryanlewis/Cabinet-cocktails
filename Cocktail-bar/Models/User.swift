//
//  User.swift
//  Sneakers App
//
//  Created by Kendall Lewis on 9/10/21.
//

import Foundation

struct User: Encodable, Decodable {
    var uid: String
    var profileImageUrl: String
    var password: String
    var isLoggedIn: Bool
}

