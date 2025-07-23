import SwiftUI

/// A reusable zodiac-themed header component with animated profile badge
struct ZodiacHeader: View {
    // MARK: - Properties
    let profileImage: String
    let badgeScale: CGFloat
    let badgeRotation: Double
    let cosmicGlowOpacity: Double
    let nebulaOpacity: Double
    let starFieldOpacity: Double
    let cosmicParticlesOpacity: Double
    let sparkleOpacity: Double
    
    // MARK: - Convenience Functions
    /// Returns the height of the profile badge
    static func profileBadgeHeight() -> CGFloat {
        return 150
    }
    
    // MARK: - Computed Properties
    private var contentTopSpacing: CGFloat {
        return ZodiacHeader.profileBadgeHeight()
    }
    
    // MARK: - Initialization
    init(
        profileImage: String,
        badgeScale: CGFloat = 1.0,
        badgeRotation: Double = 0,
        cosmicGlowOpacity: Double = 0,
        nebulaOpacity: Double = 0,
        starFieldOpacity: Double = 0,
        cosmicParticlesOpacity: Double = 0,
        sparkleOpacity: Double = 0
    ) {
        self.profileImage = profileImage
        self.badgeScale = badgeScale
        self.badgeRotation = badgeRotation
        self.cosmicGlowOpacity = cosmicGlowOpacity
        self.nebulaOpacity = nebulaOpacity
        self.starFieldOpacity = starFieldOpacity
        self.cosmicParticlesOpacity = cosmicParticlesOpacity
        self.sparkleOpacity = sparkleOpacity
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Dark header background with gradient fade
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.deepBlue.opacity(1.0))
                    .frame(height: 75)
                
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.deepBlue.opacity(1.0), location: 0.0),
                        .init(color: Color.deepBlue.opacity(0.95), location: 0.1),
                        .init(color: Color.deepBlue.opacity(0.85), location: 0.25),
                        .init(color: Color.deepBlue.opacity(0.7), location: 0.4),
                        .init(color: Color.deepBlue.opacity(0.5), location: 0.55),
                        .init(color: Color.deepBlue.opacity(0.3), location: 0.7),
                        .init(color: Color.deepBlue.opacity(0.15), location: 0.85),
                        .init(color: Color.deepBlue.opacity(0.05), location: 0.95),
                        .init(color: Color.clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
            }
            .allowsHitTesting(false)
            .ignoresSafeArea(.all, edges: .top)
            
            // Fixed Header Content
            VStack(spacing: 8) {
                ZStack {
                    // Show original white circle for logo, ZodiacProfileBadge for zodiac signs
                    if profileImage == "logo" {
                        // Original simple white circle for logo state
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 130, height: 130)
                            .scaleEffect(badgeScale)
                            .rotationEffect(.degrees(badgeRotation))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeScale)
                            .animation(Animation.easeInOut(duration: 0.8), value: badgeRotation)
                        
                        Image(profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .id(profileImage)
                            .scaleEffect(badgeScale)
                            .rotationEffect(.degrees(badgeRotation))
                    } else {
                        // Use ZodiacProfileBadge for zodiac signs
                        ZodiacProfileBadgeWhite(zodiacImage: Image(profileImage))
                            .scaleEffect(badgeScale)
                            .rotationEffect(.degrees(badgeRotation))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeScale)
                            .animation(Animation.easeInOut(duration: 0.8), value: badgeRotation)
                    }
                }
                .frame(height: 150)
                .padding(.top, profileImage == "logo" ? 60 : 36) // Adjust padding based on badge type
                
                Text("")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 0)
            .background(
                GeometryReader { headerGeometry in
                    Color.clear
                        .preference(key: HeaderHeightPreferenceKey.self, value: headerGeometry.size.height)
                }
            )
        }
        .zIndex(2)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ZodiacHeader(
            profileImage: "logo",
            badgeScale: 1.0,
            badgeRotation: 0,
            cosmicGlowOpacity: 0.5,
            nebulaOpacity: 0.3,
            starFieldOpacity: 0.4,
            cosmicParticlesOpacity: 0.6,
            sparkleOpacity: 0.8
        )
    }
}

