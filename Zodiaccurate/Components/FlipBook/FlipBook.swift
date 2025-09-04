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
    @State private var flipBookOffset: CGFloat = 0
    @State private var isVisible: Bool = true
    
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
                                    FlipBookPage(
                                        card: card, 
                                        index: index,
                                        canNavigateLeft: index > 0,
                                        canNavigateRight: index < pageCount - 1,
                                        onNavigateLeft: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentIndex = index - 1
                                            }
                                        },
                                        onNavigateRight: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentIndex = index + 1
                                            }
                                        }
                                    )
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
                                // Notify other components about the index change
                                NotificationCenter.default.post(
                                    name: .flipBookIndexChanged,
                                    object: nil,
                                    userInfo: ["index": newIndex]
                                )
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
//                    print("📏 FlipBook: Container height: \(geometry.size.height), Screen height: \(screenHeight), UpdateCard state: \(updateCardState), Available height: \(availableHeight)")
                    return availableHeight
                }())
                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: updateCardState)
            }
            .frame(maxWidth: .infinity)
            .offset(y: flipBookOffset)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateCardStateChanged)) { notification in
            if let state = notification.userInfo?["state"] as? UpdateCardState {
                updateCardState = state
                print("🔄 FlipBook: UpdateCard state changed to \(state)")
                
                // Animate FlipBook position and visibility based on UpdateCard state
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                    switch state {
                    case .minimized:
                        flipBookOffset = 0 // Return to original position when minimized
                        isVisible = true // Keep visible when minimized
                        print("🔄 FlipBook: UpdateCard minimized - FlipBook visible")
                    case .dismissed:
                        flipBookOffset = 0 // Return to normal position
                        isVisible = true // Ensure FlipBook is visible when UpdateCard is dismissed
                        print("🔄 FlipBook: UpdateCard dismissed - ensuring FlipBook is visible")
                    case .expanded, .expandedWithTutorial, .expandedWithKeyboard:
                        flipBookOffset = -100 // Move up more when expanded
                        isVisible = false // Hide when UpdateCard is expanded
                        print("🔄 FlipBook: UpdateCard expanded - FlipBook hidden")
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .flipBookCollapsed)) { _ in
            // Return FlipBook to original position when collapsed
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                flipBookOffset = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateCardDismissed)) { _ in
            // Ensure FlipBook is visible when UpdateCard is dismissed
            print("🔄 FlipBook: Received updateCardDismissed notification - ensuring visibility")
            withAnimation(.easeInOut(duration: 0.3)) {
                updateCardState = .dismissed
                flipBookOffset = 0
                isVisible = true
            }
        }
        .onAppear {
            // Post initial index when FlipBook appears
            NotificationCenter.default.post(
                name: .flipBookIndexChanged,
                object: nil,
                userInfo: ["index": currentIndex]
            )
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
    let canNavigateLeft: Bool
    let canNavigateRight: Bool
    let onNavigateLeft: (() -> Void)?
    let onNavigateRight: (() -> Void)?
    
    var body: some View {
        VStack {
            FlipBookCard(
                horoscope: card.horoscope,
                isLoading: card.isLoading,
                onCardTap: card.onCardTap,
                showStartButton: card.showStartButton,
                onStartButtonTap: card.onStartButtonTap,
                canNavigateLeft: canNavigateLeft,
                canNavigateRight: canNavigateRight,
                onNavigateLeft: onNavigateLeft,
                onNavigateRight: onNavigateRight
            )
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

