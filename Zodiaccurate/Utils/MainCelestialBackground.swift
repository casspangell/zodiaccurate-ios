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
    @State private var currentTime: Date = Date()
    
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
                
                // Animated nebula clouds with time-based positioning
                ForEach(0..<5, id: \.self) { index in
                    NebulaCloud(
                        index: index, 
                        opacity: nebulaOpacity,
                        currentTime: currentTime,
                        screenSize: geometry.size
                    )
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
            startTimeUpdates()
        }
    }
    
    private func startTimeUpdates() {
        // Update time every minute to refresh nebula positions
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            currentTime = Date()
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
    let currentTime: Date
    let screenSize: CGSize
    
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
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        
        // Convert time to a normalized value (0-1) for the day
        let timeProgress = (Double(hour) + Double(minute) / 60.0) / 24.0
        
        // Different positioning patterns for different times of day
        let timeOfDay = getTimeOfDay(hour: hour)
        
        switch timeOfDay {
        case .dawn:
            // Dawn: bubbles cluster on the left side, rising
            let baseX = screenSize.width * 0.2
            let xOffset = CGFloat(index) * 40
            let timeOffset = sin(timeProgress * .pi) * 50
            return baseX + xOffset + timeOffset
            
        case .morning:
            // Morning: bubbles spread across the top
            let baseX = screenSize.width * 0.1
            let xSpread = screenSize.width * 0.8
            let xOffset = (CGFloat(index) / 4.0) * xSpread
            let timeOffset = cos(timeProgress * .pi * 2) * 30
            return baseX + xOffset + timeOffset
            
        case .afternoon:
            // Afternoon: bubbles move to the right side
            let baseX = screenSize.width * 0.6
            let xOffset = CGFloat(index) * 35
            let timeOffset = sin(timeProgress * .pi * 3) * 40
            return baseX + xOffset + timeOffset
            
        case .dusk:
            // Dusk: bubbles cluster in the center, preparing for night
            let centerX = screenSize.width * 0.5
            let xOffset = CGFloat(index - 2) * 60
            let timeOffset = cos(timeProgress * .pi) * 80
            return centerX + xOffset + timeOffset
            
        case .night:
            // Night: bubbles spread across the bottom, like stars
            let baseX = screenSize.width * 0.15
            let xSpread = screenSize.width * 0.7
            let xOffset = (CGFloat(index) / 4.0) * xSpread
            let timeOffset = sin(timeProgress * .pi * 4) * 25
            return baseX + xOffset + timeOffset
            
        case .lateNight:
            // Late night: bubbles cluster on the left, preparing for dawn
            let baseX = screenSize.width * 0.3
            let xOffset = CGFloat(index) * 45
            let timeOffset = cos(timeProgress * .pi * 2) * 35
            return baseX + xOffset + timeOffset
        }
    }
    
    private func calculateNebulaY(index: Int) -> CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        
        // Convert time to a normalized value (0-1) for the day
        let timeProgress = (Double(hour) + Double(minute) / 60.0) / 24.0
        
        let timeOfDay = getTimeOfDay(hour: hour)
        
        switch timeOfDay {
        case .dawn:
            // Dawn: bubbles rise from bottom to middle
            let baseY = screenSize.height * 0.8
            let yOffset = CGFloat(index) * 30
            let timeOffset = (1.0 - timeProgress) * screenSize.height * 0.4
            return baseY - yOffset - timeOffset
            
        case .morning:
            // Morning: bubbles stay in upper third
            let baseY = screenSize.height * 0.2
            let yOffset = CGFloat(index) * 25
            let timeOffset = sin(timeProgress * .pi * 2) * 20
            return baseY + yOffset + timeOffset
            
        case .afternoon:
            // Afternoon: bubbles move to middle-right
            let baseY = screenSize.height * 0.4
            let yOffset = CGFloat(index) * 35
            let timeOffset = cos(timeProgress * .pi * 3) * 30
            return baseY + yOffset + timeOffset
            
        case .dusk:
            // Dusk: bubbles cluster in center
            let centerY = screenSize.height * 0.5
            let yOffset = CGFloat(index - 2) * 40
            let timeOffset = sin(timeProgress * .pi) * 50
            return centerY + yOffset + timeOffset
            
        case .night:
            // Night: bubbles spread across bottom
            let baseY = screenSize.height * 0.7
            let yOffset = CGFloat(index) * 30
            let timeOffset = sin(timeProgress * .pi * 4) * 20
            return baseY + yOffset + timeOffset
            
        case .lateNight:
            // Late night: bubbles prepare to rise
            let baseY = screenSize.height * 0.6
            let yOffset = CGFloat(index) * 25
            let timeOffset = cos(timeProgress * .pi * 2) * 40
            return baseY + yOffset + timeOffset
        }
    }
    
    private func getTimeOfDay(hour: Int) -> TimeOfDay {
        switch hour {
        case 5..<8:
            return .dawn
        case 8..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17..<20:
            return .dusk
        case 20..<24:
            return .night
        default: // 0-5
            return .lateNight
        }
    }
    
    private enum TimeOfDay {
        case dawn, morning, afternoon, dusk, night, lateNight
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
