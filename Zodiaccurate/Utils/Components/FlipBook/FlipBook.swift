//
//  FlipBook.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/7/25.
//

import SwiftUI

struct FlipBook: View {
    @State private var currentIndex: Int = 0
    private let pageCount = 3
    private let pageSpacing: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: pageSpacing) {
                            // Add leading spacer for centering
                            Spacer()
                                .frame(width: (geometry.size.width - (geometry.size.width - 40)) / 2 - pageSpacing)
                            
                            ForEach(0..<pageCount, id: \.self) { index in
                                FlipBookPage(index: index)
                                    .frame(width: geometry.size.width - 40)
                                    .id(index)
                                    .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                            .opacity(phase.isIdentity ? 1.0 : 0.7)
                                    }
                            }
                            
                            // Add trailing spacer for centering
                            Spacer()
                                .frame(width: (geometry.size.width - (geometry.size.width - 40)) / 2 - pageSpacing)
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: .init(get: { currentIndex }, set: { newPosition in
                        if let newIndex = newPosition {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex = newIndex
                            }
                        }
                    }))
                }
            }
            .frame(height: 300)
            
            // Page Indicator
            FlipBookPageIndicator(currentIndex: currentIndex, pageCount: pageCount)
                .padding(.top, 16)
        }
    }
}

struct FlipBookPage: View {
    let index: Int
    
    private var pageData: (title: String, subtitle: String, color: Color, icon: String) {
        switch index {
        case 0:
            return ("Daily Horoscope", "Discover what the stars have in store for you today", Color.accentPurple, "🌟")
        case 1:
            return ("Weekly Forecast", "Plan your week with cosmic guidance", Color.accentBlue, "📅")
        case 2:
            return ("Monthly Insights", "Deep dive into your monthly astrological journey", Color.accentGold, "✨")
        default:
            return ("", "", Color.clear, "")
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Text(pageData.icon)
                .font(.system(size: 48))
                .padding(.top, 20)
            
            // Title
            Text(pageData.title)
                .font(.dmSansSemibold(size: 24))
                .foregroundColor(.whiteCustom)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(pageData.subtitle)
                .font(.dmSansMedium(size: 16))
                .foregroundColor(.whiteCustom.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Action Button
            Button(action: {
                // Handle page-specific action
                print("Tapped page \(index)")
            }) {
                Text("Explore")
                    .font(.dmSansSemibold(size: 16))
                    .foregroundColor(.whiteCustom)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [pageData.color, pageData.color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundSecondary.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(pageData.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: pageData.color.opacity(0.2), radius: 10, x: 0, y: 5)
    }
        
}

// Page Indicator
struct FlipBookPageIndicator: View {
    let currentIndex: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.accentGold : Color.whiteCustom.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        FlipBook()
    }
}

