import SwiftUI
import Speech
// Make sure SpeechTutorialBubble is available in the project
// import the file or module if needed
// If SpeechTutorialBubble is in another file, ensure it is accessible here

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

struct TTSInputTextField: View {
    @Binding var text: String
    var placeholder: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void
    var onTap: () -> Void
    var onSpeech: () -> Void
    var isRecording: Bool
    var showTutorial: Bool
    var microphonePulse: Bool
    @Binding var highlightInputField: Bool
    
    @State private var shakeOffset: CGFloat = 0
    @State private var textFieldHeight: CGFloat = 40 // Initial height
    
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
                        .onChange(of: text) { _, newValue in
                            if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                highlightInputField = false
                            }
                            // Calculate new height based on content
                            updateTextFieldHeight(for: newValue)
                        }
                        .onSubmit {
                            print("🔵 DEBUG: TextField onSubmit triggered")
                            onSubmit()
                        }
                        .submitLabel(.send)
                        .accessibilityLabel("Message input field")
                        .accessibilityHint("Type your message and tap return to send")
                        .onChange(of: isFocused.wrappedValue) { _, newValue in
                            print("🔵 DEBUG: TextField focus changed to: \(newValue)")
                            if newValue { highlightInputField = false }
                        }
                        .offset(x: shakeOffset)
                        .animation(.default, value: shakeOffset)
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
            
            Button(action: {
                print("🔵 DEBUG: Microphone button action triggered")
                // Unfocus the text field when microphone is tapped
                isFocused.wrappedValue = false
                // Trigger speech recognition
                onSpeech()
            }) {
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(Color.accentGold.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .scaleEffect(microphonePulse ? 1.4 : 0.8)
                        .opacity(microphonePulse ? 0.8 : 0.0)
                        .animation(microphonePulse ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .easeInOut(duration: 0.3), value: microphonePulse)
                    
                    // Main button
                    Circle()
                        .fill(isRecording ? Color.red : Color.white)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(isRecording ? .easeInOut(duration: 0.3).repeatForever(autoreverses: true) : .easeInOut(duration: 0.2), value: isRecording)
                    
                    // Icon
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .foregroundColor(isRecording ? .white : Color(.darkGray))
                        .font(.system(size: 16, weight: .medium))
                        .scaleEffect(isRecording ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .id("microphoneButton")
            .frame(width: 50, height: 50)
            .onTapGesture {
                print("🔵 DEBUG: Microphone button tap gesture detected")
            }
            // Removed tutorial bubble overlay here
            .overlay(
                // Spotlight effect
                Group {
                    if showTutorial {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.accentPurple.opacity(0.3), location: 0.0),
                                        .init(color: Color.accentPurple.opacity(0.1), location: 0.5),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(microphonePulse ? 1.2 : 0.8)
                            .opacity(microphonePulse ? 0.6 : 0.0)
                            .animation(microphonePulse ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .easeInOut(duration: 0.3), value: microphonePulse)
                            .zIndex(1002)
                            .allowsHitTesting(false) // Don't intercept taps
                    }
                }
            )
        }
        .onChange(of: highlightInputField) { _, newValue in
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
