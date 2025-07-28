//
//  LoginView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import SwiftUI
import FirebaseAuth
import SwiftData

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @StateObject private var onboardingDataAccess: OnboardingDataAccess
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
    
    init(isRegistering: Bool = false) {
        _isRegistering = State(initialValue: isRegistering)
        // Initialize OnboardingDataAccess with a temporary context - will be updated in onAppear
        _onboardingDataAccess = StateObject(wrappedValue: OnboardingDataAccess(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    private func loadLastLoggedInEmail() {
        if !isRegistering {
            email = OnboardingDataAccess.lastLoggedInEmail
        }
    }
    
    enum PasswordStrength: String {
        case weak = "Weak"
        case medium = "Medium"
        case strong = "Strong"
        var color: Color {
            switch self {
            case .weak: return .red
            case .medium: return .yellow
            case .strong: return .green
            }
        }
    }
    
    enum Field: Hashable {
        case email, password, confirmPassword
    }
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    func passwordStrengthLevel(_ password: String) -> PasswordStrength {
        let length = password.count >= 8
        let upper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let lower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let number = password.range(of: "[0-9]", options: .regularExpression) != nil
        let strong = length && upper && lower && number && password.count >= 12
        if strong { return .strong }
        if length && upper && lower && number { return .medium }
        return .weak
    }
    
    func passwordMeetsRequirements(_ password: String) -> (Bool, [Bool]) {
        let length = password.count >= 8
        let upper = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let lower = password.range(of: "[a-z]", options: .regularExpression) != nil
        let number = password.range(of: "[0-9]", options: .regularExpression) != nil
        return (length && upper && lower && number, [length, upper, lower, number])
    }
    
    var body: some View {
        ZStack {
            if onboardingDataAccess.isGeneratingHoroscope {
                LoadingView()
            } else {
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
                    CelestialSystem()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        .position(x: geo.size.width / 5, y: geo.size.height / 2)
                }

                // Orange overlay
                Color.backgroundPrimary.opacity(0.5)
                    .ignoresSafeArea()

                // Login/Register form
                ScrollViewReader { proxy in
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
                                    .focused($focusedField, equals: .email)
                                    .id(Field.email)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .password
                                        withAnimation { proxy.scrollTo(Field.password, anchor: .center) }
                                    }
                                    .onTapGesture {
                                        focusedField = .email
                                        withAnimation { proxy.scrollTo(Field.email, anchor: .center) }
                                    }
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Password")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Password", text: $password)
                                            .autocapitalization(.none)
                                            .focused($focusedField, equals: .password)
                                            .id(Field.password)
                                            .submitLabel(isRegistering ? .next : .go)
                                            .onSubmit {
                                                if isRegistering {
                                                    focusedField = .confirmPassword
                                                    withAnimation { proxy.scrollTo(Field.confirmPassword, anchor: .center) }
                                                } else {
                                                    focusedField = nil
                                                }
                                            }
                                            .onTapGesture {
                                                focusedField = .password
                                                withAnimation { proxy.scrollTo(Field.password, anchor: .center) }
                                            }
                                            .onChange(of: password) {
                                                passwordStrength = passwordStrengthLevel(password)
                                            }
                                    } else {
                                        SecureField("Password", text: $password)
                                            .autocapitalization(.none)
                                            .focused($focusedField, equals: .password)
                                            .id(Field.password)
                                            .submitLabel(isRegistering ? .next : .go)
                                            .onSubmit {
                                                if isRegistering {
                                                    focusedField = .confirmPassword
                                                    withAnimation { proxy.scrollTo(Field.confirmPassword, anchor: .center) }
                                                } else {
                                                    focusedField = nil
                                                }
                                            }
                                            .onTapGesture {
                                                focusedField = .password
                                                withAnimation { proxy.scrollTo(Field.password, anchor: .center) }
                                            }
                                            .onChange(of: password) {
                                                passwordStrength = passwordStrengthLevel(password)
                                            }
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
                                // Password strength indicator
                                if isRegistering && !password.isEmpty {
                                    HStack(spacing: 8) {
                                        Text("Strength: ")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(passwordStrength.rawValue)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(passwordStrength.color)
                                        Capsule()
                                            .fill(passwordStrength.color)
                                            .frame(width: 40, height: 6)
                                            .animation(.easeInOut, value: passwordStrength)
                                    }
                                }
                                // Password requirements
                                if isRegistering && !password.isEmpty {
                                    let (_, reqs) = passwordMeetsRequirements(password)
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Image(systemName: reqs[0] ? "checkmark.circle.fill" : "xmark.circle")
                                                .foregroundColor(reqs[0] ? .green : .red)
                                            Text("At least 8 characters")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        HStack(spacing: 6) {
                                            Image(systemName: reqs[1] ? "checkmark.circle.fill" : "xmark.circle")
                                                .foregroundColor(reqs[1] ? .green : .red)
                                            Text("One uppercase letter")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        HStack(spacing: 6) {
                                            Image(systemName: reqs[2] ? "checkmark.circle.fill" : "xmark.circle")
                                                .foregroundColor(reqs[2] ? .green : .red)
                                            Text("One lowercase letter")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        HStack(spacing: 6) {
                                            Image(systemName: reqs[3] ? "checkmark.circle.fill" : "xmark.circle")
                                                .foregroundColor(reqs[3] ? .green : .red)
                                            Text("One number")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            // Confirm Password Field (animated)
                            if isRegistering {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Confirm Password")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    HStack {
                                        SecureField("Confirm Password", text: $confirmPassword)
                                            .autocapitalization(.none)
                                            .focused($focusedField, equals: .confirmPassword)
                                            .id(Field.confirmPassword)
                                            .submitLabel(.done)
                                            .onSubmit {
                                                focusedField = nil
                                            }
                                            .onTapGesture {
                                                focusedField = .confirmPassword
                                                withAnimation { proxy.scrollTo(Field.confirmPassword, anchor: .center) }
                                            }
                                            .onChange(of: confirmPassword) {
                                                passwordsMatch = (password == confirmPassword)
                                            }
                                        if !confirmPassword.isEmpty {
                                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle")
                                                .foregroundColor(passwordsMatch ? .green : .red)
                                                .transition(.scale)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.08))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
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
                                                            print("🔘 LoginView: Calling signUp...")
                try await authManager.signUp(email: email, password: password, modelContext: modelContext)
                print("🔘 LoginView: signUp completed successfully")
                                        } else {
                                            print("🔘 LoginView: Calling signIn...")
                                            try await authManager.signIn(email: email, password: password)
                                            print("🔘 LoginView: signIn completed successfully")
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
        .onAppear {
            loadLastLoggedInEmail()
            // Update OnboardingDataAccess with the correct model context
            onboardingDataAccess.updateModelContext(modelContext)
            // Set up the authentication manager with the data access
            authManager.setOnboardingDataAccess(onboardingDataAccess)
        }
        .onChange(of: authManager.horoscopeSavedToCoreData) { oldValue, newValue in
            if newValue && isRegistering {
                // Horoscope has been saved, complete the sign-up process
                authManager.completeSignUp()
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

