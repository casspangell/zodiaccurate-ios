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
    @State private var isPasswordVisible = false

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

            // Celestial bodies animation (centered, no starfield)
            GeometryReader { geo in
                CelestialSystemBackground()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .position(x: geo.size.width / 5, y: geo.size.height / 2)
            }

            // Orange overlay above celestial background, below login form
            Color.backgroundPrimary.opacity(0.7)
                .ignoresSafeArea()

            // Full-screen glass effect
//            Color.clear
//                .background(.ultraThinMaterial)
//                .ignoresSafeArea()

//             Login form
            VStack(alignment: .leading, spacing: 24) {
                Spacer().frame(height: 60)
                Text("Welcome to\nZodiaccurate")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                Text("Enter your email address and password")
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

                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Forget Password?")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(hex: "B39DDB"))
                    }
                }

                Button(action: {
                    // Handle login
                }) {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text("SIGN IN")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F8CFF").opacity(0.7), Color(hex: "B39DDB").opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.top, 8)

                Spacer()

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.system(size: 15, weight: .regular))
                    Button(action: {}) {
                        Text("Register for Free")
                            .foregroundColor(Color(hex: "B39DDB"))
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 500)
        }
    }
}

#Preview {
    LoginView()
}

