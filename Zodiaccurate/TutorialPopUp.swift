//
//  TutorialPopUp.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import SwiftUI

// MARK: - Arrow Position Enum
public enum ArrowPosition {
    case top, bottom, left, right
}

// MARK: - Flexible Tutorial PopUp
public struct TutorialPopUp: View {
    public var arrowPosition: ArrowPosition
    public var title: String = "🎤 Try voice input!"
    public var subtitle: String = "Tap the microphone button to use speech-to-text"
    public var icon: String = "mic.fill"
    public var bodyColor: Color = Color.deepBlue.opacity(0.95)
    public var arrowColor: Color = Color.accentGold
    public var glowColor: Color = Color.accentGold.opacity(0.2)
    public var pulse: Bool = false
    public var mainTextSize: CGFloat = 16
    public var subTextSize: CGFloat = 13
    public var showArrow: Bool = true
    public var body: some View {
        ZStack {
            if showArrow {
                switch arrowPosition {
                case .top:
                    VStack(spacing: 0) {
                        ArrowView(position: .top, color: arrowColor, pulse: pulse)
                        content
                    }
                case .bottom:
                    VStack(spacing: 0) {
                        content
                        ArrowView(position: .bottom, color: arrowColor, pulse: pulse)
                    }
                case .left:
                    HStack(spacing: 0) {
                        ArrowView(position: .left, color: arrowColor, pulse: pulse)
                        content
                    }
                case .right:
                    HStack(spacing: 0) {
                        content
                        ArrowView(position: .right, color: arrowColor, pulse: pulse)
                    }
                }
            } else {
                // No arrow, just show content
                content
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.accentGold)
                    .font(.system(size: mainTextSize))
                Text(title)
                    .font(.system(size: mainTextSize, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text(subtitle)
                .font(.system(size: subTextSize, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Glow effect
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(glowColor)
//                    .blur(radius: 8)
//                    .scaleEffect(1.1)
                // Main bubble
                RoundedRectangle(cornerRadius: 16)
                    .fill(bodyColor)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        )
    }
}

// MARK: - Arrow View
struct ArrowView: View {
    let position: ArrowPosition
    let color: Color
    var pulse: Bool = false
    @State private var scale: CGFloat = 1.0
    var body: some View {
        Group {
            switch position {
            case .top:
                TriangleUpward()
                    .fill(color)
                    .frame(width: 20, height: 14)
                    .scaleEffect(scale)
                    .animation(pulse ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: scale)
            case .bottom:
                Triangle()
                    .fill(color)
                    .frame(width: 20, height: 14)
                    .scaleEffect(scale)
                    .animation(pulse ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: scale)
            case .left:
                TriangleLeft()
                    .fill(color)
                    .frame(width: 14, height: 20)
                    .scaleEffect(scale)
                    .animation(pulse ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: scale)
            case .right:
                TriangleRight()
                    .fill(color)
                    .frame(width: 14, height: 20)
                    .scaleEffect(scale)
                    .animation(pulse ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: scale)
            }
        }
        .onAppear {
            if pulse {
                scale = 1.4
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 0.8
                }
            } else {
                scale = 1.0
            }
        }
        .onChange(of: pulse) { _, newValue in
            if newValue {
                scale = 1.4
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 0.8
                }
            } else {
                scale = 1.0
            }
        }
    }
}

// MARK: - Triangle Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
struct TriangleUpward: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
struct TriangleLeft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
struct TriangleRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Tutorial Manager (unchanged)
class TutorialManager: ObservableObject {
    @Published var showSpeechTutorial = false
    @Published var microphonePulse = false
    @Published var showVoiceTutorial = false
    
    func startSpeechTutorial() {
        showSpeechTutorial = true
        microphonePulse = true
        showVoiceTutorial = true
        // Remove auto-hide logic. Only dismiss when stopTutorial() is called.
    }
    
    func stopTutorial() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSpeechTutorial = false
            microphonePulse = false
            showVoiceTutorial = false
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TutorialPopUp(arrowPosition: .bottom)
        TutorialPopUp(arrowPosition: .top)
        TutorialPopUp(arrowPosition: .left)
        TutorialPopUp(arrowPosition: .right)
    }
    .padding()
    .background(Color.black)
} 
