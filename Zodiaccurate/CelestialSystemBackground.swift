import SwiftUI

struct CelestialSystemBackground: View {
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
            magneticPulse: magneticPulse
        )
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
            // More pronounced and staggered pulsing
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(0.2)) { magneticPulse = 1.25 }
            withAnimation(.easeInOut(duration: 4.7).repeatForever(autoreverses: true).delay(0.7)) { magneticPulse2 = 1.18 }
            withAnimation(.easeInOut(duration: 5.2).repeatForever(autoreverses: true).delay(1.1)) { magneticPulse3 = 1.12 }
            // Animate orbit radii for some bodies
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) { orbitRadius1 = 200 }
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true).delay(1.5)) { orbitRadius3 = 320 }
            withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true).delay(2.2)) { orbitRadius5 = 440 }
            // Animate color shift for a cosmic effect
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { colorShift = 1 }
        }
    }
}

// Environment keys for orbit radii and color shift
private struct CelestialOrbitsKey: EnvironmentKey { static let defaultValue: [CGFloat] = [180,240,300,360,420,480] }
extension EnvironmentValues { var _celestialOrbits: [CGFloat] { get { self[CelestialOrbitsKey.self] } set { self[CelestialOrbitsKey.self] = newValue } } }
private struct CelestialColorShiftKey: EnvironmentKey { static let defaultValue: Double = 0 }
extension EnvironmentValues { var _celestialColorShift: Double { get { self[CelestialColorShiftKey.self] } set { self[CelestialColorShiftKey.self] = newValue } } } 