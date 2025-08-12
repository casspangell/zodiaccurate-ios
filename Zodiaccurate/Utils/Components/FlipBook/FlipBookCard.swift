import SwiftUI

struct FlipBookCard: View {
    let horoscope: Horoscope?
    let isLoading: Bool
    let onCardTap: (() -> Void)?
    let showStartButton: Bool
    let onStartButtonTap: (() -> Void)?
    @StateObject private var audioManager = AudioManager.shared
    
    // Internal state for expansion
    @State private var isExpanded = false
    @State private var cardHeight: CGFloat = 0.5
    @State private var globalFlipBookExpanded = false
    
    // Card height constants
    private let cardHeightMinimized: CGFloat = 0.05
    private let cardHeightNormal: CGFloat = 0.5
    private let cardHeightExpanded: CGFloat = 0.8
    
    init(horoscope: Horoscope?, isLoading: Bool = false, onCardTap: (() -> Void)? = nil, showStartButton: Bool = false, onStartButtonTap: (() -> Void)? = nil) {
        self.horoscope = horoscope
        self.isLoading = isLoading
        self.onCardTap = onCardTap
        self.showStartButton = showStartButton
        self.onStartButtonTap = onStartButtonTap
    }
    
    // Convenience initializer for backward compatibility
    init(title: String, content: String, onCardTap: (() -> Void)? = nil, showStartButton: Bool = false, onStartButtonTap: (() -> Void)? = nil) {
        self.horoscope = Horoscope(title: title, message: content, key: "temp")
        self.isLoading = false
        self.onCardTap = onCardTap
        self.showStartButton = showStartButton
        self.onStartButtonTap = onStartButtonTap
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
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
                    ZStack(alignment: .topTrailing) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 16) {
                                // Header
                                Text(horoscope.title)
                                    .font(.dmSansSemibold(size: 24))
                                    .foregroundColor(globalFlipBookExpanded ? .black : .whiteCustom)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)

                                // Content
                                Text(horoscope.message)
                                    .font(.dmSansMedium(size: 16))
                                    .foregroundColor(globalFlipBookExpanded ? .black.opacity(0.8) : .whiteCustom.opacity(0.8))
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                
                                // Start Button (if enabled)
                                if showStartButton {
                                    HStack {
                                        Spacer()
                                        PrimaryGradientButton(title: "Start!") {
                                            onStartButtonTap?()
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                                Spacer(minLength: 20)
                            }
                            .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                        }
                        .disabled(!isExpanded)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Top right buttons container
                        HStack(spacing: 8) {
                            // Audio Control Button (always visible, disabled if no audio)
                            AudioControlButton(
                                isPlaying: audioManager.isPlaying && audioManager.currentAudioKey == horoscope.key,
                                onToggle: {
                                    if audioManager.hasAudio(for: horoscope) {
                                        audioManager.toggleAudio(for: horoscope)
                                    }
                                },
                                size: 44,
                                isEnabled: audioManager.hasAudio(for: horoscope),
                                iconColor: globalFlipBookExpanded ? .black : .white,
                                borderColor: AnyShapeStyle(globalFlipBookExpanded ? .black.opacity(0.3) : .white.opacity(0.7))
                            )
                            
                            // Expand/Contract Button
                            CircleIconButtonNoBackground(
                                systemName: isExpanded ? "chevron.down" : "chevron.up",
                                accessibilityLabel: isExpanded ? "Collapse card" : "Expand card",
                                iconColor: globalFlipBookExpanded ? .black : .white,
                                strokeColor: globalFlipBookExpanded ? .black.opacity(0.3) : .white.opacity(0.7),
                                action: {
                                    if isExpanded {
                                        // Tap to collapse from expanded state
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                            cardHeight = cardHeightNormal
                                            isExpanded = false
                                        }
                                        // Post notification to reset spacing
                                        NotificationCenter.default.post(name: .flipBookCollapsed, object: nil)
                                        // Post notification to deactivate component
                                        NotificationCenter.default.post(name: .componentDeactivated, object: nil)
                                        // Post notification to update global expansion state
                                        NotificationCenter.default.post(
                                            name: .flipBookExpansionStateChanged,
                                            object: nil,
                                            userInfo: ["isExpanded": false]
                                        )
                                    } else {
                                        // Tap to expand from normal state
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                                            cardHeight = cardHeightExpanded
                                            isExpanded = true
                                        }
                                        // Post notification to move FlipBook to top
                                        NotificationCenter.default.post(name: .flipBookMoveToTop, object: nil)
                                        // Post notification to activate FlipBook
                                        NotificationCenter.default.post(name: .flipBookActivated, object: nil)
                                        // Post notification to update global expansion state
                                        NotificationCenter.default.post(
                                            name: .flipBookExpansionStateChanged,
                                            object: nil,
                                            userInfo: ["isExpanded": true]
                                        )
                                        onCardTap?()
                                    }
                                }
                            )
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                        .zIndex(1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16) //kilroy
                            .fill(globalFlipBookExpanded ? Color.white : Color.bubbleMist.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                    
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
            }
            .frame(height: geometry.size.height * cardHeight)
            .offset(y: isExpanded ? -geometry.safeAreaInsets.top : 0)
            .background(
                GeometryReader { cardGeometry in
                    Color.clear
                        .preference(
                            key: FlipBookCardBottomPreferenceKey.self,
                            value: isExpanded ? cardGeometry.frame(in: .global).maxY : 0
                        )
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .onReceive(NotificationCenter.default.publisher(for: .flipBookExpansionStateChanged)) { notification in
                if let isExpanded = notification.userInfo?["isExpanded"] as? Bool {
                    globalFlipBookExpanded = isExpanded
                }
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
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
                key: "preview"
            ),
            isLoading: false,
            onCardTap: {
                print("Card tapped - would move FlipBook to top")
            }
        )
        .frame(height: 300)
        .padding()
        
        // Card with Start button
        FlipBookCard(
            title: "Wellness",
            content: "Start your intake",
            showStartButton: true,
            onStartButtonTap: {
                print("Start button tapped!")
            }
        )
        .frame(height: 300)
        .padding()
    }
    .background(Color.backgroundPrimary)
}
