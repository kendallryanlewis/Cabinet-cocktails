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

class SessionStore: ObservableObject {
    @Published var userSession: User?
    @Published var isLoggedIn: Bool = false // Example: Session state, change as needed
    @Published var loading = false
    @Published var username: String = ""    // Example: User data, change as needed
    @Published var tutorial: Bool = true
    
    func verifyUser(completion: (() -> Void)? = nil) {
        if(LocalStorageManager.shared.getActiveUser()){
            if let user = LocalStorageManager.shared.retrieveUser() ?? nil{
                DispatchQueue.main.async { [weak self] in
                    self?.userSession = user
                    self?.username = user.username
                    self?.isLoggedIn = user.isLoggedIn
                    completion?()
                }
            }
        }
    }

    // Method to handle sign-in
    func signIn(email: String, password: String) -> loginStatus {
        var user = LocalStorageManager.shared.retrieveUser()
        if (email.lowercased() == user.email.lowercased() && password == user.password
            || username.lowercased() == user.username.lowercased() && password == user.password) && email != "" && password != "" {
            LocalStorageManager.shared.saveUser(user)
            isLoggedIn = true
            userSession = user
            user.isLoggedIn = true
            return .success
        } else {
            isLoggedIn = false
            if(email.lowercased() != user.email.lowercased()){
                return .email
            }else if(password != user.password){
                return .password
            }else if(username.lowercased() != user.username.lowercased()){
                return .username
            }
        }
        return .fail
    }
    
    // Method to handle sign-up
    func signUp(username: String, email: String, password: String, confirmPassword: String) -> Bool {
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword {
            return false // Sign-up failed
        }
        let newUser = User(uid: "", email: email, profileImageUrl: "", username: username, password: password, isLoggedIn: true)
        LocalStorageManager.shared.saveUser(newUser)
        deleteUser()// remove later
        userSession = newUser
        isLoggedIn = true
        LocalStorageManager.shared.showWelcome(show: true)
        return true
    }

    // Method to handle sign-out
    func signOut() {
        // Implement your sign-out logic here
        LocalStorageManager.shared.setActiveUser(isLoggedIn: false)
        isLoggedIn = false
        username = ""
        userSession?.isLoggedIn = false
    }
    
    func deleteUser() {
        // Implement your sign-out logic here
        LocalStorageManager.shared.deleteUser()
        isLoggedIn = false
        userSession = nil
        username = ""
    }
}
