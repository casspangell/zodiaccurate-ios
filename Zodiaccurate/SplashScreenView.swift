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

#Preview {
    SplashScreenView()
}
