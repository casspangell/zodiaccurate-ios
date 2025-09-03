import SwiftUI

struct FlipBookCard: View {
    let horoscope: Horoscope?
    let isLoading: Bool
    let onCardTap: (() -> Void)?
    let showStartButton: Bool
    let onStartButtonTap: (() -> Void)?
    let isUnfinished: Bool
    
    // Navigation parameters
    let canNavigateLeft: Bool
    let canNavigateRight: Bool
    let onNavigateLeft: (() -> Void)?
    let onNavigateRight: (() -> Void)?
    
    @StateObject private var audioManager = AudioManager.shared
    
    // Internal state for expansion
    @State private var isExpanded = false
    @State private var cardHeight: CGFloat = 0.5
    @State private var globalFlipBookExpanded = false
    
    // Animation states for unfinished pulsating effect
    @State private var cardScale: CGFloat = 1.0
    @State private var cardOpacity: Double = 1.0
    @State private var borderOpacity: Double = 0.3
    
    // State for convenience initializer
    @State private var convenienceTitle: String = ""
    @State private var convenienceContent: String = ""
    
    // Card height constants
//    private let cardHeightMinimized: CGFloat = 0.05
    private let cardHeightNormal: CGFloat = 0.5
    private let cardHeightExpanded: CGFloat = 0.8
    // Reserve vertical space at the top of the card content for the overlayed
    // play/expand controls so text renders below them.
    private let topControlsInset: CGFloat = 60
    
    init(horoscope: Horoscope?, isLoading: Bool = false, onCardTap: (() -> Void)? = nil, showStartButton: Bool = false, onStartButtonTap: (() -> Void)? = nil, isUnfinished: Bool = false, canNavigateLeft: Bool = false, canNavigateRight: Bool = false, onNavigateLeft: (() -> Void)? = nil, onNavigateRight: (() -> Void)? = nil) {
        self.horoscope = horoscope
        self.isLoading = isLoading
        self.onCardTap = onCardTap
        self.showStartButton = showStartButton
        self.onStartButtonTap = onStartButtonTap
        self.isUnfinished = isUnfinished
        self.canNavigateLeft = canNavigateLeft
        self.canNavigateRight = canNavigateRight
        self.onNavigateLeft = onNavigateLeft
        self.onNavigateRight = onNavigateRight
    }
    
    // Convenience initializer for backward compatibility
    init(title: String, content: String, onCardTap: (() -> Void)? = nil, showStartButton: Bool = false, onStartButtonTap: (() -> Void)? = nil, isUnfinished: Bool = false, canNavigateLeft: Bool = false, canNavigateRight: Bool = false, onNavigateLeft: (() -> Void)? = nil, onNavigateRight: (() -> Void)? = nil) {
        self.horoscope = Horoscope(title: title, message: content, key: "temp")
        self.isLoading = false
        self.onCardTap = onCardTap
        self.showStartButton = showStartButton
        self.onStartButtonTap = onStartButtonTap
        self.isUnfinished = isUnfinished
        self.canNavigateLeft = canNavigateLeft
        self.canNavigateRight = canNavigateRight
        self.onNavigateLeft = onNavigateLeft
        self.onNavigateRight = onNavigateRight
        // Store title and content for convenience initializer
        self._convenienceTitle = State(initialValue: title)
        self._convenienceContent = State(initialValue: content)
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
                        ScrollViewReader { scrollProxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Spacer to push content below top-right overlay controls
                                    Color.clear
                                        .frame(height: topControlsInset)
                                    // Header
                                    Text(horoscope.title)
                                        .font(.dmSansSemibold(size: 24))
                                        .foregroundColor(globalFlipBookExpanded ? .black : .whiteCustom)
                                        .padding(.horizontal, 20)
                                        .id("top") // Add ID for scrolling to top

                                    // Content
                                    Text(getContentText())
                                        .font(.dmSansMedium(size: 16))
                                        .foregroundColor(globalFlipBookExpanded ? .black.opacity(0.8) : .whiteCustom.opacity(0.8))
                                        .lineSpacing(4)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                        .onAppear {
                                            print("🎯 FlipBookCard: Content text displayed - '\(getContentText())'")
                                        }
                                        .onChange(of: isCardUnfinished) { _, newValue in
                                            print("🎯 FlipBookCard: Content text changed - isCardUnfinished: \(newValue)")
                                        }
                                    
                                    // Continue/Start Button (if enabled)
                                    if showStartButton {
                                        HStack {
                                            Spacer()
                                            PrimaryGradientButton(title: isCardUnfinished ? "Continue" : "Start!") {
                                                print("🎯 FlipBookCard: \(isCardUnfinished ? "Continue" : "Start") button tapped!")
                                                onStartButtonTap?()
                                            }
                                            .onAppear {
                                                print("🎯 FlipBookCard: Button text - isCardUnfinished: \(isCardUnfinished), showing: '\(isCardUnfinished ? "Continue" : "Start!")'")
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .onAppear {
                                            print("🎯 FlipBookCard: \(isCardUnfinished ? "Continue" : "Start") button appeared - showStartButton: \(showStartButton)")
                                        }
                                        .onTapGesture {
                                            print("🎯 FlipBookCard: \(isCardUnfinished ? "Continue" : "Start") button tap gesture detected")
                                        }
                                        .allowsHitTesting(true)
                                        .zIndex(1000) // Ensure button is on top
                                        .onChange(of: isExpanded) { _, newValue in
                                            print("🎯 FlipBookCard: Card expansion changed to \(newValue)")
                                        }
                                    }
                                    
                                    Spacer(minLength: 20)
                                }
                                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
                                .layoutPriority(1) // Ensure proper layout priority
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .animation(.none, value: isExpanded) // Disable animations during frame changes
                            .onChange(of: isExpanded) { _, newValue in
                                print("🎯 FlipBookCard: ScrollView expansion state changed to \(newValue)")
                            }
                            .onChange(of: isExpanded) { _, newValue in
                                if !newValue {
                                    // Scroll to top when contracting
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            }
                        }
                        
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
                        .zIndex(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16) //kilroy
                            .fill(globalFlipBookExpanded ? Color.white : (isCardUnfinished ? Color.deepPink.opacity(0.1) : Color.bubbleMist.opacity(0.8)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isCardUnfinished ? Color.deepPink.opacity(borderOpacity) : Color.accentPurple.opacity(borderOpacity), lineWidth: isCardUnfinished ? 2 : 1)
                            )
                    )
                    .shadow(color: isCardUnfinished ? Color.deepPink.opacity(0.3) : Color.accentPurple.opacity(0.2), radius: 10, x: 0, y: 5)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)
                    .onAppear {
                        if isCardUnfinished {
                            startPulsatingAnimation()
                        }
                    }
                    .onChange(of: isCardUnfinished) { newValue in
                        if newValue {
                            startPulsatingAnimation()
                        } else {
                            stopPulsatingAnimation()
                        }
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
            }
            .frame(height: geometry.size.height * cardHeight)
            .offset(y: isExpanded ? -geometry.safeAreaInsets.top : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0), value: cardHeight) // Animate only cardHeight changes
            .onAppear {
                print("🎯 FlipBookCard: Card appeared - showStartButton: \(showStartButton)")
            }
            .onDisappear {
                print("🎯 FlipBookCard: Card disappeared")
            }
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
            .onAppear {
                updateUnfinishedState()
            }
            .onReceive(NotificationCenter.default.publisher(for: .conversationProgressUpdated)) { _ in
                print("🔄 FlipBookCard: Received conversationProgressUpdated notification, updating unfinished state")
                updateUnfinishedState()
            }
        }
    }
    
    // MARK: - State Properties for Unfinished State
    
    /// Determines if a card is unfinished based on conversation progress
    /// Returns true only if there's some progress but not complete
    @State private var isCardUnfinishedState: Bool = false
    
    /// Computed property that combines explicit isUnfinished with progress-based state
    private var isCardUnfinished: Bool {
        // If isUnfinished is explicitly set, use that value
        if isUnfinished {
            print("🎯 FlipBookCard: isUnfinished explicitly set to true")
            return true
        }
        
        // Otherwise, use the reactive state
        return isCardUnfinishedState
    }
    
    /// Get the card title for progress checking
    private func getCardTitle() -> String? {
        if let horoscope = horoscope {
            return horoscope.title
        }
        // For convenience initializer, use the stored title
        return convenienceTitle.isEmpty ? nil : convenienceTitle
    }
    
    /// Update the unfinished state based on current progress
    private func updateUnfinishedState() {
        guard let title = getCardTitle() else { 
            isCardUnfinishedState = false
            return 
        }
        
        let topicKey = getTopicKey(from: title)
        let progress = ConversationProgressManager.getProgress(for: topicKey)
        let totalSteps = getTotalStepsForTopic(topicKey)
        let newUnfinishedState = progress > 0 && progress < totalSteps
        
        if isCardUnfinishedState != newUnfinishedState {
            isCardUnfinishedState = newUnfinishedState
            print("🎯 FlipBookCard: Updated unfinished state for '\(title)' - Progress: \(progress)/\(totalSteps), Unfinished: \(newUnfinishedState)")
        }
    }
    
    /// Get the content text to display
    private func getContentText() -> String {
        if let horoscope = horoscope {
            return horoscope.message
        }
        // For convenience initializer, show appropriate text based on unfinished state
        let contentText = isCardUnfinished ? "Continue your intake" : "Start your intake"
        print("🎯 FlipBookCard: Content text - isCardUnfinished: \(isCardUnfinished), showing: '\(contentText)'")
        return contentText
    }
    
    /// Convert display title to topic key for progress checking
    private func getTopicKey(from title: String) -> String {
        switch title.lowercased() {
        case "wellness":
            return "wellness"
        case "partner", "relationship":
            return "relationship"
        case "important people":
            return "importantPeople"
        case "children":
            return "children"
        case "employment":
            return "employment"
        default:
            return title.lowercased()
        }
    }
    
    /// Get the total number of steps for a specific topic
    /// This should match the actual conversation steps defined in your app
    private func getTotalStepsForTopic(_ topic: String) -> Int {
        switch topic.lowercased() {
        case "wellness":
            return 5 // Adjust based on your actual wellness conversation steps
        case "relationship":
            return 5 // Adjust based on your actual relationship conversation steps
        case "importantpeople":
            return 5 // Adjust based on your actual important people conversation steps
        case "children":
            return 5 // Adjust based on your actual children conversation steps
        case "employment":
            return 5 // Adjust based on your actual employment conversation steps
        default:
            return 5 // Default fallback
        }
    }
    
    // MARK: - Animation Functions
    private func startPulsatingAnimation() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            cardScale = 1.02
            cardOpacity = 0.95
            borderOpacity = 0.8
        }
    }
    
    private func stopPulsatingAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            cardScale = 1.0
            cardOpacity = 1.0
            borderOpacity = 0.3
        }
    }
}



#Preview {
    VStack(spacing: 20) {
        // Canvas Preview - Demonstrates FlipBookCard with Pulsating Animation
        // Loading state
        // FlipBookCard(horoscope: nil, isLoading: true)
        //     .frame(height: 300)
        //     .padding()
        
        // // Loaded state with navigation arrows
        // FlipBookCard(
        //     horoscope: Horoscope(
        //         title: "Parenting",
        //         message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas venenatis eros ut pretium tincidunt. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Sed vitae ex vitae nisi varius venenatis. Praesent commodo urna at nisi finibus varius. Nulla facilisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec vehicula sapien vitae massa tincidunt efficitur. Duis vestibulum mauris ac lectus tincidunt, in volutpat lorem efficitur. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.",
        //         key: "preview"
        //     ),
        //     isLoading: false,
        //     onCardTap: {
        //         print("Card tapped - would move FlipBook to top")
        //     },
        //     isUnfinished: false,
        //     canNavigateLeft: true,
        //     canNavigateRight: true,
        //     onNavigateLeft: {
        //         print("Navigate left tapped!")
        //     },
        //     onNavigateRight: {
        //         print("Navigate right tapped!")
        //     }
        // )
        // .frame(height: 300)
        // .padding()
        
        // // Card with Start button
        // FlipBookCard(
        //     title: "Wellness",
        //     content: "Start your intake",
        //     showStartButton: true,
        //     onStartButtonTap: {
        //         print("Start button tapped!")
        //     },
        //     isUnfinished: false
        // )
        // .frame(height: 300)
        // .padding()
        
        // Card with unfinished state (pulsating animation) - automatically determined
        FlipBookCard(
            title: "Wellness",
            content: "Start your intake",
            showStartButton: true,
            onStartButtonTap: {
                print("Continue button tapped!")
            }
        )
        .frame(height: 300)
        .padding()
        
        // Card with employment topic to show different behavior
        FlipBookCard(
            title: "Employment",
            content: "Start your intake",
            showStartButton: true,
            onStartButtonTap: {
                print("Employment button tapped!")
            }
        )
        .frame(height: 300)
        .padding()
    }
    .background(Color.backgroundPrimary)
}
