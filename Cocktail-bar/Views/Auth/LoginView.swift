//
//  LoginView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionStore
    @State var newUserRegistration: Bool = false
    
    var body: some View {
        NavigationStack(){
            ZStack(){
                GenericBackground()
                if(newUserRegistration){
                    SignUpView(newUserRegistration: $newUserRegistration).padding(EdgeInsets.mainBorder)
                }else{
                    SignInView(newUserRegistration: $newUserRegistration).padding(EdgeInsets.mainBorder)
                }
            }
        }
    }
}

