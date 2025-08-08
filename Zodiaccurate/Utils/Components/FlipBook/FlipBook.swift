//
//  FlipBook.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/7/25.
//

import SwiftUI

struct FlipBook: View {
    @State private var currentIndex: Int = 0
    private let pageCount: Int
    private let pageSpacing: CGFloat = 20
    private let pages: [FlipBookPageContent]
    
    init(pages: [FlipBookPageContent] = []) {
        self.pages = pages.isEmpty ? FlipBook.defaultPages : pages
        self.pageCount = self.pages.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: pageSpacing) {
                            // Add leading spacer for centering
                            Spacer()
                                .frame(width: (geometry.size.width - (geometry.size.width - 40)) / 2 - pageSpacing)
                            
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, pageContent in
                            FlipBookPage(pageContent: pageContent, index: index)
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

// MARK: - FlipBook Page Content Structure
struct FlipBookPageContent {
    let title: String
    let subtitle: String
    let color: Color
    let zodiacCard: ZodiacCard?
    
    init(title: String, subtitle: String, color: Color, zodiacCard: ZodiacCard? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.zodiacCard = zodiacCard
    }
}

// MARK: - Default Pages
extension FlipBook {
    static let defaultPages: [FlipBookPageContent] = [
        FlipBookPageContent(
            title: "Daily Horoscope",
            subtitle: "Discover what the stars have in store for you today",
            color: Color.accentPurple
        ),
        FlipBookPageContent(
            title: "Weekly Forecast",
            subtitle: "Plan your week with cosmic guidance",
            color: Color.accentBlue
        ),
        FlipBookPageContent(
            title: "Monthly Insights",
            subtitle: "Deep dive into your monthly astrological journey",
            color: Color.accentGold
        )
    ]
}

struct FlipBookPage: View {
    let pageContent: FlipBookPageContent
    let index: Int
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text(pageContent.title)
                .font(.dmSansSemibold(size: 24))
                .foregroundColor(.whiteCustom)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            // Subtitle
            Text(pageContent.subtitle)
                .font(.dmSansMedium(size: 16))
                .foregroundColor(.whiteCustom.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // ZodiacCard if provided
            if let zodiacCard = pageContent.zodiacCard {
                ScrollView {
                    zodiacCard
                        .padding(.horizontal, 10)
                }
                .frame(maxHeight: 200)
            }
            
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
                            gradient: Gradient(colors: [pageContent.color, pageContent.color.opacity(0.7)]),
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
                        .stroke(pageContent.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: pageContent.color.opacity(0.2), radius: 10, x: 0, y: 5)
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
            // Example with custom pages including ZodiacCard
            FlipBook(pages: [
                FlipBookPageContent(
                    title: "Daily Horoscope",
                    subtitle: "Discover what the stars have in store for you today",
                    color: Color.accentPurple,
                    zodiacCard: ZodiacCard(
                        title: "Today's Reading",
                        content: "The stars align in your favor today. Mercury's influence brings clarity to your thoughts, while Venus enhances your relationships. Focus on communication and trust your intuition."
                    )
                ),
                FlipBookPageContent(
                    title: "Weekly Forecast",
                    subtitle: "Plan your week with cosmic guidance",
                    color: Color.accentBlue,
                    zodiacCard: ZodiacCard(
                        title: "This Week's Energy",
                        content: "A powerful week ahead with Jupiter's expansion energy. New opportunities arise mid-week. Stay open to unexpected connections and trust the universe's timing."
                    )
                ),
                FlipBookPageContent(
                    title: "Monthly Insights",
                    subtitle: "Deep dive into your monthly astrological journey",
                    color: Color.accentGold
                )
            ])
            
            Spacer()
            
            // Default FlipBook for comparison
            FlipBook()
        }
    }
}

