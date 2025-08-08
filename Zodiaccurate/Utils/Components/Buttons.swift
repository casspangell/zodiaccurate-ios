import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(Color.utilsBackground)
            .foregroundColor(.white)
            .cornerRadius(30)
    }
}

struct PrimaryGradientButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .poppinsMediumButton(size: 17)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .textCase(.uppercase)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// Circular icon button with indigo-sapphire gradient background
struct CircleIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.sapphire]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                // Icon
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .frame(width: 40, height: 40)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        .accessibilityLabel(accessibilityLabel)
    }
}

// Outlined circular asset image button
struct CircleAssetButton: View {
    let assetName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(9)
                .background(Color.clear)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                )
        }
        .frame(width: 40, height: 40)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Send Button Component
struct SendButton: View {
    let onSend: () -> Void
    let isEnabled: Bool
    let size: CGFloat
    let iconSize: CGFloat
    
    init(onSend: @escaping () -> Void, isEnabled: Bool = true, size: CGFloat = 44, iconSize: CGFloat = 18) {
        self.onSend = onSend
        self.isEnabled = isEnabled
        self.size = size
        self.iconSize = iconSize
    }
    
    var body: some View {
        Button(action: onSend) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(isEnabled ? Color.accentGold : Color.gray)
                .opacity(isEnabled ? 1.0 : 0.5)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .opacity(isEnabled ? 0.6 : 0.3)
                )
                .scaleEffect(isEnabled ? 1.0 : 0.9)
                .animation(.easeInOut(duration: 0.2), value: isEnabled)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Clear Button Component
struct ClearButton: View {
    let onClear: () -> Void
    let size: CGFloat
    let color: Color
    
    init(onClear: @escaping () -> Void, size: CGFloat = 16, color: Color = .gray) {
        self.onClear = onClear
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Button(action: onClear) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(color)
                .font(.system(size: size))
        }
        .buttonStyle(PlainButtonStyle())
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Clear text")
        .accessibilityHint("Tap to clear the text field")
    }
}



// MARK: - Audio Playback Button Component
struct AudioPlaybackButton: View {
    let isPlaying: Bool
    let onToggle: () -> Void
    let size: CGFloat
    let showLabel: Bool
    
    init(isPlaying: Bool = false, onToggle: @escaping () -> Void, size: CGFloat = 56, showLabel: Bool = false) {
        self.isPlaying = isPlaying
        self.onToggle = onToggle
        self.size = size
        self.showLabel = showLabel
    }
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    
                    // Icon
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundColor(.white)
                        .offset(x: isPlaying ? 0 : 2) // Slight offset for play icon to center it
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 3)
                .scaleEffect(isPlaying ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isPlaying)
                
                if showLabel {
                    Text(isPlaying ? "Pause" : "Play")
                        .poppinsMediumButton(size: 12)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isPlaying ? "Pause audio" : "Play audio")
        .accessibilityHint("Tap to \(isPlaying ? "pause" : "play") the audio content")
    }
}

// MARK: - Audio Control Button Component (Smaller variant)
struct AudioControlButton: View {
    let isPlaying: Bool
    let onToggle: () -> Void
    let size: CGFloat
    
    init(isPlaying: Bool = false, onToggle: @escaping () -> Void, size: CGFloat = 44) {
        self.isPlaying = isPlaying
        self.onToggle = onToggle
        self.size = size
    }
    
    var body: some View {
        Button(action: onToggle) {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: size, height: size)
                .clipShape(Circle())
                
                // Icon
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: size * 0.35, weight: .medium))
                    .foregroundColor(.white)
                    .offset(x: isPlaying ? 0 : 1) // Slight offset for play icon
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(isPlaying ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPlaying)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(isPlaying ? "Pause audio" : "Play audio")
        .accessibilityHint("Tap to \(isPlaying ? "pause" : "play") the audio content")
    }
}

// Preview
struct PrimaryGradientButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Button Components Preview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                Text("Primary Gradient Button")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                PrimaryGradientButton(title: "Sign In", action: {})
                PrimaryGradientButton(title: "Continue", action: {})
            }
            
            VStack(spacing: 16) {
                Text("Secondary Button Style")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button("Secondary Action") {}
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Text("Circle Icon Buttons")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    CircleIconButton(
                        systemName: "bell",
                        accessibilityLabel: "Notifications"
                    ) {}
                    
                    CircleIconButton(
                        systemName: "settings",
                        accessibilityLabel: "Settings"
                    ) {}
                    
                    CircleIconButton(
                        systemName: "heart",
                        accessibilityLabel: "Favorites"
                    ) {}
                }
            }
            
            VStack(spacing: 16) {
                Text("Circle Asset Buttons")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    CircleAssetButton(
                        assetName: "Aries",
                        accessibilityLabel: "Aries Sign"
                    ) {}
                    
                    CircleAssetButton(
                        assetName: "Taurus",
                        accessibilityLabel: "Taurus Sign"
                    ) {}
                    
                    CircleAssetButton(
                        assetName: "Gemini",
                        accessibilityLabel: "Gemini Sign"
                    ) {}
                }
            }
            

            
            VStack(spacing: 16) {
                Text("Audio Playback Buttons")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    AudioPlaybackButton(
                        isPlaying: false,
                        onToggle: {},
                        showLabel: true
                    )
                    
                    AudioPlaybackButton(
                        isPlaying: true,
                        onToggle: {},
                        showLabel: true
                    )
                    
                    AudioControlButton(
                        isPlaying: false,
                        onToggle: {}
                    )
                    
                    AudioControlButton(
                        isPlaying: true,
                        onToggle: {}
                    )
                }
            }
        }
        .padding(30)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(hex: "1a1a1a")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .previewLayout(.sizeThatFits)
    }
}

