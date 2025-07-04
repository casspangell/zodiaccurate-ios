import SwiftUI

struct StardustEarningAnimation: View {
    let amount: Int
    let type: StardustTransactionType
    @Binding var isShowing: Bool
    
    // Animation states
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur
            VisualEffectBlur(blurStyle: UIBlurEffect.Style.systemUltraThinMaterialDark)
                .ignoresSafeArea()
                .opacity(opacity)
            
            // Main animation container
            VStack(spacing: 20) {
                // Stardust icon with sparkles
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.accentGold.opacity(0.6),
                                    Color.accentGold.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(scale)
                        .opacity(glowIntensity)
                    
                    // Main stardust icon
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.accentGold,
                                        Color.accentPurple,
                                        Color.accentGold
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(rotation))
                        
                        // Inner stardust symbol
                        Image(systemName: "sparkles")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.accentGold)
                            .scaleEffect(scale)
                    }
                    .scaleEffect(scale)
                    
                    // Sparkles around the icon
                    ForEach(0..<8) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 16))
                            .foregroundColor([Color.yellow, Color.cyan, Color.pink].randomElement()!)
                            .offset(
                                x: 80 * cos(Double(index) * .pi / 4),
                                y: 80 * sin(Double(index) * .pi / 4)
                            )
                            .opacity(sparkleOpacity)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .delay(Double(index) * 0.1),
                                value: sparkleOpacity
                            )
                    }
                }
                
                // Amount text
                VStack(spacing: 8) {
                    Text("+\(amount)")
                        .font(.dmSansSemibold(size: 48))
                        .foregroundColor(.accentGold)
                        .scaleEffect(textScale)
                    
                    Text("Stardust")
                        .font(.dmSansMedium(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                        .scaleEffect(textScale)
                    
                    Text(type.displayName)
                        .font(.dmSansMedium(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .scaleEffect(textScale)
                }
                
                // Celebration particles
                ForEach(0..<12) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentGold,
                                    Color.accentPurple,
                                    Color.yellow
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 8, height: 8)
                        .offset(
                            x: 120 * cos(Double(index) * .pi / 6),
                            y: 120 * sin(Double(index) * .pi / 6)
                        )
                        .opacity(sparkleOpacity)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .delay(Double(index) * 0.05),
                            value: sparkleOpacity
                        )
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Initial state
        scale = 0.1
        opacity = 0
        rotation = 0
        sparkleOpacity = 0
        textScale = 0.5
        glowIntensity = 0
        
        // Animate in
        withAnimation(.easeOut(duration: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Rotate and add glow
        withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
            rotation = 360
            glowIntensity = 1.0
        }
        
        // Show sparkles
        withAnimation(.easeInOut(duration: 0.5).delay(0.4)) {
            sparkleOpacity = 1.0
        }
        
        // Animate text
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6)) {
            textScale = 1.0
        }
        
        // Hold for a moment, then animate out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.4)) {
                scale = 1.2
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isShowing = false
            }
        }
    }
}

// Preview
#Preview {
    StardustEarningAnimation(
        amount: 50,
        type: .achievement,
        isShowing: .constant(true)
    )
} 