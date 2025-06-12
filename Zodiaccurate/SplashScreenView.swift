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
    @State private var starAnimations: [Bool] = Array(repeating: false, count: 25)
    @State private var glowIntensity: Double = 0.5
    
    // Parallax motion variables
    @State private var motionManager = CMMotionManager()
    @State private var parallaxX: CGFloat = 0
    @State private var parallaxY: CGFloat = 0
    @State private var cosmosOffset: CGSize = .zero
    @State private var glowOffset: CGSize = .zero
    // Middle circle animation
    @State private var middleCircleScale: CGFloat = 1.0
    @State private var middleCircleOpacity: Double = 1.0

    var body: some View {
        if isActive {
            ZStack {
                // Cosmic animated background
                CosmicBackgroundView()

                // Background - Dark gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.backgroundPrimary,
                        Color.backgroundSecondary,
                        Color.backgroundPrimary
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Parallax cosmos layers
                ZStack {
                    // Large blurred background cosmos
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.accentGold.opacity(0.6), location: 0.0),
                                    .init(color: Color.accentPurple.opacity(0.5), location: 0.4),
                                    .init(color: Color.accentBlue.opacity(0.3), location: 0.7),
                                    .init(color: Color.clear, location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 400
                            )
                        )
                        .frame(width: 600, height: 600)
                        .blur(radius: 80)
                        .offset(cosmosOffset)
                        .opacity(glowIntensity * 0.8)
                    
                    // Medium layer
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.accentGold.opacity(0.4), location: 0.0),
                                    .init(color: Color.accentPurple.opacity(0.6), location: 0.5),
                                    .init(color: Color.clear, location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 30,
                                endRadius: 250
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 40)
                        .offset(x: cosmosOffset.width * 0.7, y: cosmosOffset.height * 0.7)
                        .opacity(glowIntensity * middleCircleOpacity)
                        .scaleEffect(middleCircleScale)
                        .animation(.easeInOut(duration: 2.0), value: middleCircleScale)
                    
                    // Smaller glow layer
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.accentGold.opacity(0.8), location: 0.0),
                                    .init(color: Color.accentPurple.opacity(0.7), location: 0.6),
                                    .init(color: Color.clear, location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 20,
                                endRadius: 150
                            )
                        )
                        .frame(width: 250, height: 250)
                        .blur(radius: 20)
                        .offset(x: cosmosOffset.width * 0.5, y: cosmosOffset.height * 0.5)
                        .opacity(glowIntensity * 1.2)
                }

                // Animated stars with parallax
                ForEach(0..<starAnimations.count, id: \.self) { index in
                    let starParallax = CGFloat(index % 3 + 1) * 0.3
                    Circle()
                        .fill(Color.whiteCustom.opacity(0.9))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 50...350) + cosmosOffset.width * starParallax,
                            y: CGFloat.random(in: 100...700) + cosmosOffset.height * starParallax
                        )
                        .opacity(starAnimations[index] ? 1.0 : 0.4)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...5))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...3)),
                            value: starAnimations[index]
                        )
                }

                VStack(spacing: 0) {
                    Spacer()
                    
                    // Title
                    Text("Zodiaccurate")
                        .dmSansSemibold56Tracking()
                        .foregroundColor(Color.whiteCustom)
                        .padding(.top, 40)
                        .offset(y: titleOffset)
                        .opacity(opacity)

                    Spacer()
                        .frame(height: 60)

                    // Main logo with realistic galaxy design
                    ZStack {
                        // Glow background for main logo
                        Circle()
                            .fill(RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.accentGold.opacity(0.35), location: 0.0),
                                    .init(color: Color.accentPurple.opacity(0.18), location: 0.7),
                                    .init(color: Color.clear, location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 160
                            ))
                            .frame(width: 260, height: 260)
                            .blur(radius: 32)
                            .offset(x: cosmosOffset.width * 0.1, y: cosmosOffset.height * 0.1)
                        // Main galaxy circle (no blur)
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.accentGold, location: 0.0),
                                        .init(color: Color.accentPurple, location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .overlay(
                                // Realistic constellation overlay
                                ZStack {
                                    // Constellation stars with varied sizes
                                    ForEach(0..<15, id: \.self) { index in
                                        Circle()
                                            .fill(Color.whiteCustom)
                                            .frame(width: CGFloat.random(in: 1...4), height: CGFloat.random(in: 1...4))
                                            .position(
                                                x: 100 + CGFloat.random(in: -80...80),
                                                y: 100 + CGFloat.random(in: -80...80)
                                            )
                                            .opacity(Double.random(in: 0.6...1.0))
                                            .shadow(color: Color.accentGold.opacity(0.6), radius: 2)
                                    }
                                    
                                    // Bright star effects
                                    ForEach(0..<5, id: \.self) { index in
                                        Image(systemName: "sparkle")
                                            .font(.system(size: CGFloat.random(in: 8...16)))
                                            .foregroundColor(Color.whiteCustom.opacity(0.9))
                                            .position(
                                                x: 100 + CGFloat.random(in: -70...70),
                                                y: 100 + CGFloat.random(in: -70...70)
                                            )
                                            .opacity(starAnimations.indices.contains(index) ? (starAnimations[index] ? 1.0 : 0.5) : 0.7)
                                    }
                                    
                                    // Nebula-like flowing lines
                                    Path { path in
                                        path.move(to: CGPoint(x: 50, y: 80))
                                        path.addQuadCurve(to: CGPoint(x: 150, y: 120), control: CGPoint(x: 100, y: 60))
                                        path.move(to: CGPoint(x: 80, y: 140))
                                        path.addQuadCurve(to: CGPoint(x: 130, y: 70), control: CGPoint(x: 160, y: 110))
                                    }
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.grayCustom.opacity(0.3), Color.clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                                }
                            )
                            .shadow(color: Color.accentGold.opacity(0.6), radius: 30, x: 0, y: 0)
                            .shadow(color: Color.accentPurple.opacity(0.4), radius: 50, x: 0, y: 0)
                            .scaleEffect(logoScale)
                            .rotationEffect(.degrees(logoRotation))
                        
                        // Logo image overlay
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180, height: 180)
                            .scaleEffect(logoScale)
                            .shadow(color: Color.whiteCustom.opacity(0.5), radius: 5)
                            .offset(x: cosmosOffset.width * 0.05, y: cosmosOffset.height * 0.05)
                    }
                    .padding(.vertical, 20)
                    // Lens flare (animated, above main logo)
                    LensFlareView()
                        .frame(width: 220, height: 100)
                        .offset(y: -60)

                    Spacer()
                        .frame(height: 80)

                    // Tagline with gradient accent
                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Life is easier WHEN YOU CAN")
                                .font(.dmSansSemibold16)
                                .foregroundColor(Color.whiteCustom.opacity(0.9))
                            Text("SEE IT COMING")
                                .font(.dmSansSemibold16)
                                .foregroundColor(Color.whiteCustom.opacity(0.9))
                        }
                        .frame(maxWidth: 260, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.accentGold, location: 0.0),
                                        .init(color: Color.accentPurple, location: 1.0)
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

                    Spacer()
                    
                    // Tap to continue
                    HStack(spacing: 8) {
                        Circle()
                            .stroke(Color.grayCustom, lineWidth: 2)
                            .frame(width: 18, height: 18)
                            .scaleEffect(tapHintOpacity > 0.5 ? 1.1 : 1.0)
                        
                        Text("Tap anywhere to continue")
                            .font(.dmSansMedium13_4)
                            .foregroundColor(Color.grayCustom)
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
                    logoScale = 0.5
                    glowIntensity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isActive = false
                }
            }
            .transition(.opacity)
        }
    }
    
    private func startAnimations() {
        // Start star twinkles
        for index in starAnimations.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1)) {
                starAnimations[index] = true
            }
        }
        
        // Main entrance animation sequence
        withAnimation(.easeOut(duration: 1.2)) {
            opacity = 1.0
        }
        
        withAnimation(.spring(response: 1.0, dampingFraction: 0.7, blendDuration: 0)) {
            titleOffset = 0
            logoScale = 1.0
        }
        
        withAnimation(.spring(response: 1.2, dampingFraction: 0.8, blendDuration: 0).delay(0.3)) {
            taglineOffset = 0
        }
        
        // Glow pulsing
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(1.5)) {
            glowIntensity = 1.2
        }
        
        // Subtle logo rotation
        withAnimation(.linear(duration: 60).repeatForever(autoreverses: false).delay(2.0)) {
            logoRotation = 360
        }
        
        // Middle circle expand and blend
        withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
            middleCircleScale = 3.0
            middleCircleOpacity = 0.0
        }
        
        // Tap hint appears last
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
            let maxOffset: CGFloat = 30
            
            withAnimation(.easeOut(duration: 0.1)) {
                cosmosOffset = CGSize(
                    width: CGFloat(attitude.roll) * maxOffset,
                    height: CGFloat(attitude.pitch) * maxOffset
                )
                
                glowOffset = CGSize(
                    width: CGFloat(attitude.roll) * maxOffset * 0.5,
                    height: CGFloat(attitude.pitch) * maxOffset * 0.5
                )
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// Cosmic animated background view
struct CosmicBackgroundView: View {
    @State private var angle1: Double = 0
    @State private var angle2: Double = 0
    @State private var angle3: Double = 0
    @State private var angle4: Double = 0
    @State private var angle5: Double = 0

    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Circle 1: Deep purple, large, slow orbit
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "490073").opacity(0.95), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 700, height: 700)
                .blur(radius: 120)
                .opacity(0.7)
                .offset(x: CGFloat(cos(angle1)) * 180 - 80, y: CGFloat(sin(angle1)) * 160 - 120)
            // Circle 2: Golden orange, medium, counter-orbit
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "E39D4D").opacity(0.85), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 500, height: 500)
                .blur(radius: 80)
                .opacity(0.6)
                .offset(x: CGFloat(cos(angle2)) * 220 + 120, y: CGFloat(sin(angle2)) * 100 - 60)
            // Circle 3: Blue, small, fast orbit
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "00324B").opacity(0.95), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .opacity(0.8)
                .offset(x: CGFloat(cos(angle3)) * 140 - 60, y: CGFloat(sin(angle3)) * 260 + 100)
            // Circle 4: Magenta, large, slow counter-orbit
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "D38DFC").opacity(0.8), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 600, height: 600)
                .blur(radius: 100)
                .opacity(0.5)
                .offset(x: CGFloat(cos(angle4)) * 200 + 100, y: CGFloat(sin(angle4)) * 320 + 160)
            // Circle 5: Gold + purple, medium, fast orbit
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "E39D4D").opacity(0.7), Color(hex: "490073").opacity(0.6), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 400, height: 400)
                .blur(radius: 60)
                .opacity(0.9)
                .offset(x: CGFloat(cos(angle5)) * 200 - 160, y: CGFloat(sin(angle5)) * 120 + 80)
            // Circle 6: Magenta-Blue gradient, dramatic
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "D38DFC").opacity(0.9), Color(hex: "00324B").opacity(0.7), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 480, height: 480)
                .blur(radius: 90)
                .opacity(0.7)
                .offset(x: CGFloat(cos(angle2 + .pi/2)) * 260 - 100, y: CGFloat(sin(angle2 + .pi/2)) * 180 - 60)
        }
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            // Animate each angle at a unique speed and direction
            angle1 += .pi / (60 * 20) // 1 full orbit in ~40s
            angle2 -= .pi / (60 * 10) // 1 full orbit in ~20s, opposite
            angle3 += .pi / (60 * 4)  // 1 full orbit in ~8s
            angle4 -= .pi / (60 * 30) // 1 full orbit in ~60s, opposite
            angle5 += .pi / (60 * 7)  // 1 full orbit in ~14s
        }
    }
}

// Custom checkmark shape
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX + rect.width * 0.25, y: rect.midY + rect.height * 0.05)
        let mid = CGPoint(x: rect.midX - rect.width * 0.05, y: rect.maxY - rect.height * 0.25)
        let end = CGPoint(x: rect.maxX - rect.width * 0.2, y: rect.minY + rect.height * 0.25)
        
        path.move(to: start)
        path.addLine(to: mid)
        path.addLine(to: end)
        
        return path
    }
}

// Photographic lens flare view
struct LensFlareView: View {
    @State private var flareRotation: Double = 0
    @State private var flarePulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Large faint outer ring
            Circle()
                .strokeBorder(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.12), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 1
                    ),
                    lineWidth: 60 * flarePulse
                )
                .frame(width: 420 * flarePulse, height: 420 * flarePulse)
                .blur(radius: 32)
                .opacity(0.18)

            // Main bright core
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.95), Color.red.opacity(0.5), Color.clear]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                ))
                .frame(width: 60 * flarePulse, height: 60 * flarePulse)
                .blur(radius: 8)
                .opacity(0.95)

            // Red ring around core
            Circle()
                .strokeBorder(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.7), Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 1
                    ),
                    lineWidth: 10 * flarePulse
                )
                .frame(width: 110 * flarePulse, height: 110 * flarePulse)
                .blur(radius: 2)
                .opacity(0.7)

            // Ghost circles along the flare axis
            FlareGhost(offset: -80, size: 38, color: Color.yellow.opacity(0.18), blur: 8, opacity: 0.7, pulse: flarePulse)
            FlareGhost(offset: -120, size: 28, color: Color.orange.opacity(0.22), blur: 6, opacity: 0.5, pulse: flarePulse)
            FlareGhost(offset: 90, size: 60, color: Color.green.opacity(0.18), blur: 10, opacity: 0.5, pulse: flarePulse)
            FlareGhost(offset: 130, size: 38, color: Color.blue.opacity(0.22), blur: 8, opacity: 0.4, pulse: flarePulse)
            FlareGhost(offset: 170, size: 22, color: Color.cyan.opacity(0.18), blur: 4, opacity: 0.3, pulse: flarePulse)
            FlareGhost(offset: 210, size: 90, color: Color.green.opacity(0.12), blur: 16, opacity: 0.22, pulse: flarePulse)
        }
        .rotationEffect(.degrees(flareRotation))
        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: flarePulse)
        .animation(.linear(duration: 24).repeatForever(autoreverses: false), value: flareRotation)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                flarePulse = 1.12
            }
            withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                flareRotation = 360
            }
        }
    }
}

struct FlareGhost: View {
    var offset: CGFloat
    var size: CGFloat
    var color: Color
    var blur: CGFloat
    var opacity: Double
    var pulse: CGFloat
    var body: some View {
        Circle()
            .fill(RadialGradient(
                gradient: Gradient(colors: [color, Color.clear]),
                center: .center,
                startRadius: 0,
                endRadius: 1
            ))
            .frame(width: size * pulse, height: size * pulse)
            .blur(radius: blur)
            .opacity(opacity)
            .offset(x: offset * pulse, y: offset * 0.18 * pulse)
    }
}

#Preview {
    SplashScreenView()
}

