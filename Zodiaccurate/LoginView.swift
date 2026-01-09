//
//  LoginView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isRegistering: Bool
    @State private var showingResetPassword = false
    @State private var resetEmail = ""
    @State private var confirmPassword = ""
    @State private var passwordStrength: PasswordStrength = .weak
    @State private var emailValid = true
    @State private var passwordsMatch = true
    @State private var showAgreementError = false
    @FocusState private var focusedField: Field?
    @State private var showHoroscopeSavedAlert: Bool = false
    @State private var generatedHoroscope: String = ""
    @State private var agreedToTerms = false
    @State private var selectedTimezone: String = ""
    
    init(isRegistering: Bool = false) {
        _isRegistering = State(initialValue: isRegistering)
    }
    
    private func loadLastLoggedInEmail() {
//        if !isRegistering {
//            email = OnboardingDataAccess.lastLoggedInEmail
//        }
    }
    
    enum Field: Hashable {
        case email, password, confirmPassword, timezone
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 60)
            Text(isRegistering ? "Create Account" : "Welcome to\nZodiaccurate")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 4)
            Text(isRegistering ? "Enter your details to create an account" : "Enter your email address and password")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.7))
                .padding(.bottom, 16)
        }
    }
    
    var body: some View {
        ZStack {
            mainContent
        }
        .onAppear {
            loadLastLoggedInEmail()
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
    
    private var mainContent: some View {
        ZStack {
            ZodiacAuroraBackground()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerView

                                LoginEmailField(
                                    email: $email,
                                    focusedField: $focusedField,
                                    onSubmit: {
                                        focusedField = .password
                                        withAnimation { proxy.scrollTo(Field.password, anchor: .center) }
                                    },
                                    onTap: {
                                        focusedField = .email
                                        withAnimation { proxy.scrollTo(Field.email, anchor: .center) }
                                    }
                                )

                                LoginPasswordField(
                                    password: $password,
                                    isPasswordVisible: $isPasswordVisible,
                                    passwordStrength: $passwordStrength,
                                    focusedField: $focusedField,
                                    isRegistering: isRegistering,
                                    onSubmit: {
                                        if isRegistering {
                                            focusedField = .confirmPassword
                                            withAnimation { proxy.scrollTo(Field.confirmPassword, anchor: .center) }
                                        } else {
                                            focusedField = nil
                                        }
                                    },
                                    onTap: {
                                        focusedField = .password
                                        withAnimation { proxy.scrollTo(Field.password, anchor: .center) }
                                    },
                                    onPasswordChange: {
                                        // Password change is handled within the component
                                    }
                                )
                                // Confirm Password Field (animated)
                                if isRegistering {
                                    LoginConfirmPasswordField(
                                        confirmPassword: $confirmPassword,
                                        passwordsMatch: $passwordsMatch,
                                        focusedField: $focusedField,
                                        onSubmit: {
                                            focusedField = .timezone
                                            withAnimation { proxy.scrollTo(Field.timezone, anchor: .center) }
                                        },
                                        onTap: {
                                            focusedField = .confirmPassword
                                            withAnimation { proxy.scrollTo(Field.confirmPassword, anchor: .center) }
                                        },
                                        onPasswordChange: {
                                            passwordsMatch = (password == confirmPassword)
                                        }
                                    )
                                    
                                    // Timezone Field
                                    LoginTimezoneField(
                                        selectedTimezone: $selectedTimezone,
                                        focusedField: $focusedField,
                                        onTap: {
                                            focusedField = .timezone
                                            withAnimation { proxy.scrollTo(Field.timezone, anchor: .center) }
                                        }
                                    )
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

                                // Required Checkbox for registration
                                if isRegistering {
                                    HStack(alignment: .center, spacing: 10) {
                                        Button(action: { withAnimation { agreedToTerms.toggle(); showAgreementError = false } }) {
                                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                                .resizable()
                                                .frame(width: 22, height: 22)
                                                .foregroundColor(agreedToTerms ? Color.accentGreen : Color.white.opacity(0.7))
                                                .animation(.easeInOut, value: agreedToTerms)
                                        }
                                        HStack(spacing: 0) {
                                            Text("I agree to the ")
                                                .foregroundColor(.white.opacity(0.85))
                                                .poppinsMediumButton(size: 15)
                                            Text("Terms")
                                                .foregroundColor(Color.accentGreen)
                                                .underline()
                                                .poppinsMediumButton(size: 15)
                                                .onTapGesture {
                                                    if let url = URL(string: "https://zodiaccurate.com/terms-and-conditions") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                            Text(" and ")
                                                .foregroundColor(.white.opacity(0.85))
                                                .poppinsMediumButton(size: 15)
                                            Text("Privacy Policy")
                                                .foregroundColor(Color.accentGreen)
                                                .underline()
                                                .poppinsMediumButton(size: 15)
                                                .onTapGesture {
                                                    if let url = URL(string: "https://zodiaccurate.com/privacy-policy") {
                                                        UIApplication.shared.open(url)
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    // Agreement error label
                                    if showAgreementError {
                                        Text("You must agree to the Terms and Privacy Policy to create an account.")
                                            .foregroundColor(.red)
                                            .poppinsMediumButton(size: 14)
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 2)
                                            .transition(.opacity)
                                    }
                                }

                                PrimaryGradientButton(title: isRegistering ? "Create Account" : "Sign In") {
                                    Task {
                                        print("🔘 LoginView: Button tapped, isRegistering = \(isRegistering)")
                                        if isRegistering {
                                            // Validate all fields on submit
                                            var errorMsg: String? = nil
                                            let (passwordValid, _) = passwordMeetsRequirements(password)
                                            if !validateEmail(email) {
                                                errorMsg = "Please enter a valid email address."
                                            } else if !passwordValid {
                                                errorMsg = "Password must be at least 8 characters, include uppercase, lowercase, and a number."
                                            } else if !passwordsMatch {
                                                errorMsg = "Passwords do not match."
                                            } else if !agreedToTerms {
                                                withAnimation { showAgreementError = true }
                                                return
                                            }
                                            if let errorMsg = errorMsg {
                                                authManager.error = errorMsg
                                                // Scroll to error label with delay to ensure it's in the view hierarchy
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                                    withAnimation {
                                                        proxy.scrollTo("errorLabel", anchor: .center)
                                                    }
                                                }
                                                return
                                            }
                                        }
                                        if isRegistering && !agreedToTerms {
                                            withAnimation { showAgreementError = true }
                                            return
                                        }
                                        do {
                                            if isRegistering {
                                                // Save timezone to UserDefaults before signup
                                                if !selectedTimezone.isEmpty {
                                                    UserDefaults.standard.set(selectedTimezone, forKey: "userTimezone")
                                                    print("🌍 Timezone saved: \(selectedTimezone)")
                                                }
                                                
                                                print("🔘 LoginView: Calling signUp...")
                                                try await authManager.signUp(email: email, password: password)
                                                print("🔘 LoginView: signUp completed successfully")
                                                
                                                // Save welcome horoscope to Firebase at /zodiac/{uuid}/welcome
                                                if let userId = authManager.user?.uid {
                                                    do {
                                                        // Fetch welcome horoscope from SwiftData
                                                        let descriptor = FetchDescriptor<Horoscope>(
                                                            predicate: #Predicate<Horoscope> { $0.key == "welcome" }
                                                        )
                                                        let horoscopes = try modelContext.fetch(descriptor)
                                                        
                                                        if let welcomeHoroscope = horoscopes.first {
                                                            let firebaseService = FirebaseDatabaseService()
                                                            try await firebaseService.saveHoroscope(userId: userId, horoscope: welcomeHoroscope)
                                                            print("✅ Welcome horoscope saved to Firebase: /zodiac/\(userId)/welcome")
                                                        } else {
                                                            print("⚠️ No welcome horoscope found in SwiftData to save to Firebase")
                                                        }
                                                    } catch {
                                                        print("❌ Failed to save welcome horoscope to Firebase: \(error)")
                                                        // Continue even if Firebase save fails
                                                    }
                                                } else {
                                                    print("⚠️ No user ID available to save welcome horoscope to Firebase")
                                                }
                                            } else {
                                                print("🔘 LoginView: Calling signIn...")
                                                try await authManager.signIn(email: email, password: password)
                                                print("🔘 LoginView: signIn completed successfully")
                                                
                                                // Sync Firebase data to SwiftData after successful login
                                                print("🔄 LoginView: Starting data sync from Firebase...")
                                                await authManager.syncDataFromFirebase(modelContext: modelContext)
                                                print("✅ LoginView: Data sync completed")
                                            }
                                        } catch {
                                            print("🔘 LoginView: Authentication error - \(error)")
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
                                .onChange(of: authManager.isLoading) { oldValue, newValue in
                                    print("🔘 LoginView: Loading state changed from \(oldValue) to \(newValue)")
                                }

                                // Error message label (other errors)
                                if let error = authManager.error {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .poppinsMediumButton(size: 15)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 4)
                                        .transition(.opacity)
                                        .id("errorLabel")
                                }

                                Spacer()

                                HStack {
                                    Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(.system(size: 15, weight: .regular))
                                    Button(action: {
                                        isRegistering.toggle()
                                        authManager.error = nil
                                        confirmPassword = ""
                                        selectedTimezone = ""
                                        showAgreementError = false
                                        
                                        // Clear email when switching to register mode
                                        if isRegistering {
                                            email = ""
                                        } else {
                                            // Load last logged-in email when switching to sign-in mode
                                            loadLastLoggedInEmail()
                                        }
                                    }) {
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
                        .background(Color.clear.contentShape(Rectangle())
                            .onTapGesture {
                                focusedField = nil
                            })
                    }
                }
            }
        }

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
} 
