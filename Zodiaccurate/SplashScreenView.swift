import SwiftUI
import CoreMotion

struct SplashScreenView: View {
    @State private var isActive = true
    @State private var opacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoRotation: Double = 0
    @State private var titleOffset: CGFloat = -50
    @State private var taglineOffset: CGFloat = 50
    @State private var tapHintOpacity: Double = 0.0
    @State private var magneticPulse: CGFloat = 1.0
    
    // Celestial body orbital states
    @State private var celestialBody1Angle: Double = 0
    @State private var celestialBody2Angle: Double = 0
    @State private var celestialBody3Angle: Double = 0
    @State private var celestialBody4Angle: Double = 0
    @State private var celestialBody5Angle: Double = 0
    @State private var celestialBody6Angle: Double = 0
    @State private var stardust1Angle: Double = 0
    @State private var stardust2Angle: Double = 0
    
    // Parallax motion variables
    @State private var motionManager = CMMotionManager()
    @State private var cosmosOffset: CGSize = .zero

    var body: some View {
        if isActive {
            ZStack {
                // Deep space background
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "1A0B2E"), location: 0.0), // Deep purple center
                        .init(color: Color(hex: "0F051A"), location: 0.7), // Darker purple
                        .init(color: Color.black, location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()

                // Distant starfield
                ForEach(0..<50, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...400),
                            y: CGFloat.random(in: 0...800)
                        )
                        .opacity(Double.random(in: 0.4...1.0))
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...8))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...5)),
                            value: opacity
                        )
                }

                // Celestial Bodies Orbiting System
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

                VStack(spacing: 0) {
                    Spacer()
                    
                    // Title with cosmic glow
                    Text("Zodiaccurate")
                        .dmSansSemibold56Tracking()
                        .foregroundColor(Color.white)
                        .shadow(color: Color(hex: "D4AF37").opacity(0.8), radius: 15, x: 0, y: 0)
                        .shadow(color: Color(hex: "8A2BE2").opacity(0.6), radius: 25, x: 0, y: 0)
                        .padding(.top, 40)
                        .offset(y: titleOffset)
                        .opacity(opacity)

                    Spacer()
                        .frame(height: 60)

                    // Central Magnetic Logo (Center of Universe)
                    ZStack {
                        // Magnetic field visualization
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "D4AF37").opacity(0.3),
                                            Color(hex: "8A2BE2").opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(
                                    width: 220 + CGFloat(index * 40),
                                    height: 220 + CGFloat(index * 40)
                                )
                                .opacity(0.4 - Double(index) * 0.05)
                                .scaleEffect(magneticPulse)
                                .animation(
                                    Animation.easeInOut(duration: 3.0 + Double(index) * 0.5)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: magneticPulse
                                )
                        }
                        
                        // Central gravitational glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "D4AF37").opacity(0.8), location: 0.0),
                                        .init(color: Color(hex: "8A2BE2").opacity(0.6), location: 0.4),
                                        .init(color: Color(hex: "FF1493").opacity(0.4), location: 0.7),
                                        .init(color: Color.clear, location: 1.0)
                                    ]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 200
                                )
                            )
                            .frame(width: 400, height: 400)
                            .blur(radius: 30)
                            .scaleEffect(magneticPulse)
                            .opacity(0.8)

                        // Main logo circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "D4AF37"), location: 0.0), // Gold
                                        .init(color: Color(hex: "8A2BE2"), location: 1.0)  // Deep purple
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .overlay(
                                // Zodiac constellation patterns
                                ZStack {
                                    ForEach(0..<12, id: \.self) { index in
                                        Circle()
                                            .fill(Color.white.opacity(0.9))
                                            .frame(width: 3, height: 3)
                                            .position(
                                                x: 100 + 70 * cos(Double(index) * .pi / 6),
                                                y: 100 + 70 * sin(Double(index) * .pi / 6)
                                            )
                                            .shadow(color: Color(hex: "D4AF37"), radius: 2)
                                    }
                                    
                                    // Connecting constellation lines
                                    Path { path in
                                        for i in 0..<12 {
                                            let angle1 = Double(i) * .pi / 6
                                            let angle2 = Double((i + 1) % 12) * .pi / 6
                                            let point1 = CGPoint(
                                                x: 100 + 70 * cos(angle1),
                                                y: 100 + 70 * sin(angle1)
                                            )
                                            let point2 = CGPoint(
                                                x: 100 + 70 * cos(angle2),
                                                y: 100 + 70 * sin(angle2)
                                            )
                                            if i == 0 {
                                                path.move(to: point1)
                                            }
                                            path.addLine(to: point2)
                                        }
                                    }
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                }
                            )
                            .shadow(color: Color(hex: "D4AF37").opacity(0.8), radius: 20, x: 0, y: 0)
                            .shadow(color: Color(hex: "8A2BE2").opacity(0.6), radius: 30, x: 0, y: 0)
                            .scaleEffect(logoScale)
                            .rotationEffect(.degrees(logoRotation))
                        
                        // Logo image overlay
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180, height: 180)
                            .scaleEffect(logoScale)
                            .shadow(color: Color.white.opacity(0.8), radius: 10)
                    }
                    .padding(.vertical, 20)

                    Spacer()
                        .frame(height: 80)

                    // Tagline with cosmic styling
                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Life is easier WHEN YOU CAN")
                                .font(.dmSansSemibold16)
                                .foregroundColor(Color.white.opacity(0.9))
                            Text("SEE IT COMING")
                                .font(.dmSansSemibold16)
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                        .frame(maxWidth: 260, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "D4AF37"), location: 0.0),
                                        .init(color: Color(hex: "FF1493"), location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 3, height: 50)
                            .padding(.leading, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .offset(y: taglineOffset)
                    .opacity(opacity)
                    .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 8, x: 0, y: 0)

                    Spacer()
                    
                    // Tap to continue
                    HStack(spacing: 8) {
                        Circle()
                            .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                            .frame(width: 18, height: 18)
                            .scaleEffect(tapHintOpacity > 0.5 ? 1.1 : 1.0)
                        
                        Text("Tap anywhere to continue")
                            .font(.dmSansMedium13_4)
                            .foregroundColor(Color.gray.opacity(0.7))
                    }
                    .padding(.bottom, 60)
                    .opacity(tapHintOpacity)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: tapHintOpacity
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                startAnimations()
                startMotionUpdates()
            }
            .onDisappear {
                stopMotionUpdates()
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 0
                    logoScale = 0.3
                    magneticPulse = 0.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isActive = false
                }
            }
            .transition(.opacity)
        }
    }
    
    private func startAnimations() {
        // Main entrance animation
        withAnimation(.easeOut(duration: 1.5)) {
            opacity = 1.0
        }
        
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
            titleOffset = 0
            logoScale = 1.0
        }
        
        withAnimation(.spring(response: 1.4, dampingFraction: 0.8).delay(0.3)) {
            taglineOffset = 0
        }
        
        // Magnetic pulse animation
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(1.0)) {
            magneticPulse = 1.3
        }
        
        // Logo rotation
        withAnimation(.linear(duration: 120).repeatForever(autoreverses: false).delay(2.0)) {
            logoRotation = 360
        }
        
        // Celestial body orbital animations
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            celestialBody1Angle = 360
        }
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            celestialBody2Angle = -360
        }
        withAnimation(.linear(duration: 35).repeatForever(autoreverses: false)) {
            celestialBody3Angle = 360
        }
        withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
            celestialBody4Angle = -360
        }
        withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) {
            celestialBody5Angle = 360
        }
        withAnimation(.linear(duration: 65).repeatForever(autoreverses: false)) {
            celestialBody6Angle = -360
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            stardust1Angle = 360
        }
        withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
            stardust2Angle = -360
        }
        
        // Tap hint
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                tapHintOpacity = 1.0
            }
        }
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1/60.0
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            guard let motion = motion else { return }
            
            let attitude = motion.attitude
            let maxOffset: CGFloat = 20
            
            withAnimation(.easeOut(duration: 0.1)) {
                cosmosOffset = CGSize(
                    width: CGFloat(attitude.roll) * maxOffset,
                    height: CGFloat(attitude.pitch) * maxOffset
                )
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

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
    
    var body: some View {
        ZStack {
            // First group of celestial bodies
            CelestialGroup1(
                body1Angle: body1Angle,
                body2Angle: body2Angle,
                body3Angle: body3Angle,
                cosmosOffset: cosmosOffset
            )
            
            // Second group of celestial bodies
            CelestialGroup2(
                body4Angle: body4Angle,
                body5Angle: body5Angle,
                body6Angle: body6Angle,
                cosmosOffset: cosmosOffset
            )
            
            // Stardust rings
            StardustRings(
                stardust1Angle: stardust1Angle,
                stardust2Angle: stardust2Angle,
                cosmosOffset: cosmosOffset
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
    
    var body: some View {
        Group {
            // Large Purple Nebula
            CelestialBody(
                color: Color(hex: "8A2BE2"),
                size: 120,
                orbitRadius: 180,
                angle: body1Angle,
                blur: 60,
                opacity: 0.6,
                cosmosOffset: cosmosOffset
            )
            
            // Golden Comet
            CelestialBody(
                color: Color(hex: "D4AF37"),
                size: 80,
                orbitRadius: 240,
                angle: body2Angle,
                blur: 40,
                opacity: 0.8,
                cosmosOffset: cosmosOffset
            )
            
            // Magenta Star Cluster
            CelestialBody(
                color: Color(hex: "FF1493"),
                size: 100,
                orbitRadius: 300,
                angle: body3Angle,
                blur: 50,
                opacity: 0.7,
                cosmosOffset: cosmosOffset
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
    
    var body: some View {
        Group {
            // Deep Purple Gas Giant
            CelestialBody(
                color: Color(hex: "4B0082"),
                size: 140,
                orbitRadius: 360,
                angle: body4Angle,
                blur: 70,
                opacity: 0.5,
                cosmosOffset: cosmosOffset
            )
            
            // Rose Gold Asteroid Belt
            CelestialBody(
                color: Color(hex: "E6B8A2"),
                size: 60,
                orbitRadius: 420,
                angle: body5Angle,
                blur: 30,
                opacity: 0.9,
                cosmosOffset: cosmosOffset
            )
            
            // Violet Spiral Galaxy
            CelestialBody(
                color: Color(hex: "9370DB"),
                size: 110,
                orbitRadius: 480,
                angle: body6Angle,
                blur: 55,
                opacity: 0.6,
                cosmosOffset: cosmosOffset
            )
        }
    }
}

// Stardust rings group
struct StardustRings: View {
    let stardust1Angle: Double
    let stardust2Angle: Double
    let cosmosOffset: CGSize
    
    var body: some View {
        Group {
            StardustRing(
                color: Color(hex: "D4AF37"),
                radius: 140,
                angle: stardust1Angle,
                particleCount: 15,
                cosmosOffset: cosmosOffset
            )
            
            StardustRing(
                color: Color(hex: "FF1493"),
                radius: 320,
                angle: stardust2Angle,
                particleCount: 20,
                cosmosOffset: cosmosOffset
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
    
    var body: some View {
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
            .offset(
                x: cos(angle * .pi / 180) * orbitRadius + cosmosOffset.width * 0.3,
                y: sin(angle * .pi / 180) * orbitRadius + cosmosOffset.height * 0.3
            )
    }
}

// Stardust Ring
struct StardustRing: View {
    let color: Color
    let radius: CGFloat
    let angle: Double
    let particleCount: Int
    let cosmosOffset: CGSize
    
    var body: some View {
        ZStack {
            ForEach(0..<min(particleCount, 10), id: \.self) { index in
                StardustParticle(
                    color: color,
                    radius: radius,
                    angle: angle,
                    index: index,
                    totalCount: particleCount,
                    cosmosOffset: cosmosOffset
                )
            }
        }
    }
}

// Individual Stardust Particle
struct StardustParticle: View {
    let color: Color
    let radius: CGFloat
    let angle: Double
    let index: Int
    let totalCount: Int
    let cosmosOffset: CGSize
    
    private var particleAngle: Double {
        angle + Double(index) * 360.0 / Double(totalCount)
    }
    
    private var xOffset: CGFloat {
        cos(particleAngle * .pi / 180) * radius + cosmosOffset.width * 0.2
    }
    
    private var yOffset: CGFloat {
        sin(particleAngle * .pi / 180) * radius + cosmosOffset.height * 0.2
    }
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.8))
            .frame(width: 4, height: 4)
            .blur(radius: 2)
            .offset(x: xOffset, y: yOffset)
            .opacity(0.7)
    }
}

#Preview {
    SplashScreenView()
}
