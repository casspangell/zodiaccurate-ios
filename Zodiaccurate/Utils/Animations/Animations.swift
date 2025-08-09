import SwiftUI

// MARK: - Glistening Background Component
struct GlisteningBackground: View {
    @State private var shimmerOffset: CGFloat
    @State private var sparkleOpacity: Double = 0.0
    @State private var isAnimating: Bool = false
    
    // Optional parameters with default values
    let shimmerStartOffset: CGFloat
    let shimmerEndOffset: CGFloat
    let shimmerDuration: Double
    let shimmerWidth: CGFloat
    let shimmerHeight: CGFloat
    let repeatForever: Bool
    let autoStart: Bool
    let triggerAnimation: Binding<Bool>?
    
    init(
        shimmerStartOffset: CGFloat = -1000,
        shimmerEndOffset: CGFloat = 600,
        shimmerDuration: Double = 2.5,
        shimmerWidth: CGFloat = 150,
        shimmerHeight: CGFloat = 500,
        repeatForever: Bool = true,
        autoStart: Bool = true,
        triggerAnimation: Binding<Bool>? = nil
    ) {
        self.shimmerStartOffset = shimmerStartOffset
        self.shimmerEndOffset = shimmerEndOffset
        self.shimmerDuration = shimmerDuration
        self.shimmerWidth = shimmerWidth
        self.shimmerHeight = shimmerHeight
        self.repeatForever = repeatForever
        self.autoStart = autoStart
        self.triggerAnimation = triggerAnimation
        self._shimmerOffset = State(initialValue: shimmerStartOffset)
    }
    
    var body: some View {
        ZStack {
            // Base background
            Color.black
            
            // Angled shimmer effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: shimmerWidth, height: shimmerHeight)
                .rotationEffect(.degrees(45))
                .offset(x: shimmerOffset, y: shimmerOffset)
//                .blur(radius: 0)
            
            // Sparkle effects
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 5, height: 2)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -100...100)
                    )
                    .opacity(sparkleOpacity)
                    .animation(
                        .easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: sparkleOpacity
                    )
            }
        }
        .onAppear {
            if autoStart {
                fireGlisteningBackground()
            }
        }
        .onChange(of: isAnimating) { _ in
            if isAnimating && autoStart {
                // Only start auto animation if autoStart is true
                let animation = repeatForever ? 
                    Animation.linear(duration: shimmerDuration).repeatForever(autoreverses: false) :
                    Animation.linear(duration: shimmerDuration)
                
                withAnimation(animation) {
                    shimmerOffset = shimmerEndOffset
                }
            }
        }
        .onChange(of: triggerAnimation?.wrappedValue ?? false) { shouldTrigger in
            if shouldTrigger {
                fireGlisteningBackground()
                triggerAnimation?.wrappedValue = false
            }
        }
    }
    
    // MARK: - Public Functions
    func fireGlisteningBackground() {
        isAnimating = true
        sparkleOpacity = 1.0
        startShimmerAnimation()
    }
    
    // MARK: - Private Functions
    private func startShimmerAnimation() {
        // When fired manually, always use non-repeating animation
        let animation = Animation.linear(duration: shimmerDuration)
        
        withAnimation(animation) {
            shimmerOffset = shimmerEndOffset
        }
        
        // Reset shimmer position after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + shimmerDuration) {
            shimmerOffset = shimmerStartOffset
        }
    }
}

// MARK: - Shooting Stars Components

// MARK: - Shooting Stars Components
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

 
// MARK: - Fiery Orbit Ring
struct FieryOrbitRing: View {
    let size: CGFloat
    let lineWidth: CGFloat
    let rotationDuration: Double

    @State private var rotation: Double = 0
    @State private var glowPulse: Bool = false

    init(size: CGFloat = 54, lineWidth: CGFloat = 3, rotationDuration: Double = 2.0) {
        self.size = size
        self.lineWidth = lineWidth
        self.rotationDuration = rotationDuration
    }

    var body: some View {
        ZStack {
            // Core fiery gradient ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "FFDD55").opacity(0.9), location: 0.00),
                            .init(color: Color(hex: "FF9900").opacity(0.95), location: 0.15),
                            .init(color: Color(hex: "FF4D00").opacity(1.0), location: 0.30),
                            .init(color: Color(hex: "FF2E00").opacity(0.95), location: 0.45),
                            .init(color: Color(hex: "FF7A00").opacity(1.0), location: 0.60),
                            .init(color: Color(hex: "FFD000").opacity(0.95), location: 0.75),
                            .init(color: Color(hex: "FFDD55").opacity(0.9), location: 0.90),
                            .init(color: Color(hex: "FF9900").opacity(0.95), location: 1.00),
                        ]),
                        center: .center
                    ),
                    lineWidth: lineWidth
                )
                .blur(radius: 0.3)

            // Highlighted streaks for a lively flame effect
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.0),
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth * 0.6, lineCap: .round, dash: [8, 28], dashPhase: 0)
                )
                .blur(radius: 1.2)
                .opacity(glowPulse ? 0.9 : 0.5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: glowPulse)

            // Soft outer glow
            Circle()
                .stroke(Color(hex: "FF6A00").opacity(0.45), lineWidth: lineWidth)
                .blur(radius: 4)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            glowPulse = true
            withAnimation(.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

