//
//  ZodiacAuroraBackground.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import SwiftUI

/// A cosmic aurora background with celestial elements for zodiac-themed screens
struct ZodiacAuroraBackground: View {
    var body: some View {
        ZStack {
            // Cosmic background
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A0B2E"), location: 0.0),
                    .init(color: Color(hex: "0F051A"), location: 0.7),
                    .init(color: Color.black, location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)

            // Vignette overlay
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.6),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .blendMode(.multiply)
            .allowsHitTesting(false)

            // Celestial bodies
            GeometryReader { geo in
                CelestialSystem()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    .position(x: geo.size.width / 5, y: geo.size.height / 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)

            // Orange overlay
            Color.backgroundPrimary.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZodiacAuroraBackground()
        .ignoresSafeArea()
}

