//
//  FlipBook.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/7/25.
//

import SwiftUI

struct FlipBook: View {
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    private let pageCount = 3
    private let pageSpacing: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: pageSpacing) {
                ForEach(0..<pageCount, id: \.self) { index in
                    FlipBookPage(index: index)
                        .frame(width: geometry.size.width - 40)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                        .opacity(currentIndex == index ? 1.0 : 0.7)
                }
            }
            .offset(x: -CGFloat(currentIndex) * (geometry.size.width - 40 + pageSpacing) + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold = geometry.size.width * 0.3
                        let velocity = value.predictedEndLocation.x - value.location.x
                        
                        if abs(value.translation.width) > threshold || abs(velocity) > 500 {
                            if value.translation.width > 0 && currentIndex > 0 {
                                currentIndex -= 1
                            } else if value.translation.width < 0 && currentIndex < pageCount - 1 {
                                currentIndex += 1
                            }
                        }
                        
                        dragOffset = 0
                    }
            )
        }
        .frame(height: 300)
        .clipped()
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
        VStack {
            FlipBook()
            FlipBookPageIndicator(currentIndex: 0, pageCount: 3)
        }
    }
}

