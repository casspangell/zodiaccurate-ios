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
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) { celestialBody1Angle = 360 }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) { celestialBody2Angle = -360 }
            withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) { celestialBody3Angle = 360 }
            withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) { celestialBody4Angle = -360 }
            withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) { celestialBody5Angle = 360 }
            withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) { celestialBody6Angle = -360 }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) { stardust1Angle = 360 }
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) { stardust2Angle = -360 }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(1.0)) { magneticPulse = 1.3 }
        }
    }
} 