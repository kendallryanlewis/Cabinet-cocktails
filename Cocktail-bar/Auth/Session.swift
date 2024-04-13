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
    var userSession: User?
    @Published var isLoggedIn: Bool = false // Example: Session state, change as needed
    @Published var loading = false
    @Published var username: String = ""    // Example: User data, change as needed
    @Published var tutorial: Bool = true
    
    func verifyUser(){
        let user = LocalStorageManager.shared.retrieveUser()
        print(user)
        if(user.isLoggedIn){
            userSession = LocalStorageManager.shared.retrieveUser()
            print(userSession)
            isLoggedIn = true
        }
    }

    // Method to handle sign-in
    func signIn(email: String, password: String) -> loginStatus {
        // Implement your sign-in logic here
        // For example, check username and password, and update the session state accordingly
        var user = LocalStorageManager.shared.retrieveUser()
        if email.lowercased() == user.email.lowercased() && password == user.password
            || username.lowercased() == user.username.lowercased() && password == user.password {
            isLoggedIn = true
            userSession = user
            user.isLoggedIn = true
            LocalStorageManager.shared.saveUser(user)
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
        // If the sign-up is successful, update the session state
        LocalStorageManager.shared.saveUser(User(uid: "", email: email, profileImageUrl: "", username: username, password: password, isLoggedIn: true))
        isLoggedIn = true
        return true
    }

    // Method to handle sign-out
    func signOut() {
        // Implement your sign-out logic here
        isLoggedIn = false
        username = ""
        userSession?.isLoggedIn = false
        LocalStorageManager.shared.saveUser(userSession!)
    }
    
    func deleteUser() {
        // Implement your sign-out logic here
        LocalStorageManager.shared.deleteUser()
        isLoggedIn = false
        username = ""
    }
    
    /*func listenAuthenticationState() -> User {
        return User(uid: "klanfajfkamsdf", email: "kendall.ryan.lewis@gmail.com", profileImageUrl: "", username: "Kendallryanlewis", tutorial: false, userAgreement: false, keywords: [], privileges: [])
    }*/
}
