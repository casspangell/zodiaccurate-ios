import SwiftUI

struct ZodiacLoadingSpinner: View {
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
            // Central pulsating bubble with ripples
            ZStack {
                // Multiple ripple layers
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.4),
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.purple.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: size.orbitRadius * (0.8 + Double(index) * 0.3), 
                               height: size.orbitRadius * (0.8 + Double(index) * 0.3))
                        .scaleEffect(1.0 + 0.3 * sin(animationPhase * 1.5 + Double(index) * 0.5))
                        .opacity(0.1 - Double(index) * 0.15)
//                        .blur(radius: 8)
                }
                
                // Central glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.purple.opacity(0.4),
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: size.orbitRadius * 0.6
                        )
                    )
                    .frame(width: size.orbitRadius * 1.2, height: size.orbitRadius * 1.2)
                    .scaleEffect(1.0 + 0.4 * sin(animationPhase * 2))
//                    .blur(radius: 10)
                
                // Inner core
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: size.orbitRadius * 0.6, height: size.orbitRadius * 0.6)
                    .scaleEffect(1.0 + 0.2 * sin(animationPhase * 3))
//                    .blur(radius: 6)
            }
            
            // First orbiting ring (largest - fastest)
            CelestialRing(
                size: size.circleSize,
                orbitRadius: size.orbitRadius,
                speed: 1.0,
                phase: animationPhase,
                scale: size.scale
            )
            
            // Second orbiting ring (medium - reverse direction)
            CelestialRing(
                size: size.circleSize * 0.8,
                orbitRadius: size.orbitRadius * 0.7,
                speed: -0.7,
                phase: animationPhase,
                scale: size.scale
            )
            
            // Third orbiting ring (largest - slowest)
            CelestialRing(
                size: size.circleSize * 1.2,
                orbitRadius: size.orbitRadius * 1.3,
                speed: 0.5,
                phase: animationPhase,
                scale: size.scale
            )
            
            // Small white stars
            CelestialStar(
                size: size.circleSize * 0.3,
                orbitRadius: size.orbitRadius * 0.4,
                speed: 1.5,
                phase: animationPhase,
                scale: size.scale
            )
            
            CelestialStar(
                size: size.circleSize * 0.2,
                orbitRadius: size.orbitRadius * 1.1,
                speed: -1.2,
                phase: animationPhase,
                scale: size.scale
            )
            
            CelestialStar(
                size: size.circleSize * 0.25,
                orbitRadius: size.orbitRadius * 0.6,
                speed: 0.8,
                phase: animationPhase,
                scale: size.scale
            )
        }
        .onAppear {
            // Start continuous animation loop
            startAnimationLoop()
        }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            // Update animation phase continuously
            animationPhase += 0.03 // Adjust speed here
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
    }
}

struct CelestialRing: View {
    let size: CGFloat
    let orbitRadius: CGFloat
    let speed: Double
    let phase: Double
    let scale: CGFloat
    
    var body: some View {
        Circle()
            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
            .frame(width: size * 2, height: size * 2)
            .shadow(color: Color.white.opacity(0.2), radius: size * 0.3, x: 0, y: 0)
            .scaleEffect(scale * (1.0 + 0.25 * sin(phase * speed * 2)))
            .offset(
                x: orbitRadius * cos(phase * speed),
                y: orbitRadius * sin(phase * speed)
            )
            .opacity(0.3 + 0.2 * sin(phase * speed * 1.5))
    }
}

struct CelestialStar: View {
    let size: CGFloat
    let orbitRadius: CGFloat
    let speed: Double
    let phase: Double
    let scale: CGFloat
    
    var body: some View {
        ZStack {
            // Star shape using multiple rotated rectangles
            ForEach(0..<4, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: size * 0.3, height: size)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Central dot
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.4, height: size * 0.4)
        }
        .frame(width: size * 2, height: size * 2)
        .shadow(color: Color.white.opacity(0.3), radius: size * 0.4, x: 0, y: 0)
        .scaleEffect(scale * (1.0 + 0.2 * sin(phase * speed * 2.5)))
        .offset(
            x: orbitRadius * cos(phase * speed),
            y: orbitRadius * sin(phase * speed)
        )
        .opacity(0.4 + 0.2 * sin(phase * speed * 1.8))
        .rotationEffect(.degrees(phase * speed * 30))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ZodiacLoadingSpinner(size: .small)
        ZodiacLoadingSpinner(size: .medium)
        ZodiacLoadingSpinner(size: .large)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backgroundPrimary)
} 
