import SwiftUI

// MARK: - Tutorial Bubble Types
enum TutorialType {
    case speech
    case voice
    case custom(title: String, subtitle: String, icon: String)
    
    var title: String {
        switch self {
        case .speech:
            return "Try voice input!"
        case .voice:
            return "Voice input available"
        case .custom(let title, _, _):
            return title
        }
    }
    
    var subtitle: String {
        switch self {
        case .speech:
            return "Tap the microphone button to use speech-to-text"
        case .voice:
            return "Use your voice to respond quickly"
        case .custom(_, let subtitle, _):
            return subtitle
        }
    }
    
    var icon: String {
        switch self {
        case .speech, .voice:
            return "mic.fill"
        case .custom(_, _, let icon):
            return icon
        }
    }
}

// MARK: - Tutorial Bubble Styling
struct TutorialBubbleStyle {
    let mainTextSize: CGFloat
    let subTextSize: CGFloat
    let bodyColor: Color
    let arrowColor: Color
    let glowColor: Color
    
    static let `default` = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.deepBlue.opacity(0.95),
        arrowColor: Color.accentGold,
        glowColor: Color.accentGold.opacity(0.2)
    )
    
    static let speech = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.deepBlue.opacity(0.95),
        arrowColor: Color.accentGold,
        glowColor: Color.accentGold.opacity(0.2)
    )
    
    static let voice = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.deepBlue.opacity(0.95),
        arrowColor: Color.accentGold,
        glowColor: Color.accentGold.opacity(0.2)
    )
    
    static let info = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.indigo.opacity(0.95),
        arrowColor: Color.azure,
        glowColor: Color.azure.opacity(0.2)
    )
    
    static let success = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.accentGreen.opacity(0.95),
        arrowColor: Color.accentGreen,
        glowColor: Color.accentGreen.opacity(0.2)
    )
    
    static let warning = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.accentGold.opacity(0.95),
        arrowColor: Color.accentGold,
        glowColor: Color.accentGold.opacity(0.2)
    )
    
    static let purple = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.accentPurple.opacity(0.95),
        arrowColor: Color.magenta,
        glowColor: Color.magenta.opacity(0.2)
    )
    
    static let custom = TutorialBubbleStyle(
        mainTextSize: 16,
        subTextSize: 13,
        bodyColor: Color.deepBlue.opacity(0.95),
        arrowColor: Color.accentGold,
        glowColor: Color.accentGold.opacity(0.2)
    )
}

// MARK: - Reusable Tutorial Bubble
struct TutorialBubble: View {
    let type: TutorialType
    let arrowPosition: ArrowPosition
    let pulse: Bool
    let onDismiss: (() -> Void)?
    let style: TutorialBubbleStyle
    let showArrow: Bool
    
    @State private var bounceScale: CGFloat = 1.0
    
    init(
        type: TutorialType,
        arrowPosition: ArrowPosition = .bottom,
        pulse: Bool = false,
        onDismiss: (() -> Void)? = nil,
        style: TutorialBubbleStyle = .default,
        showArrow: Bool = true
    ) {
        self.type = type
        self.arrowPosition = arrowPosition
        self.pulse = pulse
        self.onDismiss = onDismiss
        self.style = style
        self.showArrow = showArrow
    }
    
    var body: some View {
        ZStack {
            TutorialPopUp(
                arrowPosition: arrowPosition,
                title: type.title,
                subtitle: type.subtitle,
                bodyColor: style.bodyColor,
                arrowColor: style.arrowColor,
                glowColor: style.glowColor,
                pulse: pulse,
                mainTextSize: style.mainTextSize,
                subTextSize: style.subTextSize,
                showArrow: showArrow
            )
            .scaleEffect(bounceScale)
            
            // "Tap to dismiss" text positioned opposite to arrow
            if onDismiss != nil {
                Text("Tap to dismiss")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                    .offset(dismissTextOffset)
                    .zIndex(1000)
            }
        }
        .onTapGesture {
            onDismiss?()
        }
        .onAppear {
            startBounceAnimation()
        }
        .onChange(of: pulse) { _, newValue in
            if newValue {
                startBounceAnimation()
            } else {
                stopBounceAnimation()
            }
        }
    }
    
    private var dismissTextOffset: CGSize {
        if !showArrow {
            // No arrow, place text below by default
            return CGSize(width: 0, height: 60)
        }
        
        switch arrowPosition {
        case .top:
            // Arrow points up, text goes below
            return CGSize(width: 0, height: 60)
        case .bottom:
            // Arrow points down, text goes above
            return CGSize(width: 0, height: -60)
        case .left:
            // Arrow points left, text goes to the right
            return CGSize(width: 80, height: 0)
        case .right:
            // Arrow points right, text goes to the left
            return CGSize(width: -80, height: 0)
        }
    }
    
    private func startBounceAnimation() {
        guard pulse else { return }
        
        // Subtle bounce animation that syncs with the arrow pulse
        // Small delay to create a more natural, staggered effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bounceScale = 1.03 // Very subtle scale increase
            }
        }
    }
    
    private func stopBounceAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            bounceScale = 1.0
        }
    }
}

// MARK: - Convenience Initializers for Common Use Cases
extension TutorialBubble {
    static func speech(arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil, style: TutorialBubbleStyle = .speech) -> TutorialBubble {
        TutorialBubble(type: .speech, arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: style)
    }
    
    static func voice(arrowPosition: ArrowPosition = .top, pulse: Bool = false, onDismiss: (() -> Void)? = nil, style: TutorialBubbleStyle = .voice) -> TutorialBubble {
        TutorialBubble(type: .voice, arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: style)
    }
    
    static func custom(title: String, subtitle: String, icon: String = "info.circle", arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil, style: TutorialBubbleStyle = .custom) -> TutorialBubble {
        TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: icon), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: style)
    }
    
    // Pre-styled convenience methods
    static func info(title: String, subtitle: String, arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil) -> TutorialBubble {
        TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: "info.circle"), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: .info)
    }
    
    static func success(title: String, subtitle: String, arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil) -> TutorialBubble {
        TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: "checkmark.circle"), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: .success)
    }
    
    static func warning(title: String, subtitle: String, arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil) -> TutorialBubble {
        TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: "exclamationmark.triangle"), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: .warning)
    }
    
    static func purple(title: String, subtitle: String, arrowPosition: ArrowPosition = .bottom, pulse: Bool = false, onDismiss: (() -> Void)? = nil) -> TutorialBubble {
        TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: "sparkles"), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: .purple)
    }
    
    // Custom styling with specific text sizes
    static func customStyled(
        title: String,
        subtitle: String,
        icon: String = "info.circle",
        arrowPosition: ArrowPosition = .bottom,
        pulse: Bool = false,
        onDismiss: (() -> Void)? = nil,
        mainTextSize: CGFloat = 16,
        subTextSize: CGFloat = 13,
        bodyColor: Color = Color.deepBlue.opacity(0.95),
        arrowColor: Color = Color.accentGold,
        glowColor: Color = Color.accentGold.opacity(0.2)
    ) -> TutorialBubble {
        let customStyle = TutorialBubbleStyle(
            mainTextSize: mainTextSize,
            subTextSize: subTextSize,
            bodyColor: bodyColor,
            arrowColor: arrowColor,
            glowColor: glowColor
        )
        return TutorialBubble(type: .custom(title: title, subtitle: subtitle, icon: icon), arrowPosition: arrowPosition, pulse: pulse, onDismiss: onDismiss, style: customStyle)
    }
    
    // Tutorial bubble without arrow
    static func speechNoArrow(pulse: Bool = false, onDismiss: (() -> Void)? = nil, style: TutorialBubbleStyle = .speech) -> TutorialBubble {
        TutorialBubble(type: .speech, arrowPosition: .bottom, pulse: pulse, onDismiss: onDismiss, style: style, showArrow: false)
    }
}

// MARK: - Legacy Support (for backward compatibility)
struct SpeechTutorialBubble: View {
    var body: some View {
        TutorialBubble.speech()
    }
}

/*
 MARK: - Usage Examples
 
 // Basic speech tutorial
 TutorialBubble.speech(arrowPosition: .bottom, pulse: true)
 
 // Voice tutorial with custom style
 TutorialBubble.voice(arrowPosition: .top, pulse: true, style: .info)
 
 // Info tutorial with custom colors
 TutorialBubble.info(
     title: "New Feature!",
     subtitle: "Try the voice input",
     arrowPosition: .bottom
 )
 
 // Success tutorial
 TutorialBubble.success(
     title: "Great job!",
     subtitle: "You've completed the tutorial",
     arrowPosition: .top
 )
 
 // Warning tutorial
 TutorialBubble.warning(
     title: "⚠️ Important",
     subtitle: "Please enable microphone access",
     arrowPosition: .bottom
 )
 
 // Purple themed tutorial
 TutorialBubble.purple(
     title: "✨ Magic Feature",
     subtitle: "Discover hidden powers",
     arrowPosition: .left
 )
 
 // Custom styled tutorial with specific text sizes and colors
 TutorialBubble.customStyled(
     title: "🎯 Custom Tutorial",
     subtitle: "With custom styling",
     icon: "target",
     arrowPosition: .right,
     mainTextSize: 18,
     subTextSize: 14,
     bodyColor: Color.accentPurple.opacity(0.95),
     arrowColor: Color.magenta,
     glowColor: Color.magenta.opacity(0.3)
 )
 */

struct InputTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    var onTap: () -> Void
    @Binding var highlightInputField: Bool
    var onHeightChange: ((CGFloat) -> Void)?
    
    @State private var shakeOffset: CGFloat = 0
    @State private var textFieldHeight: CGFloat = 40 // Initial height
    @State private var previousHeight: CGFloat = 40 // Track previous height
    
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
                        .frame(minHeight: 40, maxHeight: 120) // Min and max height constraints
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
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: TextEditorSizePreferenceKey.self, value: geometry.size)
                                    .onPreferenceChange(TextEditorSizePreferenceKey.self) { size in
                                        // Debounce preference updates to prevent multiple updates per frame
                                        DispatchQueue.main.async {
                                            // Only check for height changes if we have a previous height (not initial load)
                                            if previousHeight > 0 {
                                                // Check if height has changed significantly (more than 5 points)
                                                let heightDifference = size.height - previousHeight
                                                if abs(heightDifference) > 5 {
                                                    // Call the height change callback
                                                    onHeightChange?(heightDifference)
                                                }
                                            }
                                            
                                            // Update the previous height
                                            previousHeight = size.height
                                        }
                                    }
                            }
                        )
                        .onChange(of: text) { _, newValue in
                            // Debounce text changes to prevent multiple updates per frame
                            DispatchQueue.main.async {
                                // Check if the new text contains a newline character
                                if newValue.contains("\n") {
                                    // Remove the newline and trigger submit
                                    let cleanedText = newValue.replacingOccurrences(of: "\n", with: "")
                                    text = cleanedText
                                    onSubmit()
                                    return
                                }
                                
                                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    highlightInputField = false
                                }
                                // Calculate new height based on content
                                updateTextFieldHeight(for: newValue)
                            }
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
                        isFocused.wrappedValue = false
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
    }
    
    // MARK: - Helper Functions
    private func updateTextFieldHeight(for text: String) {
        // Calculate approximate height based on text content
        let lines = text.components(separatedBy: .newlines).count
        let estimatedHeight = max(40, min(120, CGFloat(lines) * 20 + 20)) // 20 points per line + padding
        
        withAnimation(.easeInOut(duration: 0.2)) {
            textFieldHeight = estimatedHeight
        }
    }
}

// Preference key for TextEditor size
struct TextEditorSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Input Section Component
struct InputSection: View {
    @Binding var currentInput: String
    let currentStep: ConversationStep
    let onSend: () -> Void
    let isTextFieldFocused: FocusState<Bool>.Binding
    let onFrameChange: (CGRect) -> Void
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            InputTextField(
                text: $currentInput,
                placeholder: currentStep.placeholder,
                isFocused: isTextFieldFocused,
                onSubmit: onSend,
                onTap: { isTextFieldFocused.wrappedValue = true },
                highlightInputField: $highlightInputField,
                onHeightChange: onHeightChange
            )
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            onFrameChange(geometry.frame(in: .global))
                        }
                }
            )
            .onTapGesture {
                isTextFieldFocused.wrappedValue = true
            }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentGold)
                    .opacity(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .opacity(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 0.6)
                    )
                    .scaleEffect(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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


