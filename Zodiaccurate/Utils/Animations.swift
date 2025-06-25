import SwiftUI

// Shooting Stars Components
struct ShootingStarsLayer: View {
    @State private var shootingStars: [ShootingStarData] = []
    let maxStars = 7
    let animationDuration: Double = 1.2

    var body: some View {
        ZStack {
            ForEach(shootingStars) { star in
                ShootingStar(
                    start: star.start,
                    end: star.end,
                    angle: star.angle,
                    opacity: star.opacity,
                    duration: animationDuration
                )
            }
        }
        .onAppear {
            spawnStar()
        }
    }

    private func spawnStar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
            if shootingStars.count < maxStars {
                let width = UIScreen.main.bounds.width
                let height = UIScreen.main.bounds.height
                
                // Randomly choose which side to start from (top or left)
                let startFromTop = Bool.random()
                
                let startX: CGFloat
                let startY: CGFloat
                let angle: Double
                
                if startFromTop {
                    // Start from top, slightly off-screen
                    startX = CGFloat.random(in: -100...width + 100)
                    startY = -50
                    // Angle downward (between -60 and -30 degrees)
                    angle = Double.random(in: -60...(-30))
                } else {
                    // Start from left side, slightly off-screen
                    startX = -50
                    startY = CGFloat.random(in: -100...height + 100)
                    // Angle rightward (between -30 and 30 degrees)
                    angle = Double.random(in: -30...30)
                }
                
                // Length to ensure it crosses the screen
                let length = max(width, height) * 1.5
                let dx = cos(angle * .pi / 180) * length
                let dy = sin(angle * .pi / 180) * length
                let endX = startX + dx
                let endY = startY + dy
                
                let star = ShootingStarData(
                    id: UUID(),
                    start: CGPoint(x: startX, y: startY),
                    end: CGPoint(x: endX, y: endY),
                    angle: angle,
                    opacity: Double.random(in: 0.8...1.0)
                )
                shootingStars.append(star)
                
                // Remove after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    shootingStars.removeAll { $0.id == star.id }
                }
            }
            spawnStar()
        }
    }
}

struct ShootingStarData: Identifiable {
    let id: UUID
    let start: CGPoint
    let end: CGPoint
    let angle: Double
    let opacity: Double
}

struct ShootingStar: View {
    let start: CGPoint
    let end: CGPoint
    let angle: Double
    let opacity: Double
    let duration: Double
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            // Bright head
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .blur(radius: 0.5)
                .offset(x: lerp(start.x, end.x, progress) - UIScreen.main.bounds.width / 2,
                        y: lerp(start.y, end.y, progress) - UIScreen.main.bounds.height / 2)
            
            // Glowing tail
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.0), location: 0.0),
                            .init(color: Color.white.opacity(0.4), location: 0.7),
                            .init(color: Color.white.opacity(0.8), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 250, height: 1.5) // Increased length for more dramatic effect
                .rotationEffect(.degrees(angle))
                .offset(x: lerp(start.x, end.x, progress) - UIScreen.main.bounds.width / 2,
                        y: lerp(start.y, end.y, progress) - UIScreen.main.bounds.height / 2)
                .blur(radius: 0.5)
        }
        .onAppear {
            withAnimation(.easeOut(duration: duration)) {
                progress = 1.0
            }
        }
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
} 