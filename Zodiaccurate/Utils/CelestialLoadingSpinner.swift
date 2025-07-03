import SwiftUI

struct CelestialLoadingSpinner: View {
    enum Size {
        case small, medium, large
        
        var circleSize: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
        
        var orbitRadius: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 30
            case .large: return 40
            }
        }
        
        var scale: CGFloat {
            switch self {
            case .small: return 0.8
            case .medium: return 1.0
            case .large: return 1.2
            }
        }
    }
    
    let size: Size
    @State private var animationPhase: Double = 0
    
    init(size: Size = .medium) {
        self.size = size
    }
    
    private func startAnimationLoop() {
        // Initialize animation phase
        animationPhase = 0
    }
    
    var body: some View {
        ZStack {
            // Central glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.4),
                            Color.purple.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: size.orbitRadius * 0.8
                    )
                )
                .frame(width: size.orbitRadius * 1.6, height: size.orbitRadius * 1.6)
                .scaleEffect(1.0 + 0.2 * sin(animationPhase * 2))
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: false), value: animationPhase)
            
            // First orbiting circle (Cosmic Purple - fastest)
            CelestialOrb(
                size: size.circleSize,
                orbitRadius: size.orbitRadius,
                speed: 1.0,
                phase: animationPhase,
                color: Color.purple,
                scale: size.scale
            )
            
            // Second orbiting circle (Deep Blue - medium speed, reverse direction)
            CelestialOrb(
                size: size.circleSize * 0.8,
                orbitRadius: size.orbitRadius * 0.7,
                speed: -0.7,
                phase: animationPhase,
                color: Color.blue,
                scale: size.scale
            )
            
            // Third orbiting circle (Soft Pink - slowest)
            CelestialOrb(
                size: size.circleSize * 1.2,
                orbitRadius: size.orbitRadius * 1.3,
                speed: 0.5,
                phase: animationPhase,
                color: Color.pink,
                scale: size.scale
            )
        }
        .onAppear {
            // Start continuous animation loop
            startAnimationLoop()
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            // Update animation phase continuously
            animationPhase += 0.04 // Adjust speed here
        }
    }
}

struct CelestialOrb: View {
    let size: CGFloat
    let orbitRadius: CGFloat
    let speed: Double
    let phase: Double
    let color: Color
    let scale: CGFloat
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color,
                        color.opacity(0.7),
                        color.opacity(0.3)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size
                )
            )
            .frame(width: size * 2, height: size * 2)
            .shadow(color: color.opacity(0.6), radius: size * 0.5, x: 0, y: 0)
            .scaleEffect(scale * (1.0 + 0.1 * sin(phase * speed * 3)))
            .offset(
                x: orbitRadius * cos(phase * speed),
                y: orbitRadius * sin(phase * speed)
            )
            .opacity(0.8 + 0.2 * sin(phase * speed * 2))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        CelestialLoadingSpinner(size: .small)
        CelestialLoadingSpinner(size: .medium)
        CelestialLoadingSpinner(size: .large)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backgroundPrimary)
} 