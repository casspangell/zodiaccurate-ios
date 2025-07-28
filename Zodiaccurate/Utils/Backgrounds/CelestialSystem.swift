import SwiftUI

struct CelestialSystem: View {
    @State private var celestialBody1Angle: Double = 0
    @State private var celestialBody2Angle: Double = 0
    @State private var celestialBody3Angle: Double = 0
    @State private var celestialBody4Angle: Double = 0
    @State private var celestialBody5Angle: Double = 0
    @State private var celestialBody6Angle: Double = 0
    @State private var stardust1Angle: Double = 0
    @State private var stardust2Angle: Double = 0
    @State private var magneticPulse: CGFloat = 1.0
    @State private var magneticPulse2: CGFloat = 1.0
    @State private var magneticPulse3: CGFloat = 1.0
    @State private var orbitRadius1: CGFloat = 180
    @State private var orbitRadius2: CGFloat = 240
    @State private var orbitRadius3: CGFloat = 300
    @State private var orbitRadius4: CGFloat = 360
    @State private var orbitRadius5: CGFloat = 420
    @State private var orbitRadius6: CGFloat = 480
    @State private var colorShift: Double = 0
    @State private var cosmosOffset: CGSize = .zero

    var body: some View {
        ZStack {
            StarfieldView()
            // Undulating magnetic spheres (replicated from SplashScreenView, now with more colors)
            let colorSets: [[Color]] = [
                [.accentGold, .accentPurple, .accentBlue, .clear],
                [.deepBlue, .royalBlue, .electricBlue, .clear],
                [.magenta, .deepPink, .accentGold, .clear],
                [.accentPurple, .accentGold, .deepBlue, .clear],
                [.royalBlue, .magenta, .accentGold, .clear],
                [.deepPink, .accentBlue, .accentGold, .clear],
                [.accentGold, .deepBlue, .magenta, .clear],
                [.accentPurple, .royalBlue, .deepPink, .clear]
            ]
            ForEach(0..<8, id: \.self) { index in
                let base = CGFloat(index)
                let scale = magneticPulse
                let colors = colorSets[index % colorSets.count]
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 18
                    )
                    .frame(width: 220 + base * 40, height: 220 + base * 40)
                    .opacity(0.5 - Double(index) * 0.05)
                    .scaleEffect(scale)
                    .blur(radius: 12)
                    .animation(
                        Animation.easeInOut(duration: 3.0 + Double(index) * 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: magneticPulse
                    )
            }
            CelestialSystemView(
                body1Angle: celestialBody1Angle,
                body2Angle: celestialBody2Angle,
                body3Angle: celestialBody3Angle,
                body4Angle: celestialBody4Angle,
                body5Angle: celestialBody5Angle,
                body6Angle: celestialBody6Angle,
                stardust1Angle: stardust1Angle,
                stardust2Angle: stardust2Angle,
                cosmosOffset: cosmosOffset,
                magneticPulse: magneticPulse,
                animationCenterY: 0.3
            )
        }
        .environment(\._celestialOrbits, [orbitRadius1, orbitRadius2, orbitRadius3, orbitRadius4, orbitRadius5, orbitRadius6])
        .environment(\._celestialColorShift, colorShift)
        .onAppear {
            // Varying orbit speeds and directions
            withAnimation(.linear(duration: 13).repeatForever(autoreverses: false)) { celestialBody1Angle = 360 }
            withAnimation(.linear(duration: 21).repeatForever(autoreverses: false)) { celestialBody2Angle = -360 }
            withAnimation(.linear(duration: 29).repeatForever(autoreverses: false)) { celestialBody3Angle = 360 }
            withAnimation(.linear(duration: 37).repeatForever(autoreverses: false)) { celestialBody4Angle = -360 }
            withAnimation(.linear(duration: 51).repeatForever(autoreverses: false)) { celestialBody5Angle = 360 }
            withAnimation(.linear(duration: 61).repeatForever(autoreverses: false)) { celestialBody6Angle = -360 }
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) { stardust1Angle = 360 }
            withAnimation(.linear(duration: 11).repeatForever(autoreverses: false)) { stardust2Angle = -360 }
            // Magnetic pulse animation (replicated from SplashScreenView)
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(1.0)) { magneticPulse = 1.3 }
            // Animate orbit radii for some bodies
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) { orbitRadius1 = 200 }
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true).delay(1.5)) { orbitRadius3 = 320 }
            withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true).delay(2.2)) { orbitRadius5 = 440 }
            // Animate color shift for a cosmic effect
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { colorShift = 2 }
        }
    }
}

// Environment keys for orbit radii and color shift
private struct CelestialOrbitsKey: EnvironmentKey { static let defaultValue: [CGFloat] = [260,340,420,500,580,660] }
extension EnvironmentValues { var _celestialOrbits: [CGFloat] { get { self[CelestialOrbitsKey.self] } set { self[CelestialOrbitsKey.self] = newValue } } }
private struct CelestialColorShiftKey: EnvironmentKey { static let defaultValue: Double = 0 }
extension EnvironmentValues { var _celestialColorShift: Double { get { self[CelestialColorShiftKey.self] } set { self[CelestialColorShiftKey.self] = newValue } } } 

// Celestial Bodies System
struct CelestialSystemView: View {
    let body1Angle: Double
    let body2Angle: Double
    let body3Angle: Double
    let body4Angle: Double
    let body5Angle: Double
    let body6Angle: Double
    let stardust1Angle: Double
    let stardust2Angle: Double
    let cosmosOffset: CGSize
    let magneticPulse: CGFloat
    let animationCenterY: CGFloat
    
    var body: some View {
        ZStack {
            // First group of celestial bodies
            CelestialGroup1(
                body1Angle: body1Angle,
                body2Angle: body2Angle,
                body3Angle: body3Angle,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
            
            // Second group of celestial bodies
            CelestialGroup2(
                body4Angle: body4Angle,
                body5Angle: body5Angle,
                body6Angle: body6Angle,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
        }
    }
}

// First group of celestial bodies
struct CelestialGroup1: View {
    let body1Angle: Double
    let body2Angle: Double
    let body3Angle: Double
    let cosmosOffset: CGSize
    let animationCenterY: CGFloat
    @Environment(\._celestialOrbits) private var orbits: [CGFloat]

    var body: some View {
        Group {
            // Large Purple Nebula
            CelestialBody(
                color: Color(hex: "8A2BE2"),
                size: 120,
                orbitRadius: orbits.indices.contains(0) ? orbits[0] : 180,
                angle: body1Angle,
                blur: 120,
                opacity: 0.6,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
            
            // Golden Comet
            CelestialBody(
                color: Color(hex: "D4AF37"),
                size: 80,
                orbitRadius: orbits.indices.contains(1) ? orbits[1] : 240,
                angle: body2Angle,
                blur: 80,
                opacity: 0.8,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
            
            // Magenta Star Cluster
            CelestialBody(
                color: Color(hex: "FF1493"),
                size: 100,
                orbitRadius: orbits.indices.contains(2) ? orbits[2] : 300,
                angle: body3Angle,
                blur: 100,
                opacity: 0.7,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
        }
    }
}

// Second group of celestial bodies
struct CelestialGroup2: View {
    let body4Angle: Double
    let body5Angle: Double
    let body6Angle: Double
    let cosmosOffset: CGSize
    let animationCenterY: CGFloat
    @Environment(\._celestialOrbits) private var orbits: [CGFloat]

    var body: some View {
        Group {
            // Deep Purple Gas Giant
            CelestialBody(
                color: Color(hex: "4B0082"),
                size: 140,
                orbitRadius: orbits.indices.contains(3) ? orbits[3] : 360,
                angle: body4Angle,
                blur: 140,
                opacity: 0.5,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
            
            // Rose Gold Asteroid Belt
            CelestialBody(
                color: Color(hex: "E6B8A2"),
                size: 60,
                orbitRadius: orbits.indices.contains(4) ? orbits[4] : 420,
                angle: body5Angle,
                blur: 60,
                opacity: 0.9,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
            
            // Violet Spiral Galaxy
            CelestialBody(
                color: Color(hex: "9370DB"),
                size: 110,
                orbitRadius: orbits.indices.contains(5) ? orbits[5] : 480,
                angle: body6Angle,
                blur: 110,
                opacity: 0.6,
                cosmosOffset: cosmosOffset,
                animationCenterY: animationCenterY
            )
        }
    }
}

// Individual Celestial Body
struct CelestialBody: View {
    let color: Color
    let size: CGFloat
    let orbitRadius: CGFloat
    let angle: Double
    let blur: CGFloat
    let opacity: Double
    let cosmosOffset: CGSize
    let animationCenterY: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: color.opacity(opacity), location: 0.0),
                            .init(color: color.opacity(opacity * 0.7), location: 0.4),
                            .init(color: color.opacity(opacity * 0.3), location: 0.8),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size * 3, height: size * 3)
                .blur(radius: blur)
                .position(
                    x: geometry.size.width / 2 + cos(angle * .pi / 180) * orbitRadius + cosmosOffset.width * 0.3,
                    y: geometry.size.height * animationCenterY + sin(angle * .pi / 180) * orbitRadius + cosmosOffset.height * 0.3
                )
        }
    }
} 
