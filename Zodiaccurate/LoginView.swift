//
//  LoginView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color("#181122")
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Spacer()
                    Text("Horoscope")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Welcome
                Text("Welcome back")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Email
                TextField("Email", text: $email)
                    .padding()
                    .background(Color("#322447"))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                // Password
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color("#322447"))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Forgot
                HStack {
                    Spacer()
                    Text("Forgot password?")
                        .foregroundColor(Color("#a793c8"))
                        .font(.footnote)
                        .underline()
                        .padding(.trailing)
                }
                .padding(.top, 6)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    // Handle login
                }) {
                    Text("Log in")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color("#6719e5"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                
                // Signup Buttons
                HStack(spacing: 12) {
                    Button("Sign up") {
                        // Handle sign up
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Continue with email") {
                        // Handle alt login
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding()
                
                Spacer().frame(height: 12)
            }
        }
    }
}

