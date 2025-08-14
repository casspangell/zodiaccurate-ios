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
    @State private var dashPhase: CGFloat = 0
    @State private var flicker: Bool = false
    @State private var sparkRotation: Double = 0
    @State private var embers: [Ember] = []

    init(size: CGFloat = 54, lineWidth: CGFloat = 3, rotationDuration: Double = 2.0) {
        self.size = size
        self.lineWidth = lineWidth
        self.rotationDuration = rotationDuration
    }

    var body: some View {
        ZStack {
            let innerRadius = size / 2

            // Outer glow halo
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [
                            Color(hex: "FF6A00").opacity(flicker ? 0.45 : 0.35),
                            Color(hex: "FF6A00").opacity(0.0)
                        ],
                        center: .center,
                        startRadius: innerRadius * 0.85,
                        endRadius: innerRadius * 1.35
                    ),
                    lineWidth: lineWidth
                )
                .blur(radius: 8)
                .scaleEffect(glowPulse ? 1.02 : 1.0)

            // Core fiery gradient ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "FFF6A3").opacity(0.95), location: 0.00),
                            .init(color: Color(hex: "FFB700").opacity(1.0), location: 0.12),
                            .init(color: Color(hex: "FF6A00").opacity(1.0), location: 0.28),
                            .init(color: Color(hex: "FF3D00").opacity(0.95), location: 0.42),
                            .init(color: Color(hex: "FF7300").opacity(1.0), location: 0.58),
                            .init(color: Color(hex: "FFC300").opacity(1.0), location: 0.74),
                            .init(color: Color(hex: "FFF6A3").opacity(0.95), location: 0.88),
                            .init(color: Color(hex: "FFB700").opacity(1.0), location: 1.00),
                        ]),
                        center: .center
                        
                    ),
                    lineWidth: lineWidth
                )
                .shadow(color: Color(hex: "FF8C00").opacity(0.5), radius: 4, x: 0, y: 0)
                .blur(radius: flicker ? 0.4 : 0.9)

            // Moving bright dashes (flame tongues)
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.0)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth * 0.7,
                        lineCap: .round,
                        dash: [9, 23, 5, 31],
                        dashPhase: dashPhase
                    )
                )
                .blur(radius: 1.6)
                .opacity(glowPulse ? 1.0 : 0.6)
                .blendMode(.screen)

            // Rotating spark beads on the orbit
            ZStack {
                ForEach(0..<12, id: \ .self) { i in
                    let angle = (Double(i) / 12.0) * 360.0 + sparkRotation
                    let radians = angle * .pi / 180
                    let radius = innerRadius
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white, Color(hex: "FFD580")],
                                center: .center,
                                startRadius: 0,
                                endRadius: 6
                            )
                        )
                        .frame(width: 6, height: 6)
                        .opacity(glowPulse ? 0.95 : 0.75)
                        .offset(x: CGFloat(cos(radians)) * radius, y: CGFloat(sin(radians)) * radius)
                        .shadow(color: Color(hex: "FFA500").opacity(0.8), radius: 3)
                }
            }
            .compositingGroup()
            .blendMode(.screen)

            // Embers emanating outward
            ZStack {
                ForEach(embers) { ember in
                    let radians = ember.angle * .pi / 180
                    let startR = innerRadius
                    let distance = startR + CGFloat(ember.progress) * innerRadius * 0.7
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "FFD580"), Color(hex: "FF6A00").opacity(0.0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 10
                            )
                        )
                        .frame(width: 10, height: 10)
                        .opacity(1.0 - ember.progress)
                        .offset(x: CGFloat(cos(radians)) * distance, y: CGFloat(sin(radians)) * distance)
                }
            }
            .blendMode(.screen)
            .compositingGroup()
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            glowPulse = true
            withAnimation(.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: rotationDuration * 0.85).repeatForever(autoreverses: false)) {
                sparkRotation = 360
            }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                flicker.toggle()
            }
            withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                dashPhase = -68
            }
            startEmberEmission()
        }
    }
}

// MARK: - Ember Model
private struct Ember: Identifiable {
    let id = UUID()
    let angle: Double
    var progress: Double
}

private extension FieryOrbitRing {
    func startEmberEmission() {
        // Emit small embers continuously
        let emissionInterval: TimeInterval = 0.18
        func spawn() {
            let angle = Double.random(in: 0..<360)
            var ember = Ember(angle: angle, progress: 0)
            embers.append(ember)
            withAnimation(.easeOut(duration: 0.8)) {
                // advance progress
                if let idx = embers.firstIndex(where: { $0.id == ember.id }) {
                    embers[idx].progress = 1.0
                }
            }
            // cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
                embers.removeAll { $0.id == ember.id }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + emissionInterval) {
                spawn()
            }
        }
        spawn()
    }
}

// MARK: - Hand Draw Animation
struct HandDrawAnimation: View {
    @State private var rotation: Double = 0
    let animationDuration: Double
    let repeatForever: Bool
    let description: String?
    
    init(animationDuration: Double = 1.0, repeatForever: Bool = true, description: String? = nil) {
        self.animationDuration = animationDuration
        self.repeatForever = repeatForever
        self.description = description
    }
    
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white)
//                .frame(width: 70, height: 70)
//                .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(Color.yellow)
                    .background(
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(Color.accentPurple)
                            .scaleEffect(1.5)
                            .blur(radius: 20)
                    )
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        startAnimation()
                    }
                
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    private func startAnimation() {
        let animation = repeatForever ?
            Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true) :
            Animation.easeInOut(duration: animationDuration)
        
        withAnimation(animation) {
            rotation = 60
        }
        
        if !repeatForever {
            // Reset after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    rotation = -60
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        rotation = 0
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        // Dark background to match your app theme
        VerticleAuroraBackgroundView()
        
//        VStack(spacing: 40) {

        HandDrawAnimation(description: "Tap to Dismiss")
//            }
            
//            // Without background circle
//            HandDrawAnimation(description: "Default animation")
//            
//            HandDrawAnimation(animationDuration: 2.5, description: "Slower animation")
//            
//            HandDrawAnimation(repeatForever: false, description: "Single play cycle")
//        }
    }
}

