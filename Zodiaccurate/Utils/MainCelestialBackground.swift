import SwiftUI

struct MainCelestialBackground: View {
    @State private var rotationAngle: Double = 0
    @State private var nebulaOpacity: Double = 0.3
    @State private var shootingStarOffset: CGSize = CGSize(width: -200, height: -100)
    @State private var shootingStarOpacity: Double = 0
    @State private var cosmicPulse: CGFloat = 1.0
    @State private var zodiacWheelRotation: Double = 0
    @State private var auroraShift: Double = 0
    @State private var cometTrail: [CGPoint] = []
    @State private var meteorShower: [Meteor] = []
    
    struct Meteor {
        var position: CGPoint
        var velocity: CGPoint
        var opacity: Double
        var size: CGFloat
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep space gradient
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "0A0A2E"), location: 0.0),
                        .init(color: Color(hex: "1A0B2E"), location: 0.3),
                        .init(color: Color(hex: "2D1B69"), location: 0.6),
                        .init(color: Color(hex: "0F051A"), location: 0.8),
                        .init(color: Color.black, location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 50,
                    endRadius: geometry.size.width * 0.8
                )
                .ignoresSafeArea()
                
                // Animated nebula clouds
                ForEach(0..<5, id: \.self) { index in
                    NebulaCloud(index: index, opacity: nebulaOpacity)
                }
                
                // Zodiac constellation wheel
                ZodiacConstellationWheel(rotation: zodiacWheelRotation)
                    .scaleEffect(0.8)
                    .opacity(0.6)
                
                // Shooting stars
                ShootingStarView(
                    offset: shootingStarOffset,
                    opacity: shootingStarOpacity
                )
                
                // Meteor shower
                ForEach(meteorShower.indices, id: \.self) { index in
                    MeteorView(meteor: meteorShower[index])
                }
                
                // Cosmic aurora waves
                AuroraWaves(shift: auroraShift)
                
                // Comet trail
                CometTrailView(points: cometTrail)
                
                // Starfield (same as CelestialSystemBackground)
                StarfieldView()
            }
        }
        .onAppear {
            startAnimations()
            startMeteorShower()
        }
    }
    
    private func startAnimations() {
        // Main rotation - much slower
        withAnimation(.linear(duration: 300).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Nebula pulse - gentler
        withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            nebulaOpacity = 0.7
        }
        
        // Zodiac wheel rotation - very slow
        withAnimation(.linear(duration: 480).repeatForever(autoreverses: false)) {
            zodiacWheelRotation = 360
        }
        
        // Aurora shift - slower
        withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
            auroraShift = 2 * .pi
        }
        
        // Shooting star animation - less frequent
        startShootingStarAnimation()
    }
    
    private func startShootingStarAnimation() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in // Much less frequent
            withAnimation(.easeIn(duration: 1.0)) { // Slower animation
                shootingStarOpacity = 1.0
                shootingStarOffset = CGSize(width: 400, height: 200)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    shootingStarOpacity = 0
                }
                shootingStarOffset = CGSize(width: -200, height: -100)
            }
        }
    }
    
    private func startMeteorShower() {
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in // Much less frequent
            let newMeteor = Meteor(
                position: CGPoint(x: CGFloat.random(in: 0...400), y: -20),
                velocity: CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: 2...4)), // Slower velocity
                opacity: 1.0,
                size: CGFloat.random(in: 2...6)
            )
            meteorShower.append(newMeteor)
            
            // Remove old meteors
            if meteorShower.count > 10 {
                meteorShower.removeFirst()
            }
        }
    }
}

// MARK: - Supporting Views

struct NebulaCloud: View {
    let index: Int
    let opacity: Double
    
    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        nebulaColors[index % nebulaColors.count].opacity(0.8),
                        nebulaColors[index % nebulaColors.count].opacity(0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 150)
            .position(
                x: calculateNebulaX(index: index),
                y: calculateNebulaY(index: index)
            )
            .opacity(opacity)
            .blur(radius: 15)
    }
    
    private func calculateNebulaX(index: Int) -> CGFloat {
        let baseX: CGFloat = 100
        let increment: CGFloat = 80
        return baseX + CGFloat(index) * increment
    }
    
    private func calculateNebulaY(index: Int) -> CGFloat {
        let baseY: CGFloat = 150
        let increment: CGFloat = 60
        return baseY + CGFloat(index) * increment
    }
    
    private let nebulaColors: [Color] = [
        .purple, .blue, .pink, .cyan, .orange
    ]
}

struct ZodiacConstellationWheel: View {
    let rotation: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                // Zodiac symbols only - no rings
                Text("★")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 12))
                    .position(
                        x: calculateZodiacX(index: index),
                        y: calculateZodiacY(index: index)
                    )
            }
        }
        .rotationEffect(.degrees(rotation))
    }
    
    private func calculateZodiacX(index: Int) -> CGFloat {
        let radius = calculateZodiacRadius(index: index)
        let angle = Double(index) * .pi / 6
        return radius * cos(angle)
    }
    
    private func calculateZodiacY(index: Int) -> CGFloat {
        let radius = calculateZodiacRadius(index: index)
        let angle = Double(index) * .pi / 6
        return radius * sin(angle)
    }
    
    private func calculateZodiacRadius(index: Int) -> CGFloat {
        let baseRadius: CGFloat = 100
        let increment: CGFloat = 20
        return baseRadius + CGFloat(index) * increment
    }
}

struct ShootingStarView: View {
    let offset: CGSize
    let opacity: Double
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 50, y: 10))
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [.white, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 2
        )
        .offset(offset)
        .opacity(opacity)
    }
}

struct MeteorView: View {
    let meteor: MainCelestialBackground.Meteor
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: meteor.size, height: meteor.size)
            .position(meteor.position)
            .opacity(meteor.opacity)
            .shadow(color: .white, radius: 3)
    }
}

struct AuroraWaves: View {
    let shift: Double
    
    var body: some View {
        ForEach(0..<3, id: \.self) { index in
            Path { path in
                let width: CGFloat = 400
                let height: CGFloat = 200
                let centerY = height / 2
                path.move(to: CGPoint(x: 0, y: centerY))
                
                for x in stride(from: 0, through: width, by: 5) {
                    let normalizedX = x / width
                    let wavePhase = calculateWavePhase(normalizedX: normalizedX, shift: shift, index: index)
                    let waveAmplitude: CGFloat = 30
                    let y = centerY + sin(wavePhase) * waveAmplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.6),
                        Color.blue.opacity(0.4),
                        Color.purple.opacity(0.6)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            .position(x: 200, y: calculateAuroraY(index: index))
            .opacity(0.7)
        }
    }
    
    private func calculateWavePhase(normalizedX: CGFloat, shift: Double, index: Int) -> Double {
        let basePhase = normalizedX * 2 * .pi
        let shiftComponent = shift
        let indexComponent = Double(index) * .pi / 3
        return basePhase + shiftComponent + indexComponent
    }
    
    private func calculateAuroraY(index: Int) -> CGFloat {
        let baseY: CGFloat = 100
        let increment: CGFloat = 50
        return baseY + CGFloat(index) * increment
    }
}

struct CometTrailView: View {
    let points: [CGPoint]
    
    var body: some View {
        Path { path in
            guard points.count > 1 else { return }
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .stroke(
            LinearGradient(
                gradient: Gradient(colors: [.white, .cyan, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            ),
            lineWidth: 2
        )
    }
}

#Preview {
    MainCelestialBackground()
        .frame(width: 400, height: 400)
} 
