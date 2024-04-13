//
//  SignInView.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/9/23.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.colorScheme) private var colorScheme
    @Binding var newUserRegistration: Bool
    @State private var showReset: Bool = false
    @State private var email = ""
    @State private var password = ""
    @State var loginStatus: loginStatus = .fail
    
    var body: some View {
        ZStack{
            VStack(){
                Spacer()
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:300)
                Spacer()
                HStack(){
                    Text(TEXT_SIGN_IN).font(.largeTitle).bold().foregroundStyle(.white)
                    Spacer()
                }.padding(.horizontal, 30)
                RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.0))
                //.blurBackground(style: (colorScheme == .light ? .systemUltraThinMaterialLight : .systemThickMaterialLight))
                .overlay(
                    VStack(alignment: .leading){
                        GenericTextField(text: $email, placeholder: TEXT_EMAIL, isSecure: false)
                        GenericTextField(text: $password, placeholder: TEXT_PASSWORD, isSecure: true)
                            .padding(.bottom, 10)
                        GenericButton(title: TEXT_SIGN_IN) {
                            loginStatus = session.signIn(email: email, password: password)
                        }
                        if(loginStatus != .fail && loginStatus != .success){
                            VStack{
                                switch loginStatus {
                                    case .email:
                                        HStack(){
                                            Text("Email is not found: ")
                                            Button(action: {
                                               showReset = true
                                            }, label: {
                                                Text("Reset Email!").bold()
                                                    .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                            })
                                        }.font(.footnote)
                                    case .password:
                                        HStack(){
                                            Text("Password is not correct: ")
                                            Button(action: {
                                                showReset = true
                                            }, label: {
                                                Text("Reset Password!").bold()
                                                    .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                            })
                                        }.font(.footnote)
                                    case .username:
                                        HStack(){
                                            Text("Username is not found: ")
                                            Button(action: {
                                                showReset = true
                                            }, label: {
                                                Text("Reset Username!").bold()
                                                    .foregroundColor(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
                                            })
                                        }.font(.footnote)
                                    default:
                                        Text("\(loginStatus)")
                                }
                            }.padding(EdgeInsets.mainTop / 2)
                        }
                        HStack(){
                            Text(TEXT_NEED_AN_ACCOUNT)
                            Button(action: {
                                newUserRegistration = true
                            }, label: {
                                Text(TEXT_SIGN_UP).bold()
                                    .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                            })
                        }.padding(EdgeInsets.mainTop / 2)
                            .font(.footnote)
                    }.padding()
                )
                //.background(Color.white.opacity(0.9))
                .clipped().cornerRadius(10).frame(height: 300)
            }
            if(showReset){
                FloatingPopupView(isVisible: $showReset, loginStatus: $loginStatus)
            }
        }
    }
}

#Preview{
    LoginView()
}

struct FloatingPopupView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isVisible: Bool
    @Binding var loginStatus: loginStatus
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        GenericBackground().opacity(0.99)
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                switch loginStatus {
                    case .email:
                    Text("Reset Email and Username").bold()
                        GenericTextField(text: $username,placeholder: TEXT_USERNAME, isSecure: false)
                        GenericTextField(text: $email, placeholder: TEXT_EMAIL, isSecure: false)
                    case .password:
                        Text("Reset Password").bold()
                        GenericTextField(text: $password, placeholder: TEXT_PASSWORD, isSecure: true)
                        GenericTextField(text: $confirmPassword, placeholder: TEXT_CONFRIM_PASSWORD, isSecure: true)
                    default:
                        Text("Reset User").bold()
                }
                Button(action: {
                    var userSession = LocalStorageManager.shared.retrieveUser()
                    switch loginStatus {
                        case .email:
                            userSession.email = email
                            userSession.username = username
                            LocalStorageManager.shared.saveUser(userSession)
                        case .password:
                            if(password == confirmPassword){
                                userSession.password = password
                                LocalStorageManager.shared.saveUser(userSession)
                            }
                        default:
                            print("nothing to login to")
                    }
                    //print(userSession)
                }) {
                    Text("Confirm")
                        .foregroundColor(colorScheme == .dark ? .white : .darkGray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(colorScheme == .dark ? .darkGray : COLOR_PRIMARY)                .cornerRadius(4)
                HStack(){
                    Spacer()
                    Button(action: {
                        isVisible = false
                    }, label: {
                        Text("Cancel").bold()
                            .foregroundColor(colorScheme == .dark ? .darkGray : COLOR_SECONDARY)
                    })
                    Spacer()
                }.font(.footnote).padding(.top)
            }
            .padding()
            .background(colorScheme == .dark ? COLOR_PRIMARY : COLOR_SECONDARY)
            .foregroundColor(colorScheme == .dark ? .darkGray : .white)
            .cornerRadius(8)
            .shadow(radius: 15)
        }
    }
}

//https://dribbble.com/shots/15266900-Mobile-app-login-screen-and-sign-up-flow
