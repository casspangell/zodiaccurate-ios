import SwiftUI

//used in settings
struct ZodiacProfileBadgeForSettings: View {
    var zodiacSign: String = ""
    
    // Computed property to get the zodiac image based on the sign
    private var zodiacImage: Image {
        // Use the existing ZodiacSign enum to get the asset name
        if let sign = ZodiacSign(rawValue: zodiacSign) {
            return Image(sign.assetName)
        } else {
            return Image("logo") // Default fallback
        }
    }
    
    var body: some View {
        ZStack {
            // Large gradient circle behind
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 180)
                .blur(radius: 20)
            
            // Main black circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 140, height: 140)
            
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        }
        .frame(width: 180, height: 180)
        .padding(.top, 24)
    }
}

// MARK: - Customizable Zodiac Profile Badge
struct CustomZodiacProfileBadge: View {
    var zodiacImage: Image = Image("Capricorn")
    var frameSize: CGFloat = 180
    
    private var gradientCircleSize: CGFloat { frameSize }
    private var mainCircleSize: CGFloat { frameSize * 0.778 } // 140/180 ratio
    private var zodiacImageSize: CGFloat { frameSize * 0.667 } // 120/180 ratio
    private var blurRadius: CGFloat { frameSize * 0.111 } // 20/180 ratio
    private var topPadding: CGFloat { frameSize * 0.133 } // 24/180 ratio
    
    var body: some View {
        ZStack {
            // Large gradient circle behind
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: gradientCircleSize, height: gradientCircleSize)
                .blur(radius: blurRadius)
            
            // Main black circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: mainCircleSize * 0.857 // 120/140 ratio
                    )
                )
                .frame(width: mainCircleSize, height: mainCircleSize)
            
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: zodiacImageSize, height: zodiacImageSize)
                .clipShape(Circle())
        }
        .frame(width: frameSize, height: frameSize)
        .padding(.top, topPadding)
    }
}

struct ZodiacProfileBadgeWhite: View {
    var zodiacImage: Image = Image("Capricorn") // Change as needed
    var body: some View {
        ZStack {
            // Large gradient circle behind
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 180)
                .blur(radius: 20)
            
            // Main black circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 140, height: 140)
            
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        }
        .frame(width: 180, height: 180)
        .padding(.top, 24)
    }
}

// MARK: - Customizable White Zodiac Profile Badge
struct CustomZodiacProfileBadgeWhite: View {
    var zodiacImage: Image = Image("Capricorn")
    var frameSize: CGFloat = 180
    
    private var gradientCircleSize: CGFloat { frameSize }
    private var mainCircleSize: CGFloat { frameSize * 0.778 } // 140/180 ratio
    private var zodiacImageSize: CGFloat { frameSize * 0.667 } // 120/180 ratio
    private var blurRadius: CGFloat { frameSize * 0.111 } // 20/180 ratio
    private var topPadding: CGFloat { frameSize * 0.133 } // 24/180 ratio
    
    var body: some View {
        ZStack {
            // Large gradient circle behind
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: gradientCircleSize, height: gradientCircleSize)
                .blur(radius: blurRadius)
            
            // Main white circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: mainCircleSize * 0.857 // 120/140 ratio
                    )
                )
                .frame(width: mainCircleSize, height: mainCircleSize)
            
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: zodiacImageSize, height: zodiacImageSize)
                .clipShape(Circle())
        }
        .frame(width: frameSize, height: frameSize)
        .padding(.top, topPadding)
    }
}

// MARK: - Partial Profile Widget
/// A partial profile widget that shows a cropped portion of the zodiac profile badge
/// This creates a peek-a-boo effect where the badge appears to be partially hidden
struct PartialProfileWidget: View {
    var zodiacImage: Image = Image("Capricorn")
    var size: CGFloat = 120
    var showPercentage: CGFloat = 0.6 // How much of the badge to show (0.0 to 1.0)
    
    var body: some View {
        ZStack {
            // Large gradient circle behind (partial)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 15)
                .offset(x: -size * 0.25, y: 0) // Offset to show partial view
            
            // Main black circle (partial)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.17, height: size * 1.17)
                .offset(x: -size * 0.08, y: 0) // Offset to show partial view
            
            // Zodiac image (partial)
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .offset(x: -size * 0.08, y: 0) // Offset to show partial view
        }
        .frame(width: size * showPercentage, height: size)
        .clipped() // Clip the view to show only the partial amount
        .padding(.top, 16)
        .padding(.leading, 8)
    }
}

// MARK: - Compact Profile Widget
/// A more compact version of the partial profile widget
struct CompactProfileWidget: View {
    var zodiacImage: Image = Image("Capricorn")
    var size: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Gradient background (smaller and more subtle)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.4),
                            Color.pink.opacity(0.4),
                            Color.purple.opacity(0.4)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: 10)
                .offset(x: -size * 0.15, y: 0)
            
            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7)
                        ]),
                        center: .center,
                        startRadius: 3,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .offset(x: -size * 0.1, y: 0)
            
            // Zodiac image
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.85, height: size * 0.85)
                .clipShape(Circle())
                .offset(x: -size * 0.1, y: 0)
        }
        .frame(width: size * 0.7, height: size)
        .clipped()
        .padding(.top, 12)
        .padding(.leading, 6)
    }
}

// MARK: - Cosmic Badge Effects
/// Cosmic visual effects for the zodiac badge during onboarding
struct CosmicBadgeEffects: View {
    let badgeScale: CGFloat
    let badgeRotation: Double
    let cosmicGlowOpacity: Double
    let nebulaOpacity: Double
    let starFieldOpacity: Double
    let cosmicParticlesOpacity: Double
    let sparkleOpacity: Double
    let currentProfileImage: String
    
    var body: some View {
        ZStack {
            // Cosmic glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.purple.opacity(0.8), location: 0.0),
                            .init(color: Color.blue.opacity(0.4), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(cosmicGlowOpacity)
                .scaleEffect(badgeScale)
                .animation(.easeInOut(duration: 1.2), value: cosmicGlowOpacity)
            // Nebula effect
            ZStack {
                ForEach(0..<3) { layer in
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.purple.opacity(0.3), location: 0.0),
                                    .init(color: Color.blue.opacity(0.2), location: 0.3),
                                    .init(color: Color.pink.opacity(0.3), location: 0.6),
                                    .init(color: Color.purple.opacity(0.3), location: 1.0)
                                ]),
                                center: .center
                            )
                        )
                        .frame(width: 160 + CGFloat(layer * 20), height: 160 + CGFloat(layer * 20))
                        .rotationEffect(.degrees(Double(layer) * 45))
                        .opacity(nebulaOpacity)
                        .animation(
                            .easeInOut(duration: 2.0)
                            .delay(Double(layer) * 0.3),
                            value: nebulaOpacity
                        )
                }
            }
            // Star field effect
            ZStack {
                ForEach(0..<12) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                        .offset(
                            x: 80 * cos(Double(index) * .pi / 6),
                            y: 80 * sin(Double(index) * .pi / 6)
                        )
                        .opacity(starFieldOpacity)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .delay(Double(index) * 0.1),
                            value: starFieldOpacity
                        )
                }
            }
            // Cosmic particles
            ZStack {
                ForEach(0..<6) { index in
                    Image(systemName: "sparkle")
                        .foregroundColor([Color.yellow, Color.cyan, Color.pink, Color.white].randomElement()!)
                        .font(.system(size: 12))
                        .offset(
                            x: 70 * cos(Double(index) * .pi / 3),
                            y: 70 * sin(Double(index) * .pi / 3)
                        )
                        .opacity(cosmicParticlesOpacity)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .delay(Double(index) * 0.2),
                            value: cosmicParticlesOpacity
                        )
                }
            }
            // Original sparkle effect (now cosmic)
            ForEach(0..<8) { index in
                Image(systemName: "sparkle")
                    .foregroundColor([Color.yellow, Color.cyan, Color.pink].randomElement()!)
                    .font(.system(size: 16))
                    .offset(
                        x: 60 * cos(Double(index) * .pi / 4),
                        y: 60 * sin(Double(index) * .pi / 4)
                    )
                    .opacity(sparkleOpacity)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .delay(Double(index) * 0.1),
                        value: sparkleOpacity
                    )
            }
        }
    }
}

// MARK: - Stardust Indicator
/// A small circular indicator that displays stardust points on the outer edge of the zodiac badge
/// Rotates around the badge like a clock based on stardust amount (100 stardust per full rotation)
struct StardustIndicator: View {
    let stardustPoints: Int
    let frameSize: CGFloat = 180 // Default to match original badge size
    let size: CGFloat = 32
    
    // Calculate the main circle radius dynamically based on frame size
    // Uses the same scaling as CustomZodiacProfileBadge: frameSize * 0.778 / 2 = frameSize * 0.389
    private var mainCircleRadius: CGFloat { frameSize * 0.389 }
    
    /// Calculates the position offset based on stardust points
    /// 100 stardust = 1 full rotation (360 degrees)
    /// 12 o'clock (top) = multiples of 100
    /// 6 o'clock (bottom) = multiples of 50
    private var offset: CGSize {
        // Convert stardust to degrees (100 stardust = 360 degrees)
        let degrees = Double(stardustPoints) * 360.0 / 100.0
        
        // Convert degrees to radians
        let radians = degrees * .pi / 180.0
        
        // Calculate position on circumference of the main circle
        let x = mainCircleRadius * cos(radians)
        let y = -mainCircleRadius * sin(radians) // Negative because SwiftUI Y-axis is inverted
        
        return CGSize(width: x, height: y)
    }
    
    var body: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.accentGold.opacity(0.9),
                            Color.yellow.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.accentGold.opacity(0.5), radius: 4, x: 0, y: 2)
            
            // Stardust points text
            Text("\(stardustPoints)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .offset(offset)
        .animation(.easeInOut(duration: 0.5), value: stardustPoints)
    }
}

// MARK: - Customizable Stardust Indicator with Ripple Animation
/// A customizable version of StardustIndicator that scales with the badge frame size and includes ripple animation
struct CustomStardustIndicator: View {
    let stardustPoints: Int
    let frameSize: CGFloat
    
    // Animation states for ripple effect
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    @State private var showRipple: Bool = false
    @State private var previousStardustPoints: Int = 0
    
    // Animation states for cosmic entrance
    @State private var entranceScale: CGFloat = 0.1
    @State private var cosmicGlowOpacity: Double = 0
    @State private var nebulaOpacity: Double = 0
    @State private var starFieldOpacity: Double = 0
    @State private var cosmicParticlesOpacity: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var numberOpacity: Double = 0
    @State private var hasStartedEntranceAnimation = false
    
    // Scale the indicator size based on frame size (32/180 ratio)
    private var indicatorSize: CGFloat { frameSize * 0.178 }
    
    // Scale the main circle radius based on frame size (70/180 ratio)
    private var mainCircleRadius: CGFloat { frameSize * 0.389 }
    
    // Scale the font size based on frame size (12/180 ratio)
    private var fontSize: CGFloat { frameSize * 0.067 }
    
    // Scale the shadow radius based on frame size (4/180 ratio)
    private var shadowRadius: CGFloat { frameSize * 0.022 }
    
    /// Calculates the position offset based on stardust points
    /// 100 stardust = 1 full rotation (360 degrees)
    /// 12 o'clock (top) = multiples of 100
    /// 6 o'clock (bottom) = multiples of 50
    private var offset: CGSize {
        // Convert stardust to degrees (100 stardust = 360 degrees)
        let degrees = Double(stardustPoints) * 360.0 / 100.0
        
        // Convert degrees to radians
        let radians = degrees * .pi / 180.0
        
        // Calculate position on circumference of the main circle
        let x = mainCircleRadius * cos(radians)
        let y = -mainCircleRadius * sin(radians) // Negative because SwiftUI Y-axis is inverted
        
        return CGSize(width: x, height: y)
    }
    
    var body: some View {
        ZStack {
            // Cosmic glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.accentGold.opacity(0.8),
                            Color.accentGold.opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: indicatorSize * 0.5,
                        endRadius: indicatorSize * 1.5
                    )
                )
                .frame(width: indicatorSize * 3, height: indicatorSize * 3)
                .scaleEffect(cosmicGlowOpacity > 0 ? 1.0 : 0.1)
                .opacity(cosmicGlowOpacity)
                .animation(.easeInOut(duration: 0.8), value: cosmicGlowOpacity)
            
            // Nebula effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.6),
                            Color.blue.opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: indicatorSize * 0.3,
                        endRadius: indicatorSize * 1.2
                    )
                )
                .frame(width: indicatorSize * 2.5, height: indicatorSize * 2.5)
                .scaleEffect(nebulaOpacity > 0 ? 1.0 : 0.1)
                .opacity(nebulaOpacity)
                .animation(.easeInOut(duration: 1.0), value: nebulaOpacity)
            
            // Star field effect
            ForEach(0..<12) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 2, height: 2)
                    .offset(
                        x: indicatorSize * 0.8 * cos(Double(index) * .pi / 6),
                        y: indicatorSize * 0.8 * sin(Double(index) * .pi / 6)
                    )
                    .opacity(starFieldOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.05), value: starFieldOpacity)
            }
            
            // Cosmic particles
            ForEach(0..<8) { index in
                Circle()
                    .fill(Color.accentGold)
                    .frame(width: 3, height: 3)
                    .offset(
                        x: indicatorSize * 1.1 * cos(Double(index) * .pi / 4),
                        y: indicatorSize * 1.1 * sin(Double(index) * .pi / 4)
                    )
                    .opacity(cosmicParticlesOpacity)
                    .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1), value: cosmicParticlesOpacity)
            }
            
            // Sparkles
            ForEach(0..<6) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: 8))
                    .foregroundColor([Color.yellow, Color.cyan, Color.pink].randomElement()!)
                    .offset(
                        x: indicatorSize * 0.9 * cos(Double(index) * .pi / 3),
                        y: indicatorSize * 0.9 * sin(Double(index) * .pi / 3)
                    )
                    .opacity(sparkleOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: sparkleOpacity)
            }
            
            // Ripple effect (water droplet animation)
            if showRipple {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentGold.opacity(0.8),
                                Color.yellow.opacity(0.6),
                                Color.clear
                            ]),
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: indicatorSize * rippleScale, height: indicatorSize * rippleScale)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .animation(.easeOut(duration: 0.8), value: rippleScale)
                    .animation(.easeOut(duration: 0.8), value: rippleOpacity)
            }
            
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.accentGold.opacity(0.9),
                            Color.yellow.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: indicatorSize, height: indicatorSize)
                .shadow(color: Color.accentGold.opacity(0.5), radius: shadowRadius, x: 0, y: 2)
                .scaleEffect(showRipple ? 1.1 : entranceScale)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showRipple)
                .animation(.easeInOut(duration: 0.8), value: entranceScale)
            
            // Stardust points text
            Text("\(stardustPoints)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .scaleEffect(showRipple ? 1.05 : 1.0)
                .opacity(numberOpacity)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showRipple)
                .animation(.easeInOut(duration: 0.5), value: numberOpacity)
        }
        .offset(offset)
        .opacity(1.0) // Ensure stardust indicator is fully visible
        .animation(.easeInOut(duration: 0.5), value: stardustPoints)
        .onAppear {
            if !hasStartedEntranceAnimation {
                startEntranceAnimation()
            }
        }
        .onChange(of: stardustPoints) { oldValue, newValue in
            if newValue > oldValue {
                triggerRippleAnimation()
            }
        }
    }
    
    private func startEntranceAnimation() {
        hasStartedEntranceAnimation = true
        
        // Start with small scale and no cosmic effects
        entranceScale = 0.1
        cosmicGlowOpacity = 0
        nebulaOpacity = 0
        starFieldOpacity = 0
        cosmicParticlesOpacity = 0
        sparkleOpacity = 0
        numberOpacity = 0
        
        // Phase 1: Scale up with cosmic glow
        withAnimation(.easeOut(duration: 0.4)) {
            entranceScale = 1.3
            cosmicGlowOpacity = 1.0
        }
        
        // Phase 2: Add nebula and star field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                nebulaOpacity = 1.0
                starFieldOpacity = 1.0
            }
        }
        
        // Phase 3: Add cosmic particles and sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.8)) {
                cosmicParticlesOpacity = 1.0
                sparkleOpacity = 1.0
            }
        }
        
        // Phase 4: Return to normal size and show number
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.6)) {
                entranceScale = 1.0
                numberOpacity = 1.0
            }
        }
        
        // Phase 5: Fade out cosmic effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.8)) {
                cosmicGlowOpacity = 0
                nebulaOpacity = 0
                starFieldOpacity = 0
                cosmicParticlesOpacity = 0
                sparkleOpacity = 0
            }
        }
    }
    
    private func triggerRippleAnimation() {
        // Reset ripple state
        rippleScale = 1.0
        rippleOpacity = 0.8
        showRipple = true
        
        // Animate ripple expansion
        withAnimation(.easeOut(duration: 0.8)) {
            rippleScale = 2.5
            rippleOpacity = 0.0
        }
        
        // Reset after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showRipple = false
            rippleScale = 1.0
            rippleOpacity = 0.0
        }
    }
}

// MARK: - Localized Stardust Earning Animation
/// A localized animation that happens directly on the profile badge when stardust is earned
struct LocalizedStardustAnimation: View {
    let amount: Int
    let type: StardustTransactionType
    @Binding var isShowing: Bool
    
    // Animation states
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var textScale: CGFloat = 0.5
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Glow effect around the badge
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.accentGold.opacity(0.8),
                            Color.accentGold.opacity(0.4),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(scale)
                .opacity(glowIntensity)
            
            // Sparkles around the badge
            ForEach(0..<6) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundColor([Color.yellow, Color.cyan, Color.pink].randomElement()!)
                    .offset(
                        x: 100 * cos(Double(index) * .pi / 3),
                        y: 100 * sin(Double(index) * .pi / 3)
                    )
                    .opacity(sparkleOpacity)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .delay(Double(index) * 0.1),
                        value: sparkleOpacity
                    )
            }
            
            // Amount text floating up
            VStack(spacing: 4) {
                Text("\(amount)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.accentGold)
                    .scaleEffect(textScale)
                
                Text(type.emoji)
                    .font(.system(size: 14))
                    .scaleEffect(textScale)
            }
            .offset(y: particleOffset)
            .opacity(opacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Initial state
        scale = 0.1
        opacity = 0
        rotation = 0
        sparkleOpacity = 0
        glowIntensity = 0
        textScale = 0.5
        particleOffset = 0
        
        // Animate in
        withAnimation(.easeOut(duration: 0.4)) {
            scale = 1.0
            glowIntensity = 1.0
        }
        
        // Show sparkles
        withAnimation(.easeInOut(duration: 0.3).delay(0.2)) {
            sparkleOpacity = 1.0
        }
        
        // Animate text
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.3)) {
            textScale = 1.0
            opacity = 1.0
        }
        
        // Float text up
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            particleOffset = -60
        }
        
        // Fade out
        withAnimation(.easeIn(duration: 0.3).delay(1.2)) {
            opacity = 0
            glowIntensity = 0
            sparkleOpacity = 0
        }
        
        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isShowing = false
            // Notify that the stardust animation has completed
            NotificationCenter.default.post(name: .stardustAnimationCompleted, object: nil)
        }
    }
}

// MARK: - Enhanced Zodiac Profile Badge with Stardust
struct ZodiacProfileBadgeWithStardust: View {
    var zodiacImage: Image = Image("Capricorn")
    var stardustPoints: Int = 0
    var frameSize: CGFloat = 180 // Default size, can be customized
    @State private var showEarningAnimation = false
    @State private var earningAmount = 0
    @State private var earningType: StardustTransactionType = .earned
    @State private var showStardustIndicator = false
    @State private var hasTriggeredEarning = false
    
    var body: some View {
        ZStack {
            // Customizable ZodiacProfileBadge with frame size
            CustomZodiacProfileBadge(zodiacImage: zodiacImage, frameSize: frameSize)
            
            // Stardust indicator (scaled to frame size) - appears after earning animation
            if showStardustIndicator {
                CustomStardustIndicator(stardustPoints: stardustPoints, frameSize: frameSize)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Localized earning animation
            if showEarningAnimation {
                LocalizedStardustAnimation(
                    amount: earningAmount,
                    type: earningType,
                    isShowing: $showEarningAnimation
                )
            }
        }
        .frame(width: frameSize, height: frameSize)
        .onReceive(NotificationCenter.default.publisher(for: .stardustEarned)) { notification in
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? Int,
               let type = userInfo["type"] as? StardustTransactionType {
                triggerEarningAnimation(amount: amount, type: type)
            }
        }
        .onChange(of: stardustPoints) { oldValue, newValue in
            // Update indicator visibility when stardust balance changes
            if newValue > 0 && !showStardustIndicator {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStardustIndicator = true
                }
            } else if newValue == 0 && showStardustIndicator {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStardustIndicator = false
                }
            }
        }
        .onAppear {
            // Show stardust indicator immediately if no earning animation is expected and user has stardust
            if !hasTriggeredEarning && stardustPoints > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showStardustIndicator = true
                    }
                }
            }
        }
    }
    
    private func triggerEarningAnimation(amount: Int, type: StardustTransactionType) {
        // Use the current stardust balance for the animation, not the earned amount
        earningAmount = stardustPoints
        earningType = type
        hasTriggeredEarning = true
        showEarningAnimation = true
        
        print("🎯 ZodiacProfileBadgeWithStardust: Triggering earning animation for current balance: \(stardustPoints) stardust")
        
        // Show stardust indicator after earning animation completes (1.5 seconds) only if user has stardust
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showStardustIndicator = stardustPoints > 0
            }
        }
    }
}

// MARK: - Enhanced White Zodiac Profile Badge with Stardust
/// Enhanced version of ZodiacProfileBadgeWhite that includes a stardust indicator and localized earning animation
struct ZodiacProfileBadgeWhiteWithStardust: View {
    var zodiacImage: Image = Image("Capricorn")
    var stardustPoints: Int = 0
    var frameSize: CGFloat = 180 // Default size, can be customized
    @State private var showEarningAnimation = false
    @State private var earningAmount = 0
    @State private var earningType: StardustTransactionType = .earned
    @State private var showStardustIndicator = false
    @State private var hasTriggeredEarning = false
    
    var body: some View {
        ZStack {
            // Customizable ZodiacProfileBadgeWhite with frame size
            CustomZodiacProfileBadgeWhite(zodiacImage: zodiacImage, frameSize: frameSize)
            
            // Stardust indicator (scaled to frame size) - appears after earning animation
            if showStardustIndicator {
                CustomStardustIndicator(stardustPoints: stardustPoints, frameSize: frameSize)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Localized earning animation
            if showEarningAnimation {
                LocalizedStardustAnimation(
                    amount: earningAmount,
                    type: earningType,
                    isShowing: $showEarningAnimation
                )
            }
        }
        .frame(width: frameSize, height: frameSize)
        .onReceive(NotificationCenter.default.publisher(for: .stardustEarned)) { notification in
            if let userInfo = notification.userInfo,
               let amount = userInfo["amount"] as? Int,
               let type = userInfo["type"] as? StardustTransactionType {
                triggerEarningAnimation(amount: amount, type: type)
            }
        }
        .onChange(of: stardustPoints) { oldValue, newValue in
            // Update indicator visibility when stardust balance changes
            if newValue > 0 && !showStardustIndicator {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStardustIndicator = true
                }
            } else if newValue == 0 && showStardustIndicator {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStardustIndicator = false
                }
            }
        }
        .onAppear {
            if !hasTriggeredEarning && stardustPoints > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showStardustIndicator = true
                    }
                }
            }
        }
    }
    
    private func triggerEarningAnimation(amount: Int, type: StardustTransactionType) {
        // Use the current stardust balance for the animation, not the earned amount
        earningAmount = stardustPoints
        earningType = type
        hasTriggeredEarning = true
        showEarningAnimation = true
        
        print("🎯 ZodiacProfileBadgeWhiteWithStardust: Triggering earning animation for current balance: \(stardustPoints) stardust")
        
        // Show stardust indicator after earning animation completes (1.5 seconds) only if user has stardust
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showStardustIndicator = stardustPoints > 0
            }
        }
    }
}

// MARK: - Badge Animation Manager
/// Manages the cosmic badge animation sequence for zodiac sign acquisition
class BadgeAnimationManager: ObservableObject {
    @Published var isAcquiringBadge = false
    @Published var badgeScale: CGFloat = 1.0
    @Published var badgeRotation: Double = 0
    @Published var sparkleOpacity: Double = 0
    @Published var cosmicParticlesOpacity: Double = 0
    @Published var nebulaOpacity: Double = 0
    @Published var starFieldOpacity: Double = 0
    @Published var cosmicGlowOpacity: Double = 0
    @Published var currentProfileImage = "logo"
    
    /// Triggers the cosmic badge animation sequence
    /// - Parameter newAssetName: The new zodiac sign asset name to swap to
    func triggerBadgeAnimation(andSwapTo newAssetName: String) {
        isAcquiringBadge = true
        
        // Phase 1 & 2: Build up cosmic effects and scale up badge
        withAnimation(Animation.easeInOut(duration: 0.8)) { cosmicGlowOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                self.badgeScale = 1.3
                self.badgeRotation = 15
            }
            withAnimation(Animation.easeInOut(duration: 1.0)) { self.nebulaOpacity = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(Animation.easeInOut(duration: 0.8)) {
                self.starFieldOpacity = 1.0
                self.cosmicParticlesOpacity = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(Animation.easeInOut(duration: 0.3)) { self.sparkleOpacity = 1.0 }
        }

        // Phase 3: Funnel effect - spin and shrink
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.linear(duration: 0.8)) {
                self.badgeRotation += 1080 // Spin 3 times
                self.badgeScale = 0.01 // Shrink to almost nothing
            }
        }
        
        // Phase 4: Swap image and pop it into view
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // After funnel
            // Instantly swap image and reset rotation
            self.currentProfileImage = newAssetName
            self.badgeRotation = 0
            
            // Pop out with spring animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                self.badgeScale = 1.0
            }
        }
        
        // Phase 5: Fade out all cosmic effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(Animation.easeInOut(duration: 0.8)) {
                self.sparkleOpacity = 0.0
                self.cosmicParticlesOpacity = 0.0
                self.starFieldOpacity = 0.0
                self.nebulaOpacity = 0.0
                self.cosmicGlowOpacity = 0.0
            }
        }
        
        // Phase 6: Reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            self.isAcquiringBadge = false
        }
    }
}

// MARK: - Spinning Stardust Demo
struct SpinningStardustDemo: View {
    @State private var showStardustIndicator = false
    @State private var stardustPoints = 0
    
    var body: some View {
        VStack(spacing: 16) {
            // Demo badge with stardust indicator
            ZStack {
                // Background badge
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .purple.opacity(0.5), radius: 4, x: 0, y: 2)
                
                // Zodiac image placeholder
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                // Stardust indicator (only show when triggered)
                if showStardustIndicator {
                    CustomStardustIndicator(
                        stardustPoints: stardustPoints,
                        frameSize: 120
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Demo button
            Button(action: {
                triggerStardustAnimation()
            }) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.accentGold)
                    Text("Trigger Cosmic Stardust")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentGold.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentGold, lineWidth: 1)
                        )
                )
            }
            .disabled(showStardustIndicator)
            
            // Status text
            Text(showStardustIndicator ? "Animation in progress..." : "Tap button to see cosmic animation")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func triggerStardustAnimation() {
        // Reset state
        showStardustIndicator = false
        stardustPoints = 0
        
        // Start animation sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            stardustPoints = 25
            withAnimation(.easeInOut(duration: 0.5)) {
                showStardustIndicator = true
            }
        }
        
        // Reset after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showStardustIndicator = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                stardustPoints = 0
            }
        }
    }
}



#Preview {
    VStack(spacing: 20) {
//        Text("Full Profile Badge")
//            .foregroundColor(.white)
//        ZodiacProfileBadge()
//        
//        Text("Profile Badge with Stardust (100 - 12 o'clock)")
//            .foregroundColor(.white)
//        ZodiacProfileBadgeWithStardust(
//            zodiacImage: Image("Aries"),
//            stardustPoints: 100
//        )
//        
//        Text("Profile Badge with Stardust (50 - 6 o'clock)")
//            .foregroundColor(.white)
//        ZodiacProfileBadgeWithStardust(
//            zodiacImage: Image("Taurus"),
//            stardustPoints: 75
//        )
//        
//        Text("Profile Badge with Stardust (25 - 3 o'clock)")
//            .foregroundColor(.white)
//        ZodiacProfileBadgeWithStardust(
//            zodiacImage: Image("Gemini"),
//            stardustPoints: 25
//        )
//        
//        Text("White Profile Badge with Stardust (75 - 9 o'clock)")
//            .foregroundColor(.white)
//        ZodiacProfileBadgeWhiteWithStardust(
//            zodiacImage: Image("Cancer"),
//            stardustPoints: 235
//        )
        
//        Text("Custom Frame Sizes")
//            .foregroundColor(.white)
//        HStack(spacing: 20) {
//            ZodiacProfileBadgeWithStardust(
//                zodiacImage: Image("Leo"),
//                stardustPoints: 50,
//                frameSize: 120
//            )
//            
//            ZodiacProfileBadgeWithStardust(
//                zodiacImage: Image("Virgo"),
//                stardustPoints: 150,
//                frameSize: 240
//            )
//            
//            ZodiacProfileBadgeWhiteWithStardust(
//                zodiacImage: Image("Libra"),
//                stardustPoints: 200,
//                frameSize: 90
//            )
//        }
        
//        Text("Partial Profile Widget")
//            .foregroundColor(.white)
//        PartialProfileWidget()
//        
//        Text("Compact Profile Widget")
//            .foregroundColor(.white)
//        CompactProfileWidget()
        
        Text("Cosmic Badge Effects")
            .foregroundColor(.white)
        CosmicBadgeEffects(
            badgeScale: 1.0,
            badgeRotation: 0,
            cosmicGlowOpacity: 1.0,
            nebulaOpacity: 1.0,
            starFieldOpacity: 1.0,
            cosmicParticlesOpacity: 1.0,
            sparkleOpacity: 1.0,
            currentProfileImage: "logo"
        )
        
        Text("Spinning Stardust Animation Demo")
            .foregroundColor(.white)
            .font(.headline)
        
        SpinningStardustDemo()
    }
    .background(Color.black)
    .padding()
}
