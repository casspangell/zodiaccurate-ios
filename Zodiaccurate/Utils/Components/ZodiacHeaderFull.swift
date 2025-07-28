//
//  ZodiacHeaderFull.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

/// A reusable zodiac-themed header component with animated profile badge
struct ZodiacHeaderFull: View {
    // MARK: - Properties
    let profileImage: String
    let badgeScale: CGFloat
    let badgeRotation: Double
    let cosmicGlowOpacity: Double
    let nebulaOpacity: Double
    let starFieldOpacity: Double
    let cosmicParticlesOpacity: Double
    let sparkleOpacity: Double
    let stardustPoints: Int
    let badgeSize: CGFloat?
    
    // MARK: - Convenience Functions
    /// Returns the height of the profile badge
    static func profileBadgeHeight() -> CGFloat {
        return UIScreen.main.bounds.width * 0.5
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
        sparkleOpacity: Double = 0,
        stardustPoints: Int = 0,
        badgeSize: CGFloat? = nil
    ) {
        self.profileImage = profileImage
        self.badgeScale = badgeScale
        self.badgeRotation = badgeRotation
        self.cosmicGlowOpacity = cosmicGlowOpacity
        self.nebulaOpacity = nebulaOpacity
        self.starFieldOpacity = starFieldOpacity
        self.cosmicParticlesOpacity = cosmicParticlesOpacity
        self.sparkleOpacity = sparkleOpacity
        self.stardustPoints = stardustPoints
        self.badgeSize = badgeSize
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.deepBlue.opacity(1.0))
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .ignoresSafeArea(.all, edges: .top)
            
            // Fixed Header Content
            VStack(spacing: 0) {
                ZStack {
                    ZodiacProfileBadgeWithStardust(
                        zodiacImage: Image(profileImage),
                        stardustPoints: stardustPoints,
                        frameSize: ZodiacHeaderFull.profileBadgeHeight()
                    )
                    .scaleEffect(badgeScale)
                    .rotationEffect(.degrees(badgeRotation))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeScale)
                    .animation(Animation.easeInOut(duration: 0.8), value: badgeRotation)
                    .background(Color.red)
                }
                .frame(width: ZodiacHeaderFull.profileBadgeHeight(), height: ZodiacHeaderFull.profileBadgeHeight())
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .frame(maxWidth: .infinity)
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
        
        ZodiacHeaderFull(
            profileImage: "logo",
            badgeScale: 1.0,
            badgeRotation: 0,
            cosmicGlowOpacity: 0.5,
            nebulaOpacity: 0.3,
            starFieldOpacity: 0.4,
            cosmicParticlesOpacity: 0.6,
            sparkleOpacity: 0.8,
            badgeSize: nil
        )
    }
}

