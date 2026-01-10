//
//  ZodiacHeaderFull.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

/// A reusable header background component with gradient fade
struct HeaderBackground: View {
    let opacity: Double
    let heightMultiplier: CGFloat
    
    init(opacity: Double = 1.0, heightMultiplier: CGFloat = 1.0) {
        self.opacity = opacity
        self.heightMultiplier = heightMultiplier
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.deepBlue.opacity(1.0))
                .frame(height: 75 * heightMultiplier)
            
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.deepBlue.opacity(1.0), location: 0.0),
                    .init(color: Color.deepBlue.opacity(0.95), location: 0.1),
                    .init(color: Color.deepBlue.opacity(0.85), location: 0.25),
                    .init(color: Color.deepBlue.opacity(0.7), location: 0.4),
                    .init(color: Color.deepBlue.opacity(0.5), location: 0.55),
                    .init(color: Color.deepBlue.opacity(0.3), location: 0.7),
                    .init(color: Color.deepBlue.opacity(0.15), location: 0.85),
                    .init(color: Color.deepBlue.opacity(0.05), location: 0.95),
                    .init(color: Color.clear, location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100 * heightMultiplier)
        }
        .opacity(opacity)
        .allowsHitTesting(false)
        .ignoresSafeArea(.all, edges: .top)
    }
}

/// Display modes for the ZodiacHeaderMain component
enum ZodiacHeaderDisplayMode {
    case initial  // Default UI with centered badge only
    case compact  // 3/4-height of initial, otherwise identical
    case main     // Full UI with buttons and date
}

/// A reusable zodiac-themed header component with animated profile badge
/// 
/// The header can automatically display topic names based on the highlighted button state:
/// - When `highlightedButton` is set to a specific topic (e.g., .wellness), the header will
///   automatically show the corresponding display name (e.g., "Wellness") in compact mode
/// - If `centeredLabel` is explicitly provided, it takes precedence over the automatic behavior
/// - This is particularly useful when the header is used with QuestionMenu to show which topic is active
struct ZodiacHeader: View {
    // MARK: - Properties
    let profileImage: String
    let badgeScale: CGFloat
    let badgeRotation: Double
    let cosmicGlowOpacity: Double
    let nebulaOpacity: Double
    let starFieldOpacity: Double
    let cosmicParticlesOpacity: Double
    let sparkleOpacity: Double
    let stardustPoints: Int
    let badgeSize: CGFloat?
    let todaysDate: String
    let onSettingsTap: (() -> Void)?
    let onProfileBadgeTap: (() -> Void)?
    let displayMode: ZodiacHeaderDisplayMode
    // Horizontal menu configuration
    let showMenu: Bool
    let onWellness: (() -> Void)?
    let onRelationship: (() -> Void)?
    let onImportantPeople: (() -> Void)?
    let onChildren: (() -> Void)?
    let onEmployment: (() -> Void)?
    let highlightedButton: QuestionMenuButton
    // Optional centered label - if not provided, will automatically show based on highlightedButton state
    let centeredLabel: String?
    @StateObject private var badgeAnimationManager = BadgeAnimationManager()
    @State private var headerOpacity: Double = 1.0
    @State private var headerBackgroundOpacity: Double = 1.0
    
    // MARK: - Computed Properties
    
    /// Automatically generates the centered label based on the highlighted button state
    /// 
    /// Priority order:
    /// 1. If `centeredLabel` is explicitly provided, use that
    /// 2. Otherwise, automatically generate label based on `highlightedButton` state
    /// 3. If no button is highlighted, return nil (no label shown)
    private var automaticCenteredLabel: String? {
        if let customLabel = centeredLabel {
            return customLabel
        }
        
        switch highlightedButton {
        case .wellness:
            return "Wellness"
        case .relationship:
            return "Relationship"
        case .importantPeople:
            return "Important People"
        case .children:
            return "Children"
        case .employment:
            return "Employment"
        case .none:
            return nil
        }
    }
    
    // MARK: - Convenience Functions
    /// Returns the height of the profile badge
    static func profileBadgeHeight() -> CGFloat {
        return UIScreen.main.bounds.width * 0.5
    }
    
    /// Formats the current date in the required format
    static func formatCurrentDate() -> String {
        return "\(getDayOfWeek())\n\(getFormattedDate())"
    }
    
    /// Changes the opacity of the header
    /// - Parameter opacity: The opacity value (0.0 to 1.0)
    func setHeaderOpacity(_ opacity: Double) {
        headerOpacity = max(0.0, min(1.0, opacity)) // Clamp between 0.0 and 1.0
    }

    // MARK: - Initialization
    init(
        profileImage: String,
        badgeScale: CGFloat = 1.0,
        badgeRotation: Double = 0,
        cosmicGlowOpacity: Double = 0,
        nebulaOpacity: Double = 0,
        starFieldOpacity: Double = 0,
        cosmicParticlesOpacity: Double = 0,
        sparkleOpacity: Double = 0,
        stardustPoints: Int = 0,
        badgeSize: CGFloat? = nil,
        todaysDate: String = ZodiacHeader.formatCurrentDate(),
        onSettingsTap: (() -> Void)? = nil,
        onProfileBadgeTap: (() -> Void)? = nil,
        displayMode: ZodiacHeaderDisplayMode = .initial,
        showMenu: Bool = false,
        onWellness: (() -> Void)? = nil,
        onRelationship: (() -> Void)? = nil,
        onImportantPeople: (() -> Void)? = nil,
        onChildren: (() -> Void)? = nil,
        onEmployment: (() -> Void)? = nil,
        highlightedButton: QuestionMenuButton = .none,
        centeredLabel: String? = nil
    ) {
        self.profileImage = profileImage
        self.badgeScale = badgeScale
        self.badgeRotation = badgeRotation
        self.cosmicGlowOpacity = cosmicGlowOpacity
        self.nebulaOpacity = nebulaOpacity
        self.starFieldOpacity = starFieldOpacity
        self.cosmicParticlesOpacity = cosmicParticlesOpacity
        self.sparkleOpacity = sparkleOpacity
        self.stardustPoints = stardustPoints
        self.badgeSize = badgeSize
        self.todaysDate = todaysDate
        self.onSettingsTap = onSettingsTap
        self.onProfileBadgeTap = onProfileBadgeTap
        self.displayMode = displayMode
        self.showMenu = showMenu
        self.onWellness = onWellness
        self.onRelationship = onRelationship
        self.onImportantPeople = onImportantPeople
        self.onChildren = onChildren
        self.onEmployment = onEmployment
        self.highlightedButton = highlightedButton
        self.centeredLabel = centeredLabel
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Dark header background with gradient fade
            if displayMode == .initial {
                HeaderBackground(opacity: headerBackgroundOpacity, heightMultiplier: 1.0)
            } else if displayMode == .compact {
                HeaderBackground(opacity: headerBackgroundOpacity, heightMultiplier: 0.75)
            }
            
            // Header Content
            if displayMode == .main {
                // Main mode - current UI with buttons and date
                VStack(spacing: 0) {
                    HStack {
                        ZStack {
                            // Profile badge that animates between states
                            ZodiacProfileBadgeWithStardust(
                                zodiacImage: Image(badgeAnimationManager.currentProfileImage),
                                stardustPoints: 1250,
                                frameSize: displayMode == .main ? ZodiacHeader.profileBadgeHeight() : 150
                            )
                            .scaleEffect(displayMode == .main ? 1.0 : 0.9)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                        }
                        .frame(
                            width: displayMode == .main ? ZodiacHeader.profileBadgeHeight() : 150,
                            height: displayMode == .main ? ZodiacHeader.profileBadgeHeight() - 50 : 150
                        )
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                        .onTapGesture {
                            onProfileBadgeTap?()
                        }
                        
                        // Settings buttons that slide in
                        if displayMode == .main {
                            settingsButtons
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.leading, displayMode == .main ? 15 : 0)
                    .padding(.trailing, displayMode == .main ? 20 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                    
                    Spacer()

                    // Horizontal Question Menu anchored at the bottom of the header
                    if showMenu {
                                                    QuestionMenu(
                                onWellness: { onWellness?() },
                                onRelationship: { onRelationship?() },
                                onImportantPeople: { onImportantPeople?() },
                                onChildren: { onChildren?() },
                                onEmployment: { onEmployment?() },
                                highlightedButton: highlightedButton
                            )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height/5, alignment: .top)
                .padding(.top, 0)
                .padding(.bottom, displayMode == .main ? 10 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
            } else if displayMode == .initial {
                // Initial/Compact modes - profile badge centered; compact is 3/4 height
                let scale: CGFloat = displayMode == .compact ? 0.75 : 1.0
                VStack(spacing: 0) {
                    ZStack {
                        if badgeAnimationManager.currentProfileImage == "logo" {
                            // Original simple white circle for logo state
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 130 * scale, height: 130 * scale)
                                .scaleEffect(badgeAnimationManager.badgeScale)
                                .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeAnimationManager.badgeScale)
                                .animation(Animation.easeInOut(duration: 0.8), value: badgeAnimationManager.badgeRotation)
                            
                            Image(badgeAnimationManager.currentProfileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 140 * scale, height: 140 * scale)
                                .id(badgeAnimationManager.currentProfileImage)
                                .scaleEffect(badgeAnimationManager.badgeScale)
                                .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                        } else {
                            // Use enhanced ZodiacProfileBadge with stardust for zodiac signs
                            ZodiacProfileBadgeWhiteWithStardust(
                                zodiacImage: Image(badgeAnimationManager.currentProfileImage),
                                stardustPoints: stardustPoints
                            )
                            .scaleEffect(badgeAnimationManager.badgeScale * scale)
                            .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeAnimationManager.badgeScale)
                            .animation(Animation.easeInOut(duration: 0.8), value: badgeAnimationManager.badgeRotation)
                        }
                    }
                    .frame(height: 150 * scale)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, getSafeAreaTop())
                .background(
                    GeometryReader { headerGeometry in
                        Color.clear
                            .preference(key: HeaderHeightPreferenceKey.self, value: headerGeometry.size.height)
                    }
                )
                            } else if displayMode == .compact {
                    // Initial/Compact modes - profile badge centered; compact is 3/4 height
                    let scale: CGFloat = displayMode == .compact ? 0.75 : 1.0
                    VStack(spacing: 0) {
                        ZStack {
                            if badgeAnimationManager.currentProfileImage == "logo" {
                                // Original simple white circle for logo state
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 130 * scale, height: 130 * scale)
                                    .scaleEffect(badgeAnimationManager.badgeScale)
                                    .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeAnimationManager.badgeScale)
                                    .animation(Animation.easeInOut(duration: 0.8), value: badgeAnimationManager.badgeScale)
                                
                                Image(badgeAnimationManager.currentProfileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140 * scale, height: 140 * scale)
                                    .id(badgeAnimationManager.currentProfileImage)
                                    .scaleEffect(badgeAnimationManager.badgeScale)
                                    .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                            } else {
                                // Use enhanced ZodiacProfileBadge with stardust for zodiac signs
                                ZodiacProfileBadgeWhiteWithStardust(
                                    zodiacImage: Image(badgeAnimationManager.currentProfileImage),
                                    stardustPoints: stardustPoints
                                )
                                .scaleEffect(badgeAnimationManager.badgeScale * scale)
                                .rotationEffect(.degrees(badgeAnimationManager.badgeRotation))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeAnimationManager.badgeScale)
                                .animation(Animation.easeInOut(duration: 0.8), value: badgeAnimationManager.badgeRotation)
                            }
                        }
                        .frame(height: 150 * scale)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, -8) // Negative padding to pull content closer to top
                    .background(
                        GeometryReader { headerGeometry in
                            Color.clear
                                .preference(key: HeaderHeightPreferenceKey.self, value: headerGeometry.size.height)
                        }
                    )
            }
        }
        .overlay(
            // Optional centered label - only visible in compact mode
            Group {
                if displayMode == .compact, let label = automaticCenteredLabel {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // Fancy label with gradient and effects
                        Text(label)
                            .font(.dmSansSemibold(size: 20))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.deepBlue.opacity(0.9),
                                                Color.accentPurple.opacity(0.9)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.electricBlue.opacity(0.95),
                                                        Color.magenta
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(color: Color.orange.opacity(0.9), radius: 20, x: 0, y: 4)
                                    .shadow(color: Color.magenta.opacity(0.6), radius: 10, x: 0, y: 6)
                            )
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: label)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        )
        .opacity(headerOpacity)
        .zIndex(2)
        .onAppear {
            
            // Initialize BadgeAnimationManager with the initial profile image
            badgeAnimationManager.currentProfileImage = profileImage
            
            // Ensure header opacity is set to 1.0 when header appears
            setHeaderOpacity(1.0)
            
            // Set header background opacity to 0.0 when main view appears
            if displayMode == .main {
                headerBackgroundOpacity = 0.0
            }
        }
        .onChange(of: profileImage) { _, newValue in
            // Update current profile image when prop changes (e.g., when user zodiac updates)
            badgeAnimationManager.currentProfileImage = newValue
        }
        .onReceive(NotificationCenter.default.publisher(for: .badgeAnimationTriggered)) { notification in
            if let userInfo = notification.userInfo,
               let newAssetName = userInfo["newAssetName"] as? String {
                badgeAnimationManager.triggerBadgeAnimation(andSwapTo: newAssetName)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setHeaderBackgroundOpacity)) { notification in
            if let userInfo = notification.userInfo,
               let opacity = userInfo["opacity"] as? Double {
                withAnimation(.easeInOut(duration: 0.3)) {
                    headerBackgroundOpacity = opacity
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .setHeaderOpacityZero)) { notification in
            setHeaderOpacity(0.0)
        }
    }
    
    // MARK: - Layout Components
    private var settingsButtons: some View {
        VStack(alignment: .trailing, spacing: 16) {
            CircleIconButton(
                systemName: "bell",
                accessibilityLabel: "Notifications"
            ) {
                // Bell button action
            }
            
            CircleIconButton(
                systemName: "gearshape",
                accessibilityLabel: "Settings"
            ) {
                onSettingsTap?()
            }
            
            // Date display
            HoroscopeDateText(date: todaysDate)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .offset(x: displayMode == .main ? 0 : 200) // Slide in from off-screen
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: displayMode)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ZodiacHeader(
                profileImage: "Leo",
                badgeScale: 1.0,
                badgeRotation: 0,
                cosmicGlowOpacity: 0.5,
                nebulaOpacity: 0.3,
                starFieldOpacity: 0.4,
                cosmicParticlesOpacity: 0.6,
                sparkleOpacity: 0.8,
                badgeSize: nil,
                todaysDate: ZodiacHeader.formatCurrentDate(),
                onSettingsTap: {
                    print("Settings button tapped")
                },
                displayMode: .main
            )
            
            ZodiacHeader(
                profileImage: "Leo",
                badgeScale: 1.0,
                badgeRotation: 0,
                cosmicGlowOpacity: 0.5,
                nebulaOpacity: 0.3,
                starFieldOpacity: 0.4,
                cosmicParticlesOpacity: 0.6,
                sparkleOpacity: 0.8,
                badgeSize: nil,
                todaysDate: ZodiacHeader.formatCurrentDate(),
                onSettingsTap: {
                    print("Settings button tapped")
                },
                displayMode: .initial
            )
            
        ZodiacHeader(
            profileImage: "Leo",
            badgeScale: 1.0,
            badgeRotation: 0,
            cosmicGlowOpacity: 0.5,
            nebulaOpacity: 0.3,
            starFieldOpacity: 0.4,
            cosmicParticlesOpacity: 0.6,
            sparkleOpacity: 0.8,
            badgeSize: nil,
            todaysDate: ZodiacHeader.formatCurrentDate(),
            onSettingsTap: {
                print("Settings button tapped")
            },
            displayMode: .compact,
            highlightedButton: .relationship
        )
        
        // Example with different highlighted button states
        VStack(spacing: 16) {
            Text("Different Highlighted States:")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                ZodiacHeader(
                    profileImage: "Leo",
                    displayMode: .compact,
                    highlightedButton: .wellness
                )
                
                ZodiacHeader(
                    profileImage: "Leo",
                    displayMode: .compact,
                    highlightedButton: .importantPeople
                )
                
                ZodiacHeader(
                    profileImage: "Leo",
                    displayMode: .compact,
                    highlightedButton: .children
                )
                
                ZodiacHeader(
                    profileImage: "Leo",
                    displayMode: .compact,
                    highlightedButton: .employment
                )
            }
        }
        }
    }
}

// MARK: - Canvas Preview with Animation
#Preview("Canvas Preview with Animation") {
    AnimatedHeaderDemo()
}

// MARK: - Demo Component for Canvas Preview
struct AnimatedHeaderDemo: View {
    @State private var displayMode: ZodiacHeaderDisplayMode = .initial
    @State private var isAnimating = false
    
    // MARK: - Computed Properties
    private var profileBadge: some View {
        ZodiacProfileBadgeWithStardust(
            zodiacImage: Image("Leo"),
            stardustPoints: 1250,
            frameSize: ZodiacHeader.profileBadgeHeight()
        )
        .scaleEffect(1.0)
        .rotationEffect(.degrees(0))
    }
    
    private var initialProfileBadge: some View {
        ZodiacProfileBadgeWhiteWithStardust(
            zodiacImage: Image("Leo"),
            stardustPoints: 1250
        )
        .scaleEffect(displayMode == .main ? 0.8 : 1.0) // Size animation
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
    }
    
    private var mainProfileBadge: some View {
        ZodiacProfileBadgeWithStardust(
            zodiacImage: Image("Leo"),
            stardustPoints: 1250,
            frameSize: ZodiacHeader.profileBadgeHeight()
        )
        .scaleEffect(displayMode == .main ? 1.0 : 0.8) // Size animation
        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
    }
    
    private var settingsButtons: some View {
        VStack(alignment: .trailing, spacing: 16) {
            CircleIconButton(
                systemName: "bell",
                accessibilityLabel: "Notifications"
            ) {
                // Bell button action
            }
            
            CircleIconButton(
                systemName: "gearshape",
                accessibilityLabel: "Settings"
            ) {
                print("Settings tapped")
            }
            
            // Date display
            HoroscopeDateText(date: ZodiacHeader.formatCurrentDate())
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .offset(x: displayMode == .main ? 0 : 200) // Slide in from off-screen
        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2), value: displayMode)
    }
    
    var body: some View {
        ZStack {
            // Background gradient to simulate app background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.deepBlue.opacity(0.3),
                    Color.purple.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Animation button at the top
                animationControls
                
                // Animated Header with position transitions
                VStack(spacing: 0) {
                    HStack {
                        ZStack {
                            // Profile badge that animates between states
                            ZodiacProfileBadgeWithStardust(
                                zodiacImage: Image("Leo"),
                                stardustPoints: 1250,
                                frameSize: displayMode == .main ? ZodiacHeader.profileBadgeHeight() : 150
                            )
                            .scaleEffect(displayMode == .main ? 1.0 : 0.9)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                        }
                        .frame(
                            width: displayMode == .main ? ZodiacHeader.profileBadgeHeight() : 150,
                            height: displayMode == .main ? ZodiacHeader.profileBadgeHeight() - 50 : 150
                        )
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                        
                        // Settings buttons that slide in
                        if displayMode == .main {
                            VStack(alignment: .trailing, spacing: 16) {
                                CircleIconButton(
                                    systemName: "bell",
                                    accessibilityLabel: "Notifications"
                                ) {
                                    // Bell button action
                                }
                                
                                CircleIconButton(
                                    systemName: "gearshape",
                                    accessibilityLabel: "Settings"
                                ) {
                                    print("Settings tapped")
                                }
                                
                                            // Date display
            HoroscopeDateText(date: ZodiacHeader.formatCurrentDate())
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .padding(.leading, displayMode == .main ? 15 : 0)
                    .padding(.trailing, displayMode == .main ? 20 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height/5, alignment: .top)
                .padding(.top, displayMode == .main ? 10 : 36)
                .padding(.bottom, displayMode == .main ? 10 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayMode)
                
                // Simulated content area
                contentArea
            }
        }
    }
    
    // MARK: - Layout Components
    private var animationControls: some View {
        VStack(spacing: 16) {
            Text("Animation Demo")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Primary transition button
            Button("🚀 Animate to Main UI") {
                transitionToMain()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .font(.headline)
            .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Button("Initial Mode") {
                    transitionToInitial()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button("Main Mode") {
                    transitionToMain()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private var contentArea: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 200)
            .overlay(
                Text("App Content Area")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            )
    }
    
    // MARK: - Animation Functions
    /// Transitions from initial mode to main mode with animation
    private func transitionToMain() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Animate to main mode
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            displayMode = .main
        }
        
        // Reset animation flag after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = false
        }
    }
    
    /// Transitions from main mode to initial mode with animation
    private func transitionToInitial() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Animate to initial mode
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            displayMode = .initial
        }
        
        // Reset animation flag after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = false
        }
    }
}
