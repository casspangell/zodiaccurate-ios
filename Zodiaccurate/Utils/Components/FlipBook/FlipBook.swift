//
//  FlipBook.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/7/25.
//

import SwiftUI

struct FlipBook: View {
    @State private var currentIndex: Int = 0
    @State private var updateCardState: UpdateCardState = .dismissed
    
    private let pageCount: Int
    private let pageSpacing: CGFloat = 20
    private let pages: [FlipBookCard]
    
    init(pages: [FlipBookCard] = []) {
        self.pages = pages.isEmpty ? FlipBook.defaultCards : pages
        self.pageCount = self.pages.count
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Page Indicator
                FlipBookPageIndicator(currentIndex: currentIndex, pageCount: pageCount)
                    .padding(.bottom, 16)
                    .padding(.top, 30)
                
                GeometryReader { geometry in
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: pageSpacing) {
                                // Add leading spacer for centering
                                Spacer()
                                    .frame(width: (geometry.size.width - (geometry.size.width - 40)) / 2 - pageSpacing)
                                
                                ForEach(Array(pages.enumerated()), id: \.offset) { index, card in
                                    FlipBookPage(card: card, index: index)
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
                .frame(height: {
                    let screenHeight = UIScreen.main.bounds.height
                    let availableHeight = getFlipBookCardAvailableHeight(
                        screenHeight: screenHeight,
                        updateCardState: updateCardState
                    )
                    print("📏 FlipBook: Container height: \(geometry.size.height), Screen height: \(screenHeight), UpdateCard state: \(updateCardState), Available height: \(availableHeight)")
                    return availableHeight
                }())
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateCardStateChanged)) { notification in
            if let state = notification.userInfo?["state"] as? UpdateCardState {
                updateCardState = state
            }
        }
    }
}

// MARK: - Default Cards
extension FlipBook {
    static let defaultCards: [FlipBookCard] = [
        FlipBookCard(
            title: "Daily Horoscope",
            content: "Discover what the stars have in store for you today"
        ),
        FlipBookCard(
            title: "Weekly Forecast",
            content: "Plan your week with cosmic guidance"
        ),
        FlipBookCard(
            title: "Monthly Insights",
            content: "Deep dive into your monthly astrological journey"
        )
    ]
}

struct FlipBookPage: View {
    let card: FlipBookCard
    let index: Int
    
    var body: some View {
        VStack {
            card
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        VerticleAuroraBackgroundView()
        VStack {
            // Example with custom ZodiacCards
            FlipBook(
                pages: [
                    FlipBookCard(
                        title: "Today's Reading",
                        content: "The stars align in your favor today. Mercury's influence brings clarity to your thoughts, while Venus enhances your relationships. Focus on communication and trust your intuition."
                    ),
                    FlipBookCard(
                        title: "This Week's Energy",
                        content: "A powerful week ahead with Jupiter's expansion energy. New opportunities arise mid-week. Stay open to unexpected connections and trust the universe's timing."
                    ),
                    FlipBookCard(
                        title: "Monthly Overview",
                        content: "This month brings transformative energy with Pluto's influence. Embrace transformation and trust the process of growth."
                    )
                ]
            )
            
            Spacer()
            
            // Default FlipBook for comparison
            FlipBook()
        }
    }
}

