import SwiftUI

struct FlipBookCard: View {
    let horoscope: Horoscope?
    let isLoading: Bool
    let onCardTap: (() -> Void)?
    @StateObject private var audioManager = AudioManager.shared
    
    // Internal state for expansion
    @State private var isExpanded = false
    @State private var cardHeight: CGFloat = 0.5
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // Card height constants
    private let cardHeightMinimized: CGFloat = 0.05
    private let cardHeightNormal: CGFloat = 0.5
    private let cardHeightExpanded: CGFloat = 0.8
    
    init(horoscope: Horoscope?, isLoading: Bool = false, onCardTap: (() -> Void)? = nil) {
        self.horoscope = horoscope
        self.isLoading = isLoading
        self.onCardTap = onCardTap
    }
    
    // Convenience initializer for backward compatibility
    init(title: String, content: String, onCardTap: (() -> Void)? = nil) {
        self.horoscope = Horoscope(title: title, message: content, key: "temp")
        self.isLoading = false
        self.onCardTap = onCardTap
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                if isLoading {
                    // Loading state with spinner
                    VStack {
                        Spacer()
                        ZodiacLoadingSpinner(size: .large)
                            .frame(width: 80, height: 80)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.bubbleMist.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                } else if let horoscope = horoscope {
                    // Content state
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        Text(horoscope.title)
                            .font(.dmSansSemibold(size: 24))
                            .foregroundColor(.whiteCustom)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        // Content
                        Text(horoscope.message)
                            .font(.dmSansMedium(size: 16))
                            .foregroundColor(.whiteCustom.opacity(0.8))
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
//                            .fill(Color.bubbleMist.opacity(0.8))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 16)
//                                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
//                            )
                    )
                    .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Audio Playback Button in upper right corner
                    if audioManager.hasAudio(for: horoscope) {
                        AudioControlButton(
                            isPlaying: audioManager.isPlaying && audioManager.currentAudioKey == horoscope.key,
                            onToggle: {
                                audioManager.toggleAudio(for: horoscope)
                            },
                            size: 44
                        )
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                        .zIndex(1)
                    }
                } else {
                    // Empty state (shouldn't happen with proper usage)
                    VStack {
                        Spacer()
                        Text("No content available")
                            .font(.dmSansMedium(size: 16))
                            .foregroundColor(.whiteCustom.opacity(0.6))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.bubbleMist.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
            .frame(height: geometry.size.height * cardHeight)
            .offset(y: isExpanded ? -geometry.safeAreaInsets.top : dragOffset)
            .contentShape(RoundedRectangle(cornerRadius: 16))
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
                                    // Post notification to reset spacing
                                    NotificationCenter.default.post(name: .flipBookCollapsed, object: nil)
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
                                } else if shouldMinimize {
                                    cardHeight = cardHeightMinimized
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
                        dragOffset = 0
                    }
                    // Post notification to reset spacing
                    NotificationCenter.default.post(name: .flipBookCollapsed, object: nil)
                } else {
                    // Tap to expand from normal state
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                        cardHeight = cardHeightExpanded
                        isExpanded = true
                        dragOffset = 0
                    }
                    // Post notification to move FlipBook to top
                    NotificationCenter.default.post(name: .flipBookMoveToTop, object: nil)
                }
                
                onCardTap?()
            }
        }
    }
}



#Preview {
    VStack(spacing: 20) {
        // Loading state
        FlipBookCard(horoscope: nil, isLoading: true)
            .frame(height: 300)
            .padding()
        
        // Loaded state
        FlipBookCard(
            horoscope: Horoscope(
                title: "Parenting",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                key: "preview"
            ),
            isLoading: false,
            onCardTap: {
                print("Card tapped - would move FlipBook to top")
            }
        )
        .frame(height: 300)
        .padding()
    }
    .background(Color.backgroundPrimary)
}
