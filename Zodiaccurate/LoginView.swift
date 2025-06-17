//
//  LoginView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isRegistering = false
    @State private var showingResetPassword = false
    @State private var resetEmail = ""
    
    var body: some View {
        ZStack {
            // Cosmic background (reuse from splash, no starfield)
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A0B2E"), location: 0.0),
                    .init(color: Color(hex: "0F051A"), location: 0.7),
                    .init(color: Color.black, location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()

            // Vignette overlay for black corners/edges
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.6),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()
            .blendMode(.multiply)
            .allowsHitTesting(false)

            // Celestial bodies animation
            GeometryReader { geo in
                CelestialSystemBackground()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .position(x: geo.size.width / 5, y: geo.size.height / 2)
            }

            // Orange overlay
            Color.backgroundPrimary.opacity(0.5)
                .ignoresSafeArea()

            // Login/Register form
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 60)
                    Text(isRegistering ? "Create Account" : "Welcome to\nZodiaccurate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    Text(isRegistering ? "Enter your details to create an account" : "Enter your email address and password")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.7))
                        .padding(.bottom, 16)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Email")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Password")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $password)
                                    .autocapitalization(.none)
                            }
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }

                    if !isRegistering {
                        HStack {
                            Spacer()
                            Button(action: { showingResetPassword = true }) {
                                Text("Forgot Password?")
                                    .poppinsMediumButton(size: 15)
                                    .foregroundColor(Color(hex: "B39DDB"))
                            }
                        }
                    }

                    PrimaryGradientButton(title: isRegistering ? "Create Account" : "Sign In") {
                        Task {
                            do {
                                if isRegistering {
                                    try await authManager.signUp(email: email, password: password)
                                } else {
                                    try await authManager.signIn(email: email, password: password)
                                }
                            } catch {
                                // Error is handled by AuthenticationManager
                            }
                        }
                    }
                    .disabled(authManager.isLoading)
                    .overlay {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }

                    // Error message label
                    if let error = authManager.error {
                        Text(error)
                            .foregroundColor(.red)
                            .poppinsMediumButton(size: 15)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .transition(.opacity)
                    }

                    Spacer()

                    HStack {
                        Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 15, weight: .regular))
                        Button(action: { isRegistering.toggle() }) {
                            Text(isRegistering ? "Sign In" : "Register for Free")
                                .foregroundColor(Color(hex: "B39DDB"))
                                .poppinsMediumButton(size: 15)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 500)
            }
        }
        .alert("Reset Password", isPresented: $showingResetPassword) {
            TextField("Email", text: $resetEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            Button("Cancel", role: .cancel) { }
            Button("Send Reset Link") {
                Task {
                    do {
                        try await authManager.resetPassword(email: resetEmail)
                        resetEmail = ""
                    } catch {
                        // Error is handled by AuthenticationManager
                    }
                }
            }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}

