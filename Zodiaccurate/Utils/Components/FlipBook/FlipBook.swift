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
    
    // Card height constants
    private let cardHeightMinimized: CGFloat = 0.05
    private let cardHeightNormal: CGFloat = 0.5
    private let cardHeightExpanded: CGFloat = 0.8
    
    private let pageCount: Int
    private let pageSpacing: CGFloat = 20
    private let pages: [FlipBookCard]
    private let onMoveToTop: (() -> Void)?
    
    // External state control
    @Binding var cardHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var isMinimized: Bool
    
    init(pages: [FlipBookCard] = [], onMoveToTop: (() -> Void)? = nil, cardHeight: Binding<CGFloat>, isExpanded: Binding<Bool>, isMinimized: Binding<Bool>) {
        self.pages = pages.isEmpty ? FlipBook.defaultCards : pages
        self.pageCount = self.pages.count
        self.onMoveToTop = onMoveToTop
        self._cardHeight = cardHeight
        self._isExpanded = isExpanded
        self._isMinimized = isMinimized
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Page Indicator (moved to top)
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
                                    FlipBookPage(card: card, index: index, onCardTap: onMoveToTop)
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
                    .frame(height: geometry.size.height * cardHeight)
                }
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * (isMinimized ? cardHeightMinimized : cardHeight))
//                .background(
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(Color.bubbleMist.opacity(0.9))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 24)
//                                .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
//                        )
//                )
//                .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let translation = value.translation.height
                            let screenHeight = geometry.size.height
                            
                            if isExpanded {
                                // When expanded, allow normal drag behavior
                                let heightDifference = (cardHeightExpanded - cardHeightNormal) * screenHeight
                                let maxDrag = heightDifference * 0.3
                                dragOffset = max(-maxDrag, min(translation, maxDrag))
                            } else {
                                // When in normal state, allow swiping up to expand or down to minimize
                                let heightDifference = (cardHeightNormal - cardHeightMinimized) * screenHeight
                                let maxDrag = heightDifference * 0.5
                                dragOffset = max(-maxDrag, min(translation, maxDrag))
                            }
                        }
                        .onEnded { value in
                            let translation = value.translation.height
                            let velocity = value.velocity.height
                            let screenHeight = geometry.size.height
                            
                            if isExpanded {
                                // When expanded, determine if we should collapse
                                let shouldCollapse = translation > 50 || velocity > 500
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                    if shouldCollapse {
                                        cardHeight = cardHeightNormal
                                        isExpanded = false
                                        isMinimized = false
                                    }
                                    dragOffset = 0
                                }
                            } else {
                                // When in normal state, determine if we should expand or minimize
                                let shouldExpand = translation < -50 || velocity < -500
                                let shouldMinimize = translation > 30 || velocity > 300
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                    if shouldExpand && !isExpanded {
                                        cardHeight = cardHeightExpanded
                                        isExpanded = true
                                        isMinimized = false
                                    } else if shouldMinimize && !isMinimized {
                                        cardHeight = cardHeightMinimized
                                        isMinimized = true
                                        isExpanded = false
                                    }
                                    dragOffset = 0
                                }
                            }
                            
                            isDragging = false
                        }
                )
                .onTapGesture {
                    if isExpanded {
                        // Tap to collapse from expanded state
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            cardHeight = cardHeightNormal
                            isExpanded = false
                            isMinimized = false
                            dragOffset = 0
                        }
                    } else if isMinimized {
                        // Tap to return to normal state from minimized
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            cardHeight = cardHeightNormal
                            isMinimized = false
                            isExpanded = false
                            dragOffset = 0
                        }
                    } else {
                        // Tap to expand from normal state
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            cardHeight = cardHeightExpanded
                            isExpanded = true
                            isMinimized = false
                            dragOffset = 0
                        }
                    }
                }
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
    let onCardTap: (() -> Void)?
    
    var body: some View {
        VStack {
            card
                .padding(.horizontal, 10)
                .onTapGesture {
                    onCardTap?()
                }
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
                ],
                cardHeight: .constant(0.5),
                isExpanded: .constant(false),
                isMinimized: .constant(false)
            )
            
            Spacer()
            
            // Default FlipBook for comparison
            FlipBook(
                cardHeight: .constant(0.5),
                isExpanded: .constant(false),
                isMinimized: .constant(false)
            )
        }
    }
}

