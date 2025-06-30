import SwiftUI

// MARK: - Solar Flare Background Effect

/// Custom animated shape for solar flare effects
struct SolarFlareShape: Shape {
    var animatableData: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width
        let height = rect.height
        
        // Create flame-like shape that flows horizontally
        let flamePoints = 16
        let baseWidth = width * 0.6
        let baseHeight = height * 0.8
        
        // Start from the bottom center (fire base)
        let startPoint = CGPoint(x: center.x, y: center.y + baseHeight * 0.4)
        path.move(to: startPoint)
        
        // Create the right side of the flame (flowing right)
        for i in 0..<flamePoints {
            let progress = Double(i) / Double(flamePoints - 1)
            let x = center.x + (baseWidth * 0.5) * progress
            let y = center.y + baseHeight * 0.4 - (baseHeight * 0.8) * progress
            
            // Add flame-like variation
            let flameVariation = sin(progress * .pi * 3 + animatableData * 2) * 0.3
            let widthVariation = sin(progress * .pi * 2 + animatableData * 1.5) * 0.2
            let adjustedX = x + flameVariation * baseWidth * 0.1
            let adjustedY = y + widthVariation * baseHeight * 0.1
            
            path.addLine(to: CGPoint(x: adjustedX, y: adjustedY))
        }
        
        // Create the left side of the flame (flowing left)
        for i in (0..<flamePoints).reversed() {
            let progress = Double(i) / Double(flamePoints - 1)
            let x = center.x - (baseWidth * 0.5) * progress
            let y = center.y + baseHeight * 0.4 - (baseHeight * 0.8) * progress
            
            // Add flame-like variation
            let flameVariation = sin(progress * .pi * 3 + animatableData * 2) * 0.3
            let widthVariation = sin(progress * .pi * 2 + animatableData * 1.5) * 0.2
            let adjustedX = x - flameVariation * baseWidth * 0.1
            let adjustedY = y + widthVariation * baseHeight * 0.1
            
            path.addLine(to: CGPoint(x: adjustedX, y: adjustedY))
        }
        
        path.closeSubpath()
        return path
    }
}

/// Individual solar flare layer with custom animation
struct SolarFlareLayer: View {
    let size: CGFloat
    let rotationSpeed: Double
    let scaleSpeed: Double
    let opacity: Double
    let color: Color
    let delay: Double
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacityValue: Double = 0
    @State private var flameOffset: CGFloat = 0
    
    var body: some View {
        SolarFlareShape(animatableData: rotation)
            .fill(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: color.opacity(opacity), location: 0.0),
                        .init(color: color.opacity(opacity * 0.8), location: 0.3),
                        .init(color: color.opacity(opacity * 0.5), location: 0.6),
                        .init(color: color.opacity(opacity * 0.2), location: 0.8),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacityValue)
            .offset(x: flameOffset, y: 0)
            .blur(radius: 6)
            .blendMode(.screen)
            .onAppear {
                // Horizontal flame movement
                withAnimation(
                    .easeInOut(duration: rotationSpeed)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    flameOffset = size * 0.1
                }
                
                // Flame shape animation
                withAnimation(
                    .easeInOut(duration: rotationSpeed * 0.8)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    rotation = 2 * .pi
                }
                
                // Flame intensity pulsing
                withAnimation(
                    .easeInOut(duration: scaleSpeed)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    scale = 1.1
                }
                
                // Opacity breathing effect
                withAnimation(
                    .easeInOut(duration: scaleSpeed * 0.7)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    opacityValue = opacity
                }
            }
    }
}

/// Complete solar flare background effect
struct SolarFlareBackground: View {
    let size: CGFloat
    
    // Solar flare color palette
    private let flareColors: [Color] = [
        Color(hex: "FF4500"), // Deep orange
        Color(hex: "FFD700"), // Bright yellow
        Color(hex: "FF6347"), // Warm red
        Color(hex: "FFA500"), // Light orange
        Color(hex: "FFFFE0")  // Pale yellow
    ]
    
    var body: some View {
        ZStack {
            // Base layer - slow rotation and scaling
            SolarFlareLayer(
                size: size,
                rotationSpeed: 8.0,
                scaleSpeed: 6.0,
                opacity: 0.6,
                color: flareColors[0],
                delay: 0.0
            )
            
            // Middle layer - medium rotation in opposite direction
            SolarFlareLayer(
                size: size * 0.8,
                rotationSpeed: 5.0,
                scaleSpeed: 4.0,
                opacity: 0.5,
                color: flareColors[1],
                delay: 1.0
            )
            
            // Top layer - faster pulsing for active flare tips
            SolarFlareLayer(
                size: size * 0.6,
                rotationSpeed: 3.0,
                scaleSpeed: 2.5,
                opacity: 0.7,
                color: flareColors[2],
                delay: 2.0
            )
            
            // Additional accent layers for complexity
            SolarFlareLayer(
                size: size * 0.9,
                rotationSpeed: 7.0,
                scaleSpeed: 5.0,
                opacity: 0.4,
                color: flareColors[3],
                delay: 0.5
            )
            
            SolarFlareLayer(
                size: size * 0.7,
                rotationSpeed: 4.5,
                scaleSpeed: 3.5,
                opacity: 0.3,
                color: flareColors[4],
                delay: 1.5
            )
        }
        .drawingGroup() // Optimize for performance
    }
}

/// Profile badge with integrated solar flare background
struct ProfileBadgeWithFlare: View {
    let profileImage: Image
    let zodiacImage: Image
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Solar flare background
            SolarFlareBackground(size: size)
                .frame(width: size, height: size)
            
            // Profile badge circle with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.6, blue: 0.2), // orange
                            Color(red: 0.7, green: 0.2, blue: 0.7), // purple
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color.purple.opacity(0.5), radius: 40, x: 0, y: 0)
            
            // Zodiac image
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.67, height: size * 0.67)
                .clipShape(Circle())
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Enhanced Zodiac Profile Badge with Solar Flare

/// Enhanced version of ZodiacProfileBadge with solar flare effect
struct EnhancedZodiacProfileBadge: View {
    var zodiacImage: Image = Image("Capricorn")
    let size: CGFloat = 180
    
    var body: some View {
        ProfileBadgeWithFlare(
            profileImage: Image("logo"),
            zodiacImage: zodiacImage,
            size: size
        )
        .padding(.top, 24)
        .padding(.leading, 16)
    }
}

// MARK: - Shooting Stars Components
struct ShootingStarsLayer: View {
    @State private var shootingStars: [ShootingStarData] = []
    let maxStars = 7
    let animationDuration: Double = 1.2

    var body: some View {
        ZStack {
            ForEach(shootingStars) { star in
                ShootingStar(
                    start: star.start,
                    end: star.end,
                    angle: star.angle,
                    opacity: star.opacity,
                    duration: animationDuration
                )
            }
        }
        .onAppear {
            spawnStar()
        }
    }

    private func spawnStar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
            if shootingStars.count < maxStars {
                let width = UIScreen.main.bounds.width
                let height = UIScreen.main.bounds.height
                
                // Randomly choose which side to start from (top or left)
                let startFromTop = Bool.random()
                
                let startX: CGFloat
                let startY: CGFloat
                let angle: Double
                
                if startFromTop {
                    // Start from top, slightly off-screen
                    startX = CGFloat.random(in: -100...width + 100)
                    startY = -50
                    // Angle downward (between -60 and -30 degrees)
                    angle = Double.random(in: -60...(-30))
                } else {
                    // Start from left side, slightly off-screen
                    startX = -50
                    startY = CGFloat.random(in: -100...height + 100)
                    // Angle rightward (between -30 and 30 degrees)
                    angle = Double.random(in: -30...30)
                }
                
                // Length to ensure it crosses the screen
                let length = max(width, height) * 1.5
                let dx = cos(angle * .pi / 180) * length
                let dy = sin(angle * .pi / 180) * length
                let endX = startX + dx
                let endY = startY + dy
                
                let star = ShootingStarData(
                    id: UUID(),
                    start: CGPoint(x: startX, y: startY),
                    end: CGPoint(x: endX, y: endY),
                    angle: angle,
                    opacity: Double.random(in: 0.8...1.0)
                )
                shootingStars.append(star)
                
                // Remove after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    shootingStars.removeAll { $0.id == star.id }
                }
            }
            spawnStar()
        }
    }
}

struct ShootingStarData: Identifiable {
    let id: UUID
    let start: CGPoint
    let end: CGPoint
    let angle: Double
    let opacity: Double
}

struct ShootingStar: View {
    let start: CGPoint
    let end: CGPoint
    let angle: Double
    let opacity: Double
    let duration: Double
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            // Bright head
            Circle()
                .fill(Color.white)
                .frame(width: 2, height: 2)
                .blur(radius: 0.5)
                .offset(x: lerp(start.x, end.x, progress) - UIScreen.main.bounds.width / 2,
                        y: lerp(start.y, end.y, progress) - UIScreen.main.bounds.height / 2)
            
            // Glowing tail
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.0), location: 0.0),
                            .init(color: Color.white.opacity(0.4), location: 0.7),
                            .init(color: Color.white.opacity(0.8), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 250, height: 1.5) // Increased length for more dramatic effect
                .rotationEffect(.degrees(angle))
                .offset(x: lerp(start.x, end.x, progress) - UIScreen.main.bounds.width / 2,
                        y: lerp(start.y, end.y, progress) - UIScreen.main.bounds.height / 2)
                .blur(radius: 0.5)
        }
        .onAppear {
            withAnimation(.easeOut(duration: duration)) {
                progress = 1.0
            }
        }
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}

// MARK: - Settings Button with Circular Menu

/// Settings button with circular menu animation
struct SettingsButtonWithMenu: View {
    @Binding var isMenuOpen: Bool
    @State private var isAnimatingMenu = false
    @State private var gearRotation: Double = 0
    @State private var menuScale: CGFloat = 0
    @State private var menuOpacity: Double = 0
    @State private var profileItemScale: CGFloat = 0
    @State private var logoutItemScale: CGFloat = 0
    
    let onProfileTap: () -> Void
    let onLogoutTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay to close menu when tapped outside
            if isMenuOpen {
                Color.black.opacity(0.001) // Nearly transparent but tappable
                    .onTapGesture {
                        closeMenu()
                    }
            }
            
            // Main settings button
            Button(action: {
                if isMenuOpen {
                    closeMenu()
                } else {
                    openMenu()
                }
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.indigo, Color.sapphire]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    // Gear icon
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(gearRotation))
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
            }
            .frame(width: 40, height: 40)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Circular menu
            if isAnimatingMenu {
                ZStack {
                    // Profile menu item (10 o'clock position)
                    MenuItem(
                        icon: "person.circle",
                        title: "Profile",
                        position: .topLeading,
                        scale: profileItemScale,
                        action: {
                            onProfileTap()
                            closeMenu()
                        }
                    )
                    
                    // Logout menu item (2 o'clock position)
                    MenuItem(
                        icon: "arrow.right.square",
                        title: "Logout",
                        position: .topTrailing,
                        scale: logoutItemScale,
                        action: {
                            onLogoutTap()
                            closeMenu()
                        }
                    )
                }
                .scaleEffect(menuScale)
                .opacity(menuOpacity)
            }
        }
    }
    
    private func openMenu() {
        isMenuOpen = true
        isAnimatingMenu = true
        
        // Gear rotation animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            gearRotation = 30
        }
        
        // Menu appearance animation
        withAnimation(.easeInOut(duration: 0.4)) {
            menuScale = 1
            menuOpacity = 1
        }
        
        // Staggered menu items animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
            profileItemScale = 1
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.2)) {
            logoutItemScale = 1
        }
    }
    
    private func closeMenu() {
        // Immediately hide the blur/overlay
        isMenuOpen = false

        // Animate out the menu
        withAnimation(.easeInOut(duration: 0.2)) {
            profileItemScale = 0
            logoutItemScale = 0
        }

        withAnimation(.easeInOut(duration: 0.3).delay(0.1)) {
            menuScale = 0
            menuOpacity = 0
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.2)) {
            gearRotation = 0
        }

        // Remove the menu after the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAnimatingMenu = false
        }
    }
}

/// Individual menu item component
struct MenuItem: View {
    let icon: String
    let title: String
    let position: Alignment
    let scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(scale)
        .position(getPosition())
    }
    
    private func getPosition() -> CGPoint {
        let radius: CGFloat = 80
        switch position {
        case .topLeading:
            return CGPoint(x: -radius, y: -radius)
        case .topTrailing:
            return CGPoint(x: radius, y: -radius)
        default:
            return CGPoint(x: 0, y: 0)
        }
    }
}

// MARK: - Preview
struct SettingsButtonWithMenu_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            SettingsButtonWithMenu(
                isMenuOpen: .constant(false),
                onProfileTap: { print("Profile tapped") },
                onLogoutTap: { print("Logout tapped") }
            )
        }
    }
} 