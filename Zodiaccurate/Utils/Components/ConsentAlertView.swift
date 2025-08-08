//
//  ConsentAlertView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

struct ConsentAlertView: View {
    @Binding var showConsentAlert: Bool
    @State private var consentChecked = false
    @State private var showConsentError = false
    @State private var consentJiggle = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 18) {
                // Title
                Text("Consent Policies")
                    .font(.dmSansSemibold(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Your information is secure and encrypted.")
                    .font(.dmSansMedium(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Consent Row
                HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            consentChecked.toggle()
                            showConsentError = false
                        }
                    }) {
                        Image(systemName: consentChecked ? "checkmark.square.fill" : "square")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(consentChecked ? Color.accentGreen : (showConsentError ? Color.red : Color.white.opacity(0.7)))
                            .scaleEffect(consentJiggle ? 1.15 : 1.0)
                            .animation(.default, value: consentJiggle)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Agree to GDPR Privacy Policy")

                    // Wrap the text in a VStack for word wrapping
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("I agree to the Zodiaccurate ")
                                .foregroundColor(.white.opacity(0.85))
                                .font(.dmSansMedium(size: 15))
                                .fixedSize(horizontal: false, vertical: true)
                            Text("GDPR Privacy Policy")
                                .foregroundColor(Color.accentGreen)
                                .underline()
                                .font(.dmSansMedium(size: 15))
                                .fixedSize(horizontal: false, vertical: true)
                                .onTapGesture {
                                    if let url = URL(string: "https://zodiaccurate.com/privacy-policy") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 8)
                .padding(.bottom, 2)
                .offset(x: consentJiggle ? -12 : 0)
                .animation(consentJiggle ? .default : .none, value: consentJiggle)

                if showConsentError {
                    Text("You must agree to the GDPR Privacy Policy to continue.")
                        .foregroundColor(.red)
                        .font(.dmSansMedium(size: 14))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                        .transition(.opacity)
                }

                // Ok Button
                PrimaryGradientButton(title: "Ok") {
                    if consentChecked {
                        // Save consent flag to UserDefaults
                        UserDefaults.standard.set(true, forKey: "hasAcceptedConsentPolicies")
                        print("✅ User accepted consent policies, flag saved")
                        
                        // Post notification to trigger header opacity change
                        NotificationCenter.default.post(name: .consentAccepted, object: nil)
                        
                        // Post notification to trigger onboarding completion
                        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showConsentAlert = false
                        }
                    } else {
                        // Jiggle and highlight error
                        showConsentError = true
                        consentJiggle = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                            consentJiggle = false
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.indigo.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.accentGold.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
            .padding(.horizontal, 40)
            .offset(x: consentJiggle ? -12 : 0)
            .animation(consentJiggle ? .default : .none, value: consentJiggle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zIndex(9999)
    }
}

#Preview {
    ConsentAlertView(showConsentAlert: .constant(true))
        .background(Color.black)
}
