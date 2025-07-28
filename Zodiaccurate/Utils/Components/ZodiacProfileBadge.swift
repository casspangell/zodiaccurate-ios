import SwiftUI

struct ZodiacProfileBadge: View {
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

// MARK: - Customizable Stardust Indicator
/// A customizable version of StardustIndicator that scales with the badge frame size
struct CustomStardustIndicator: View {
    let stardustPoints: Int
    let frameSize: CGFloat
    
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
            
            // Stardust points text
            Text("\(stardustPoints)")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .offset(offset)
        .animation(.easeInOut(duration: 0.5), value: stardustPoints)
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
                Text("+\(amount)")
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
    @State private var earningType: StardustTransactionType = .achievement
    
    var body: some View {
        ZStack {
            // Customizable ZodiacProfileBadge with frame size
            CustomZodiacProfileBadge(zodiacImage: zodiacImage, frameSize: frameSize)
            
            // Stardust indicator (scaled to frame size)
            if stardustPoints > 0 {
                CustomStardustIndicator(stardustPoints: stardustPoints, frameSize: frameSize)
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
    }
    
    private func triggerEarningAnimation(amount: Int, type: StardustTransactionType) {
        earningAmount = amount
        earningType = type
        showEarningAnimation = true
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
    @State private var earningType: StardustTransactionType = .achievement
    
    var body: some View {
        ZStack {
            // Customizable ZodiacProfileBadgeWhite with frame size
            CustomZodiacProfileBadgeWhite(zodiacImage: zodiacImage, frameSize: frameSize)
            
            // Stardust indicator (scaled to frame size)
            if stardustPoints > 0 {
                CustomStardustIndicator(stardustPoints: stardustPoints, frameSize: frameSize)
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
    }
    
    private func triggerEarningAnimation(amount: Int, type: StardustTransactionType) {
        earningAmount = amount
        earningType = type
        showEarningAnimation = true
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

// MARK: - Notification Extensions
extension Notification.Name {
    static let stardustEarned = Notification.Name("stardustEarned")
}

#Preview {
    VStack(spacing: 20) {
        Text("Full Profile Badge")
            .foregroundColor(.white)
        ZodiacProfileBadge()
        
        Text("Profile Badge with Stardust (100 - 12 o'clock)")
            .foregroundColor(.white)
        ZodiacProfileBadgeWithStardust(
            zodiacImage: Image("Aries"),
            stardustPoints: 100
        )
        
        Text("Profile Badge with Stardust (50 - 6 o'clock)")
            .foregroundColor(.white)
        ZodiacProfileBadgeWithStardust(
            zodiacImage: Image("Taurus"),
            stardustPoints: 75
        )
        
        Text("Profile Badge with Stardust (25 - 3 o'clock)")
            .foregroundColor(.white)
        ZodiacProfileBadgeWithStardust(
            zodiacImage: Image("Gemini"),
            stardustPoints: 25
        )
        
        Text("White Profile Badge with Stardust (75 - 9 o'clock)")
            .foregroundColor(.white)
        ZodiacProfileBadgeWhiteWithStardust(
            zodiacImage: Image("Cancer"),
            stardustPoints: 235
        )
        
        Text("Custom Frame Sizes")
            .foregroundColor(.white)
        HStack(spacing: 20) {
            ZodiacProfileBadgeWithStardust(
                zodiacImage: Image("Leo"),
                stardustPoints: 50,
                frameSize: 120
            )
            
            ZodiacProfileBadgeWithStardust(
                zodiacImage: Image("Virgo"),
                stardustPoints: 150,
                frameSize: 240
            )
            
            ZodiacProfileBadgeWhiteWithStardust(
                zodiacImage: Image("Libra"),
                stardustPoints: 200,
                frameSize: 90
            )
        }
        
        Text("Partial Profile Widget")
            .foregroundColor(.white)
        PartialProfileWidget()
        
        Text("Compact Profile Widget")
            .foregroundColor(.white)
        CompactProfileWidget()
        
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
    }
    .background(Color.black)
    .padding()
}
