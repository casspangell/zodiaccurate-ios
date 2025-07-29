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
    let horoscopeDate: String
    let onSettingsTap: (() -> Void)?
    
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
        badgeSize: CGFloat? = nil,
        horoscopeDate: String = "Monday\nJanuary 5, 2025",
        onSettingsTap: (() -> Void)? = nil
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
        self.horoscopeDate = horoscopeDate
        self.onSettingsTap = onSettingsTap
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
//            VStack(spacing: 0) {
//                Rectangle()
//                    .fill(Color.blue)
//                    .frame(height: UIScreen.main.bounds.height * 0.3)
//                
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, alignment: .top)
//            .allowsHitTesting(false)
            
            // Fixed Header Content
            VStack(spacing: 0) {
                HStack {
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
                    }
                    .frame(width: ZodiacHeaderFull.profileBadgeHeight(), height: ZodiacHeaderFull.profileBadgeHeight() - 50) //don't know needed a buffer
                    
//                    Spacer()
                    
                    // Vertical stack of buttons
                    VStack(alignment: .trailing, spacing: 16) {
                        CircleIconButton(
                            systemName: "bell",
                            accessibilityLabel: "Notifications"
                        ) {
                            // Bell button action
                        }
                        
                        CircleIconButton(
                            systemName: "gearshape",
                            accessibilityLabel: "Settings"
                        ) {
                            onSettingsTap?()
                        }
                        
                        // Date display
                        HoroscopeDateText(date: horoscopeDate)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.trailing, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height/5, alignment: .top)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
        .zIndex(2)
        .onAppear {
            print("🎯 ZodiacHeaderFull: Header appeared")
            print("   🎭 Profile image: \(profileImage)")
            print("   📅 Horoscope date: \(horoscopeDate)")
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ZodiacHeaderFull(
            profileImage: "Leo",
            badgeScale: 1.0,
            badgeRotation: 0,
            cosmicGlowOpacity: 0.5,
            nebulaOpacity: 0.3,
            starFieldOpacity: 0.4,
            cosmicParticlesOpacity: 0.6,
            sparkleOpacity: 0.8,
            badgeSize: nil,
            horoscopeDate: "Monday\nJanuary 5, 2025",
            onSettingsTap: {
                // This would be implemented in the actual view that uses ZodiacHeaderFull
                // Example: showingSettings = true
                print("Settings button tapped")
            }
        )
    }
}

