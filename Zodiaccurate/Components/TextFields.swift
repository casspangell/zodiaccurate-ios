import SwiftUI

// Global CustomBubbleShape radius constants
let bubbleCornerRadius: CGFloat = 20
let bubbleTopRightRatio: CGFloat = 0.5

// MARK: - Single Line Text Field Component
struct SingleLineTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    var backgroundColor: Color = Color.textFieldBackground
    
    @State private var shakeOffset: CGFloat = 0
    @State private var textChangeWorkItem: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                ZStack(alignment: .leading) {
                    // Placeholder text
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    
                    // Single line TextField - fixed height, no expansion
                    TextField("", text: $text)
                        .focused(isFocused)
                        .lineLimit(1) // Force single line
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(height: 44) // Fixed height for single line
                        .foregroundColor(.white)
                        .background(
                            CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)
                                .fill(backgroundColor)
                                .overlay(
                                    CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)
                                        .stroke(highlightInputField ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        .onChange(of: text) { _, newValue in
                            // Cancel any pending text change work
                            textChangeWorkItem?.cancel()
                            
                            // Debounce text changes to prevent multiple updates per frame
                            let workItem = DispatchWorkItem {
                                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    highlightInputField = false
                                }
                            }
                            
                            textChangeWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
                        }
                        .onChange(of: isFocused.wrappedValue) { _, newValue in
                            // Debounce focus changes to prevent multiple updates per frame
                            DispatchQueue.main.async {
                                if newValue { highlightInputField = false }
                            }
                        }
                        .offset(x: shakeOffset)
                        .animation(.default, value: shakeOffset)
                        .submitLabel(.send)
                        .onSubmit {
                            onSubmit()
                        }
                        .accessibilityLabel("Single line input field")
                        .accessibilityHint("Type your message and tap return to send")
                }
                
                // Clear button (X)
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .scale))
                    .accessibilityLabel("Clear text")
                    .accessibilityHint("Tap to clear the text field")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: highlightInputField) { _, newValue in
            // Debounce highlight changes to prevent multiple updates per frame
            DispatchQueue.main.async {
                if newValue {
                    withAnimation(.default) {
                        shakeOffset = -10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                        withAnimation(.default) { shakeOffset = 10 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                        withAnimation(.default) { shakeOffset = -6 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                        withAnimation(.default) { shakeOffset = 6 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.default) { shakeOffset = 0 }
                    }
                }
            }
        }
        .onDisappear {
            // Clean up work items when view disappears
            textChangeWorkItem?.cancel()
        }
    }
}

// MARK: - Multi Line Text Field Component
struct MultiLineTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    var backgroundColor: Color = Color.textFieldBackground
    var textColor: UIColor = .white
    
    @State private var shakeOffset: CGFloat = 0
    @State private var textFieldHeight: CGFloat = 100 // Initial height for 4 lines
    @State private var textChangeWorkItem: DispatchWorkItem?
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                ZStack(alignment: .topLeading) {
                    // Placeholder text
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color.white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                    
                    // Multi-line TransparentTextEditor - fixed height like original "text" type
                    TransparentTextEditor(text: $text, textColor: textColor)
                        .frame(minHeight: 100, maxHeight: 100)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)
                                .fill(backgroundColor)
                                .overlay(
                                    CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)
                                        .stroke(highlightInputField ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        .onChange(of: text) { _, newValue in
                            // Cancel any pending text change work
                            textChangeWorkItem?.cancel()
                            // Check if the new text contains a newline character (handle immediately)
                            if newValue.contains("\n") {
                                // Remove the newline and trigger submit
                                let cleanedText = newValue.replacingOccurrences(of: "\n", with: "")
                                text = cleanedText
                                onSubmit()
                                return
                            }
                            // Debounce other text changes to prevent multiple updates per frame
                            let workItem = DispatchWorkItem {
                                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    highlightInputField = false
                                }
                                // Calculate new height based on content
                                updateTextFieldHeight(for: newValue)
                            }
                            textChangeWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
                        }
                        .onChange(of: isFocused.wrappedValue) { _, newValue in
                            // Debounce focus changes to prevent multiple updates per frame
                            DispatchQueue.main.async {
                                if newValue { highlightInputField = false }
                            }
                        }
                        .offset(x: shakeOffset)
                        .animation(.default, value: shakeOffset)
                        .accessibilityLabel("Multi-line input field")
                        .accessibilityHint("Type your message and tap return to send")
                }
                
                // Clear button (X)
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.opacity.combined(with: .scale))
                    .accessibilityLabel("Clear text")
                    .accessibilityHint("Tap to clear the text field")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: highlightInputField) { _, newValue in
            // Debounce highlight changes to prevent multiple updates per frame
            DispatchQueue.main.async {
                if newValue {
                    withAnimation(.default) {
                        shakeOffset = -10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                        withAnimation(.default) { shakeOffset = 10 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                        withAnimation(.default) { shakeOffset = -6 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                        withAnimation(.default) { shakeOffset = 6 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.default) { shakeOffset = 0 }
                    }
                }
            }
        }
        .onDisappear {
            // Clean up work items when view disappears
            textChangeWorkItem?.cancel()
        }
    }
    
    // MARK: - Helper Functions
    private func updateTextFieldHeight(for text: String) {
        // Fixed height for 4 lines like original "text" type
        let estimatedHeight: CGFloat = 100 // 4 lines × 20 points + 20 points padding
        
        withAnimation(.easeInOut(duration: 0.2)) {
            textFieldHeight = estimatedHeight
        }
    }
}

// MARK: - Transparent Text Editor
struct TransparentTextEditor: UIViewRepresentable {
    @Binding var text: String
    var textColor: UIColor = .white
    var font: UIFont = .systemFont(ofSize: 17)

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = textColor
        textView.font = font
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Anchor content to the top
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = textColor
        uiView.font = font
        
        // Ensure content stays anchored to the top
        uiView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        uiView.textContainer.lineFragmentPadding = 0
        
        // Force scroll to top to anchor content
        DispatchQueue.main.async {
            uiView.setContentOffset(.zero, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TransparentTextEditor
        init(_ parent: TransparentTextEditor) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            
            // Keep content anchored to top when text changes
            DispatchQueue.main.async {
                textView.setContentOffset(.zero, animated: false)
            }
        }
    }
}





// MARK: - Typing Indicator Component
struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    let isAnimating: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.purple)
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.accentGold.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationAmount)
                            .animation(
                                isAnimating
                                ? Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2)
                                : .default,
                                value: animationAmount
                            )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            if isAnimating {
                self.animationAmount = 1.0
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            self.animationAmount = newValue ? 1.0 : 0.0
        }
    }
}

// MARK: - Login Field Components
struct LoginEmailField: View {
    @Binding var email: String
    @FocusState.Binding var focusedField: LoginView.Field?
    var onSubmit: () -> Void
    var onTap: () -> Void
    
    var body: some View {
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
                .id(LoginView.Field.email)
                .submitLabel(.next)
                .onSubmit(onSubmit)
                .onTapGesture(perform: onTap)
        }
    }
}

struct LoginPasswordField: View {
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var passwordStrength: PasswordStrength
    @FocusState.Binding var focusedField: LoginView.Field?
    var isRegistering: Bool
    var onSubmit: () -> Void
    var onTap: () -> Void
    var onPasswordChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            HStack {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .password)
                        .id(LoginView.Field.password)
                        .submitLabel(isRegistering ? .next : .go)
                        .onSubmit(onSubmit)
                        .onTapGesture(perform: onTap)
                        .onChange(of: password) { _, _ in
                            passwordStrength = passwordStrengthLevel(password)
                            onPasswordChange()
                        }
                } else {
                    SecureField("Password", text: $password)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .password)
                        .id(LoginView.Field.password)
                        .submitLabel(isRegistering ? .next : .go)
                        .onSubmit(onSubmit)
                        .onTapGesture(perform: onTap)
                        .onChange(of: password) { _, _ in
                            passwordStrength = passwordStrengthLevel(password)
                            onPasswordChange()
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
    }
}

struct LoginConfirmPasswordField: View {
    @Binding var confirmPassword: String
    @Binding var passwordsMatch: Bool
    @FocusState.Binding var focusedField: LoginView.Field?
    var onSubmit: () -> Void
    var onTap: () -> Void
    var onPasswordChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirm Password")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            HStack {
                SecureField("Confirm Password", text: $confirmPassword)
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .confirmPassword)
                    .id(LoginView.Field.confirmPassword)
                    .submitLabel(.done)
                    .onSubmit(onSubmit)
                    .onTapGesture(perform: onTap)
                    .onChange(of: confirmPassword) { _, _ in
                        onPasswordChange()
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
}


