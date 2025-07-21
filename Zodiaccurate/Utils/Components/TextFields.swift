import SwiftUI

struct InputTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    var onTap: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    var backgroundColor: Color = Color(.systemGray6)
    
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
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    
                    // Dynamic TextEditor
                    TextEditor(text: $text)
                        .focused(isFocused)
                        .frame(minHeight: 100, maxHeight: 100) // Fixed height for 4 lines
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
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
                        .submitLabel(.send)
                        .accessibilityLabel("Message input field")
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
        // Fixed height for 4 lines
        let estimatedHeight: CGFloat = 100 // 4 lines × 20 points + 20 points padding
        
        withAnimation(.easeInOut(duration: 0.2)) {
            textFieldHeight = estimatedHeight
        }
    }
}

// MARK: - Single Line Text Field Component
struct SingleLineTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    var onTap: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    var backgroundColor: Color = Color(.systemGray6)
    
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
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
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
    var onTap: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    var backgroundColor: Color = Color(.systemGray6)
    
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
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    
                    // Multi-line TextEditor - fixed height like original "text" type
                    TextEditor(text: $text)
                        .focused(isFocused)
                        .frame(minHeight: 100, maxHeight: 100) // Fixed height for 4 lines like original
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
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
                        .submitLabel(.send)
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


