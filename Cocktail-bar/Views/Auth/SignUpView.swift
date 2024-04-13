//
//  SignUpView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.colorScheme) private var colorScheme
    @Binding var newUserRegistration: Bool
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    
    var body: some View {
        VStack(){
            HStack(){
                Button(action: {
                    newUserRegistration = false
                }, label: {
                    HStack(){
                        Image(systemName: "chevron.backward")
                            .font(.headline).bold()
                        Text("Sign Up!")
                    }.foregroundColor(.white)
                })
                Spacer()
            }.padding()
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width:100)
            Spacer()
            HStack(){
                Text(TEXT_SIGN_UP)
                    .font(.largeTitle).bold().foregroundStyle(.white)
                Spacer()
            }.padding(.horizontal, 30)
            RoundedRectangle(cornerRadius: 15)
            .fill(Color.black.opacity(0.0))
            //.blurBackground(style: (colorScheme == .light ? .systemThinMaterialLight : .systemThickMaterialLight))
            .overlay(
                VStack(alignment: .leading){
                    GenericTextField(text: $username,placeholder: TEXT_USERNAME, isSecure: false)
                    GenericTextField(text: $email, placeholder: TEXT_EMAIL, isSecure: false)
                    GenericTextField(text: $password, placeholder: TEXT_PASSWORD, isSecure: true)
                    GenericTextField(text: $confirmPassword, placeholder: TEXT_CONFRIM_PASSWORD, isSecure: true)
                    Text(TEXT_TERMS_APPLY_TAG)
                        .font(.footnote)
                        .foregroundColor(colorScheme == .light ? .white : .gray)
                        .padding()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineSpacing(10)
                    GenericButton(title: TEXT_CONSENT) {
                        if session.signUp(username: username, email: email,  password: password, confirmPassword: confirmPassword) {
                            newUserRegistration = true
                        } else {
                            print("KNDL - Error 1")
                        }
                    }
                }.padding()
            )
            //.background(Color.white.opacity(0.9))
            .clipped().cornerRadius(10).frame(height: 450)
        }
    }
}
#Preview {
    LoginView()
}
//https://dribbble.com/shots/15266900-Mobile-app-login-screen-and-sign-up-flow