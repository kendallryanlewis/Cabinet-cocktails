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
    @Published var isLoggedIn: Bool = true // Always logged in - no authentication needed
    @Published var loading = false
    @Published var username: String = "Guest"
    @Published var email: String = ""
    @Published var tutorial: Bool = true
    
    private let usernameKey = "AppUsername"
    private let emailKey = "AppEmail"
    private let hasCompletedWelcomeKey = "HasCompletedWelcome"
    
    init() {
        // Always logged in by default
        self.isLoggedIn = true
        // Load saved username and email
        self.username = UserDefaults.standard.string(forKey: usernameKey) ?? "Guest"
        self.email = UserDefaults.standard.string(forKey: emailKey) ?? ""
    }
    
    func verifyUser(completion: (() -> Void)? = nil) {
        // Always verified - no authentication needed
        self.isLoggedIn = true
        completion?()
    }
    
    func saveProfile(username: String, email: String) {
        self.username = username.isEmpty ? "Guest" : username
        self.email = email
        UserDefaults.standard.set(self.username, forKey: usernameKey)
        UserDefaults.standard.set(email, forKey: emailKey)
    }
    
    func hasCompletedWelcome() -> Bool {
        return UserDefaults.standard.bool(forKey: hasCompletedWelcomeKey)
    }
    
    func setWelcomeCompleted() {
        UserDefaults.standard.set(true, forKey: hasCompletedWelcomeKey)
    }
}
