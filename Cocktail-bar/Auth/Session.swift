//
//  SessionStore.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import Foundation
import Combine

enum loginStatus: String, Codable {
    case username
    case password
    case email
    case success
    case fail
}

@MainActor
class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = true
    @Published var loading = false
    @Published var tutorial: Bool = true

    private let hasCompletedWelcomeKey = "HasCompletedWelcome"

    init() {
        self.isLoggedIn = true
    }

    func verifyUser(completion: (() -> Void)? = nil) {
        self.isLoggedIn = true
        completion?()
    }

    func hasCompletedWelcome() -> Bool {
        return UserDefaults.standard.bool(forKey: hasCompletedWelcomeKey)
    }

    func setWelcomeCompleted() {
        UserDefaults.standard.set(true, forKey: hasCompletedWelcomeKey)
    }
}
