//
//  ConversationalOnboardingView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import SwiftUI
import SwiftData
import Combine

struct ConversationalOnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var userDataManager: UserDataManager?
    @State private var stardustManager: StardustManager?
    // Removed Firebase integration - only using Core Data
    @State private var messages: [ChatMessage] = []
    @State private var currentInput = ""
    @State private var currentStep = 0
    @State private var isTyping = false
    @State private var userData = UserData(firstName: "", birthDate: "", birthTime: "", zodiacSign: "", responses: [])
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var showInteractivePicker = false
    @State private var showInputField = false
    @State private var showSecondaryElements = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    @State private var textFieldFrame: CGRect = .zero
    @State private var currentProfileImage = "logo"
    @State private var isAcquiringBadge = false
    @State private var badgeScale: CGFloat = 1.0
    @State private var badgeRotation: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var cosmicParticlesOpacity: Double = 0
    @State private var nebulaOpacity: Double = 0
    @State private var starFieldOpacity: Double = 0
    @State private var cosmicGlowOpacity: Double = 0
    @State private var showOnboardingHoroscope = false
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var tutorialManager = TutorialManager()
    @FocusState private var isTextFieldFocused: Bool
    @State private var highlightInputField = false
    @State private var manualScrollOffset: CGFloat = 0
    
    // Unified scroll manager
    @StateObject private var scrollManager = ScrollManager()

    var onComplete: () -> Void = {}
    
    init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }
    
    // Calculate dynamic offsets
    private var scrollViewOffset: CGFloat {
        return max(headerHeight * 0.5, 100) // Start midway behind the profile image, minimum 100
    }
    
    private var contentTopSpacing: CGFloat {
        return max(headerHeight * 1.2, 200) // Push content below the profile image with minimum spacing
    }
    
    private var contentTopPadding: CGFloat {
        return max(headerHeight * 0.67, 80) // Overlap with profile image, minimum 80
    }
    
    // Calculate intelligent keyboard offset
    private var intelligentKeyboardOffset: CGFloat {
        guard keyboardHeight > 0 else { return 0 }
        
        // Get screen height
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the bottom position of the text field relative to screen
        let textFieldBottom = textFieldFrame.maxY
        
        // Calculate available space above keyboard
        let keyboardTop = screenHeight - keyboardHeight
        let availableSpace = keyboardTop - textFieldBottom
        
        // If text field is below keyboard, calculate how much to move up
        if availableSpace < 0 {
            // Add some padding (20 points) to ensure text field is comfortably above keyboard
            return abs(availableSpace) + 20
        }
        
        return 0
    }
    
    // Calculate total scroll offset including manual adjustments
    private var totalScrollOffset: CGFloat {
        return scrollViewOffset + intelligentKeyboardOffset + manualScrollOffset
    }
    
    var body: some View {
        ZStack {
            // Background layers - ensure full screen coverage
            BackgroundView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
                .onTapGesture {
                    // Dismiss keyboard when tapping background
                    isTextFieldFocused = false
                }
            
            if showOnboardingHoroscope {
                OnboardingHoroscopeView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                // Header ZStack - positioned on top
                ZStack {
                    // Dark header background with gradient fade
                    VStack(spacing: 0) {
                        // Solid dark background for header content - extend to very top
                        Rectangle()
                            .fill(Color.deepBlue.opacity(1.0))
                            .frame(height: headerHeight + 100) // Increased height to extend to top
                        
                        // Enhanced gradient fade at bottom
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
                        .frame(height: 100)
                    }
                    .allowsHitTesting(false)
                    .ignoresSafeArea(.all, edges: .top) // Ensure header background extends to top edge
                    
                    // Fixed Header Content
                    VStack(spacing: 8) {
                        // Logo with minimal glow
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(currentProfileImage == "logo" ? 0.5 : 0.8))
                                .frame(width: 130, height: 130)
                                .scaleEffect(badgeScale)
                                .rotationEffect(.degrees(badgeRotation))
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: badgeScale)
                                .animation(Animation.easeInOut(duration: 0.8), value: badgeRotation)
                            
                            CosmicBadgeEffects(
                                badgeScale: badgeScale,
                                badgeRotation: badgeRotation,
                                cosmicGlowOpacity: cosmicGlowOpacity,
                                nebulaOpacity: nebulaOpacity,
                                starFieldOpacity: starFieldOpacity,
                                cosmicParticlesOpacity: cosmicParticlesOpacity,
                                sparkleOpacity: sparkleOpacity,
                                currentProfileImage: currentProfileImage
                            )
                            
                            ZStack {
                                Image(currentProfileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140, height: 140)
                                    .id(currentProfileImage)
                            }
                            .scaleEffect(badgeScale)
                            .rotationEffect(.degrees(badgeRotation))
                        }
                        .frame(height: 150)
                        .padding(.top, 60)
                        
                        Text("")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 0)
                    .background(
                        GeometryReader { headerGeometry in
                            Color.clear
                                .preference(key: HeaderHeightPreferenceKey.self, value: headerGeometry.size.height)
                        }
                    )
                }
                .zIndex(2)
                
                // Chat ScrollView - This is the key change
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            // Add spacing to push content below profile image
                            Spacer().frame(height: contentTopSpacing)
                            
                            // Fallback spacer to ensure minimum spacing
                            if headerHeight < 100 {
                                Spacer().frame(height: 250)
                            }
                            
                            // Chat Content
                            ChatContentView(
                                messages: messages,
                                currentStep: currentStep,
                                onboardingConversationSteps: onboardingConversationSteps,
                                showInteractivePicker: showInteractivePicker,
                                showSecondaryElements: showSecondaryElements,
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                isTyping: isTyping,
                                onDateSelected: { date in
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    handleUserInput(input: formatter.string(from: date))
                                },
                                onTimeSelected: { time in
                                    let formatter = DateFormatter()
                                    formatter.timeStyle = .short
                                    handleUserInput(input: formatter.string(from: time))
                                },
                                onUnknownTime: {
                                    handleUserInput(input: "Unknown")
                                },
                                tutorialManager: tutorialManager,
                                onBubbleSizeChange: { message, size in
                                }
                            )
                            

                            
                            // Input
                            ChatInputView(
                                currentStep: currentStep,
                                onboardingConversationSteps: onboardingConversationSteps,
                                showInputField: showInputField,
                                showSecondaryElements: showSecondaryElements,
                                currentInput: $currentInput,
                                onSend: { handleSendWithRecordingCheck() },
                                isTextFieldFocused: $isTextFieldFocused,
                                onFrameChange: { frame in
                                    textFieldFrame = frame
                                },
                                tutorialManager: tutorialManager,
                                highlightInputField: $highlightInputField,
                                onHeightChange: { heightDifference in
                                    // Automatically move the scrollview up by the height difference
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        manualScrollOffset += heightDifference
                                    }
                                }
                            )
                            .id("inputSection")
                            
                            // Complete Button
                            if (currentStep < onboardingConversationSteps.count && onboardingConversationSteps[currentStep].isFinal && messages.count > 0 && messages.last?.isUser == false) ||
                               currentStep >= onboardingConversationSteps.count {
                                Button(action: { 
                                    saveOnboardingData()
                                    showOnboardingHoroscope = true
                                    
                                    // Generate horoscope on background thread
                                    Task {
                                        await generateWelcomeHoroscope()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text("See Your First Zodiaccurate")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentGold)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 50) // Add enough padding to clear the home indicator
                                .transition(.opacity)
                            }
                            
                            // Bottom anchor with safe area padding
                            Color.clear
                                .frame(height: 1)
                                .padding(.bottom, 50) // Add enough padding to clear the home indicator
                                .id("bottom")
                        }
                        .padding(.horizontal)
                        .padding(.top, -contentTopPadding)
                    }
                    .scrollDisabled(true)
                    .scrollDismissesKeyboard(.interactively)
                    .clipped() // Prevent content from overflowing
                    .onChange(of: messages.count) { _, _ in
                        // Only scroll when an AI response is added (not user messages)
                        if let lastMessage = messages.last, !lastMessage.isUser {
                            scrollManager.scheduleScroll(to: .lastMessage, proxy: proxy, delay: 0.1, messageId: lastMessage.id)
                        }
                    }
                    .onChange(of: isTyping) { _, newValue in
                        if newValue {
                            scrollManager.scheduleScroll(to: .typing, proxy: proxy, delay: 0.1)
                        }
                    }
                    .onChange(of: tutorialManager.showVoiceTutorial) { _, newValue in
                        if newValue {
                            // Scroll to show input section when tutorial appears
                            scrollManager.scheduleScroll(to: .input, proxy: proxy, delay: 0.1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // KEY: Fill remaining space
                .offset(y: -totalScrollOffset) // Total scroll offset including manual adjustments
                .zIndex(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // KEY: Fill entire screen
            }
            
            if showZodiacAlert {
                ZodiacAlertView(
                    title: "Horoscope Generation Failed",
                    message: zodiacAlertMessage,
                    primaryButtonTitle: "Try Again",
                    primaryButtonAction: {
                        showZodiacAlert = false
                        Task { await generateWelcomeHoroscope() }
                    }
                )
            }
            

            
            // Stardust earning animation
            if let stardustManager = stardustManager, stardustManager.showEarningAnimation {
                StardustEarningAnimation(
                    amount: stardustManager.earningAnimationAmount,
                    type: stardustManager.earningAnimationType,
                    isShowing: Binding(
                        get: { stardustManager.showEarningAnimation },
                        set: { stardustManager.showEarningAnimation = $0 }
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full screen coverage
        .ignoresSafeArea(.all, edges: .all) // Ignore all safe areas
        .onAppear {
            // Initialize UserDataManager with the correct model context
            if userDataManager == nil {
                userDataManager = UserDataManager(modelContext: modelContext)
            } else {
                userDataManager?.updateModelContext(modelContext)
            }
            
            // Initialize StardustManager (no do-catch needed)
            if stardustManager == nil {
                stardustManager = StardustManager(modelContext: modelContext)
                print("✅ StardustManager initialized successfully")
            }
            
            startConversation()
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            self.headerHeight = headerHeight
        }
        .animation(Animation.easeInOut(duration: 0.7), value: showOnboardingHoroscope)
        .onReceive(Publishers.keyboardHeight) { keyboardHeight in
            self.keyboardHeight = keyboardHeight
        }
        .onDisappear {
            // Cancel any pending scroll operations when view disappears
            scrollManager.cancelPendingScroll()
        }

    }
    

    
    // Background View
    private struct BackgroundView: View {
        var body: some View {
            ZStack {
                // Cosmic background
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "1A0B2E"), location: 0.0),
                        .init(color: Color(hex: "0F051A"), location: 0.7),
                        .init(color: Color.black, location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)

                // Vignette overlay
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0.0), location: 0.6),
                        .init(color: Color.black.opacity(0.7), location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
                .blendMode(.multiply)
                .allowsHitTesting(false)

                // Celestial bodies
                GeometryReader { geo in
                    CelestialSystemBackground()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        .position(x: geo.size.width / 5, y: geo.size.height / 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)

                // Orange overlay
                Color.backgroundPrimary.opacity(0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all, edges: .all)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // Helper function to calculate dynamic typing delay based on text length
    private func calculateTypingDelay(for text: String) -> Double {
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        let characterCount = text.count
        
        // Reduced base delay for more responsive feel
        let baseDelay: Double = 0.8
        
        // Reduced word delay for faster responses
        let wordDelay = Double(wordCount) * 0.08
        
        // Reduced character delay for long messages
        let characterDelay = characterCount > 200 ? Double(characterCount - 200) * 0.005 : 0
        
        // Reduced maximum delay cap
        let maxDelay: Double = 4.0
        let calculatedDelay = baseDelay + wordDelay + characterDelay
        
        return min(calculatedDelay, maxDelay)
    }
    
    private func startConversation() {
        showInteractivePicker = false
        showInputField = false
        showSecondaryElements = false
        
        let initialMessage = onboardingConversationSteps[0].message
        let typingDelay = calculateTypingDelay(for: initialMessage)
        
        // Add initial message with dynamic typing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                isTyping = false
                let aiMessage = ChatMessage(
                    text: initialMessage,
                    isUser: false,
                    timestamp: Date()
                )
                withAnimation {
                    messages.append(aiMessage)
                }
                
                // Show input field or interactive picker after message appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showSecondaryElements = true
                        if onboardingConversationSteps[0].inputType == "text" {
                            showInputField = true
                            
                            // Start speech tutorial only on the first step
                            if currentStep == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // Removed speech tutorial
                                }
                            }
                        } else if onboardingConversationSteps[0].inputType == "date" || 
                                onboardingConversationSteps[0].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleSendWithRecordingCheck() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            highlightInputField = true
            // Optionally shake or vibrate here
            return
        }
        highlightInputField = false
        handleUserInput(input: currentInput)
    }
    
    private func handleUserInput(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Stop tutorial when user provides input
        tutorialManager.stopTutorial()
        
        // Check if the next step will use an interactive picker
        let nextStepWillUsePicker = currentStep + 1 < onboardingConversationSteps.count && 
                                   (onboardingConversationSteps[currentStep + 1].inputType == "date" || 
                                    onboardingConversationSteps[currentStep + 1].inputType == "time")
        
        // Hide interactive elements when user provides input
        // Only hide picker if next step won't use one
        if !nextStepWillUsePicker {
            showInteractivePicker = false
        }
        showInputField = false
        showSecondaryElements = false
        
        // Add user message
        let userMessage = ChatMessage(
            text: input,
            isUser: true,
            timestamp: Date()
        )
        withAnimation {
            messages.append(userMessage)
        }
        
        // Store user data
        storeUserData(input: input, step: onboardingConversationSteps[currentStep])
        
        // Clear the text field after submission
        currentInput = ""
        
        // Move to next step
        currentStep += 1
        
        // Add AI response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if currentStep < onboardingConversationSteps.count {
                let nextMessage = onboardingConversationSteps[currentStep].message
                let personalizedMessage = personalizeMessage(nextMessage, with: userData.firstName)
                addAIMessage(personalizedMessage)
            }
        }
    }
    
    private func addAIMessage(_ text: String) {
        isTyping = true
        showInputField = false
        // Only hide picker if the current step doesn't use one
        if currentStep >= onboardingConversationSteps.count || 
           (onboardingConversationSteps[currentStep].inputType != "date" && 
            onboardingConversationSteps[currentStep].inputType != "time") {
            showInteractivePicker = false
        }
        showSecondaryElements = false
        
        let typingDelay = calculateTypingDelay(for: text)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
            isTyping = false
            let aiMessage = ChatMessage(
                text: text,
                isUser: false,
                timestamp: Date()
            )
            withAnimation {
                messages.append(aiMessage)
            }
            
            // Show input field or interactive picker after message appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showSecondaryElements = true
                    if currentStep < onboardingConversationSteps.count {
                        if onboardingConversationSteps[currentStep].inputType == "text" {
                            showInputField = true
                            
                            // Start speech tutorial only on the first step
                            if currentStep == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // Removed speech tutorial
                                }
                            }
                        } else if onboardingConversationSteps[currentStep].inputType == "date" || 
                                onboardingConversationSteps[currentStep].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private func storeUserData(input: String, step: ConversationStep) {
        switch step.dataKey {
        case "firstName":
            userData.firstName = input
        case "birthDate":
            userData.birthDate = input
            userData.zodiacSign = determineZodiacSign(from: input)
        case "birthTime":
            userData.birthTime = input
        case "intuition":
            // Get the personalized question text
            let questionText = personalizeMessage(step.message, with: userData.firstName)
            userData.responses.append((questionText, "intuition", input))
        case "energy":
            // Get the personalized question text
            let questionText = personalizeMessage(step.message, with: userData.firstName)
            userData.responses.append((questionText, "energy", input))
        case "dreams":
            // Get the personalized question text
            let questionText = personalizeMessage(step.message, with: userData.firstName)
            userData.responses.append((questionText, "dreams", input))
        default:
            break
        }
    }
    
    private func personalizeMessage(_ message: String, with name: String) -> String {
        return message.replacingOccurrences(of: "{name}", with: name)
    }
    
    private func determineZodiacSign(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if let date = formatter.date(from: dateString) {
            do {
                let zodiacSign = try ZodiacUtility.getZodiacSign(from: date)
                
                // Trigger badge acquisition animation, swapping the image mid-way
                triggerBadgeAnimation(andSwapTo: zodiacSign.assetName)
                
                return zodiacSign.rawValue
            } catch {
                print("Error determining zodiac sign: \(error)")
                return "Unknown"
            }
        }
        
        return "Unknown"
    }
    
    private func triggerBadgeAnimation(andSwapTo newAssetName: String) {
        isAcquiringBadge = true
        
        // Phase 1 & 2: Build up cosmic effects and scale up badge
                    withAnimation(Animation.easeInOut(duration: 0.8)) { cosmicGlowOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                badgeScale = 1.3
                badgeRotation = 15
            }
            withAnimation(Animation.easeInOut(duration: 1.0)) { nebulaOpacity = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(Animation.easeInOut(duration: 0.8)) {
                starFieldOpacity = 1.0
                cosmicParticlesOpacity = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(Animation.easeInOut(duration: 0.3)) { sparkleOpacity = 1.0 }
        }

        // Phase 3: Funnel effect - spin and shrink
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.linear(duration: 0.8)) {
                badgeRotation += 1080 // Spin 3 times
                badgeScale = 0.01 // Shrink to almost nothing
            }
        }
        
        // Phase 4: Swap image and pop it into view
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // After funnel
            // Instantly swap image and reset rotation
            self.currentProfileImage = newAssetName
            self.badgeRotation = 0
            
            // Pop out with spring animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                badgeScale = 1.0
            }
        }
        
        // Phase 5: Fade out all cosmic effects
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(Animation.easeInOut(duration: 0.8)) {
                sparkleOpacity = 0.0
                cosmicParticlesOpacity = 0.0
                starFieldOpacity = 0.0
                nebulaOpacity = 0.0
                cosmicGlowOpacity = 0.0
            }
        }
        
        // Phase 6: Reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            isAcquiringBadge = false
        }
    }
    
    private func saveOnboardingData() {
        print("💾 Saving onboarding data to Core Data...")
        print("👤 User data: \(userData)")
        
        // Generate a temporary UUID for onboarding
        let onboardingUUID = UUID().uuidString
        print("🆔 Generated onboarding UUID: \(onboardingUUID)")
        
        // Store the onboarding UUID for later use
        UserDefaults.standard.set(onboardingUUID, forKey: "onboardingUUID")
        
        // Save the user data to Core Data with the temporary UUID
        userDataManager?.saveUserData(userData, userId: onboardingUUID)
        
        // Save completion flag to UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Award stardust for completing onboarding
        if let stardustManager = stardustManager {
            stardustManager.earnOnboardingReward()
            print("🪙 Awarded onboarding stardust reward")
        } else {
            print("⚠️ StardustManager not available for onboarding reward")
        }
        
        print("✅ Onboarding data saved successfully to Core Data!")
        print("🎯 hasCompletedOnboarding set to: \(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))")
        print("🆔 Onboarding UUID stored: \(onboardingUUID)")
    }
    
    private func generateWelcomeHoroscope() async {
        print("✨ ConversationalOnboardingView: Starting welcome horoscope generation...")
        print("📊 User data for horoscope generation:")
        print("   - First Name: \(userData.firstName)")
        print("   - Birth Date: \(userData.birthDate)")
        print("   - Birth Time: \(userData.birthTime)")
        print("   - Zodiac Sign: \(userData.zodiacSign)")
        print("   - Responses count: \(userData.responses.count)")
        
        let onboardingAI = OnboardingAI()
        await onboardingAI.generateWelcomeHoroscope(
            firstName: userData.firstName,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            zodiacSign: userData.zodiacSign,
            responses: userData.responses
        )
        
        if let horoscope = onboardingAI.generatedHoroscope {
            print("🎉 ConversationalOnboardingView: Welcome Horoscope Generated Successfully!")
            print("📜 Horoscope Content:")
            print(String(repeating: "=", count: 50))
            print(horoscope)
            print(String(repeating: "=", count: 50))
            
            // Save horoscope to Core Data
            await saveHoroscopeToCoreData(horoscope)
            
        } else if let error = onboardingAI.error {
            print("❌ ConversationalOnboardingView: Failed to generate horoscope: \(error)")
            await MainActor.run {
                zodiacAlertMessage = error
                showZodiacAlert = true
                isTyping = false
                showInputField = true
                showSecondaryElements = true
            }
        } else {
            print("⚠️ ConversationalOnboardingView: Horoscope generation completed but no result received")
        }
    }
    
    private func saveHoroscopeToCoreData(_ horoscope: String) async {
        print("💾 Saving horoscope to Core Data...")
        
        // Ensure we have a UserDataManager
        if userDataManager == nil {
            userDataManager = UserDataManager(modelContext: modelContext)
        }
        
        // Get the onboarding UUID if it exists
        let onboardingUUID = UserDefaults.standard.string(forKey: "onboardingUUID")
        print("🆔 Using onboarding UUID for horoscope save: \(onboardingUUID ?? "nil")")
        
        // Load the existing user data from Core Data
        if let existingUserData = userDataManager?.loadUserData(for: onboardingUUID) {
            print("📝 Updating existing user data with horoscope...")
            print("🔍 Before update - firstName: \(existingUserData.firstName), horoscope: \(existingUserData.welcomeHoroscope?.prefix(30) ?? "nil")")
            existingUserData.welcomeHoroscope = horoscope
            existingUserData.updatedAt = Date()
            
            do {
                try modelContext.save()
                print("✅ Horoscope saved to Core Data successfully!")
                print("🌟 Horoscope length: \(horoscope.count) characters")
                print("🔍 After save - firstName: \(existingUserData.firstName), horoscope: \(existingUserData.welcomeHoroscope?.prefix(30) ?? "nil")")
                
                // Award stardust for horoscope generation
                if let stardustManager = stardustManager {
                    stardustManager.earnHoroscopeGenerationReward()
                    print("🪙 Awarded horoscope generation stardust reward")
                } else {
                    print("⚠️ StardustManager not available for horoscope reward")
                }
                
                // Post notification to update OnboardingHoroscopeView
                await MainActor.run {
                    print("📢 ConversationalOnboardingView: Posting horoscopeGenerated notification...")
                    NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
                    print("✅ ConversationalOnboardingView: horoscopeGenerated notification posted successfully")
                }
            } catch {
                print("❌ Error saving horoscope to Core Data: \(error)")
            }
        } else {
            print("⚠️ No existing user data found in Core Data, creating new entry...")
            
            // Create a new UserDataModel with the horoscope
            let responses = userData.responses.map { "\($0.0)|\($0.1)|\($0.2)" }
            let userDataModel = UserDataModel(
                firstName: userData.firstName,
                birthDate: userData.birthDate,
                birthTime: userData.birthTime,
                zodiacSign: userData.zodiacSign,
                responses: responses,
                userId: onboardingUUID,
                welcomeHoroscope: horoscope
            )
            
            modelContext.insert(userDataModel)
            
            do {
                try modelContext.save()
                print("✅ New user data with horoscope saved to Core Data successfully!")
                print("🔍 New record - firstName: \(userDataModel.firstName), horoscope: \(userDataModel.welcomeHoroscope?.prefix(30) ?? "nil")")
                
                // Award stardust for horoscope generation
                if let stardustManager = stardustManager {
                    stardustManager.earnHoroscopeGenerationReward()
                    print("🪙 Awarded horoscope generation stardust reward")
                } else {
                    print("⚠️ StardustManager not available for horoscope reward")
                }
                
                // Post notification to update OnboardingHoroscopeView
                await MainActor.run {
                    print("📢 ConversationalOnboardingView: Posting horoscopeGenerated notification...")
                    NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
                    print("✅ ConversationalOnboardingView: horoscopeGenerated notification posted successfully")
                }
            } catch {
                print("❌ Error saving new user data with horoscope to Core Data: \(error)")
            }
        }
    }
}











// Break out the chat content into a separate view
struct ChatContentView: View {
    let messages: [ChatMessage]
    let currentStep: Int
    let onboardingConversationSteps: [ConversationStep]
    let showInteractivePicker: Bool
    let showSecondaryElements: Bool
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let isTyping: Bool
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let tutorialManager: TutorialManager // <-- Add this
    let onBubbleSizeChange: ((ChatMessage, CGSize) -> Void)?
    
    init(messages: [ChatMessage], currentStep: Int, onboardingConversationSteps: [ConversationStep], showInteractivePicker: Bool, showSecondaryElements: Bool, selectedDate: Binding<Date>, selectedTime: Binding<Date>, isTyping: Bool, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, tutorialManager: TutorialManager, onBubbleSizeChange: ((ChatMessage, CGSize) -> Void)? = nil) {
        self.messages = messages
        self.currentStep = currentStep
        self.onboardingConversationSteps = onboardingConversationSteps
        self.showInteractivePicker = showInteractivePicker
        self.showSecondaryElements = showSecondaryElements
        self.selectedDate = selectedDate
        self.selectedTime = selectedTime
        self.isTyping = isTyping
        self.onDateSelected = onDateSelected
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.tutorialManager = tutorialManager
        self.onBubbleSizeChange = onBubbleSizeChange
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(messages) { message in
                ChatBubble(
                    message: message,
                    onSizeChange: { size in
                        onBubbleSizeChange?(message, size)
                    }
                )
                .id(message.id)
                .transition(.opacity)
            }
            // Remove the tutorial popup from here
            
            if currentStep < onboardingConversationSteps.count {
                let showPicker = !onboardingConversationSteps[currentStep].isFinal &&
                                 showInteractivePicker &&
                                 showSecondaryElements

                InteractivePickerView(
                    step: onboardingConversationSteps[currentStep],
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime
                )
                .opacity(showPicker ? 1 : 0)
                .allowsHitTesting(showPicker)
            }
            
            TypingIndicator(isAnimating: isTyping)
                .opacity(isTyping ? 1 : 0)
                .id("typingIndicator")

            // Ensure we always have a bottom anchor for scrolling
            Color.clear
                .frame(height: 1)
                .id("chatBottom")
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                print("--- minY: \(geo.frame(in: .global).minY), maxY: \(geo.frame(in: .global).maxY)")
                            }
                    }
                )
        }
        .padding(.horizontal)
        .padding(.bottom, 12) // Ensure minimum 12px padding from bottom
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showSecondaryElements)
    }
}

// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let onboardingConversationSteps: [ConversationStep]
    let showInputField: Bool
    let showSecondaryElements: Bool
    let currentInput: Binding<String>
    let onSend: () -> Void
    let isTextFieldFocused: FocusState<Bool>.Binding
    let onFrameChange: (CGRect) -> Void
    let tutorialManager: TutorialManager
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
        
    var body: some View {
        if currentStep < onboardingConversationSteps.count && !onboardingConversationSteps[currentStep].isFinal {
            let isVisible = onboardingConversationSteps[currentStep].inputType == "text" &&
                            showInputField &&
                            showSecondaryElements
            
            VStack(spacing: 0) {
                // Input section
                InputSection(
                    currentInput: currentInput,
                    currentStep: onboardingConversationSteps[currentStep],
                    onSend: onSend,
                    isTextFieldFocused: isTextFieldFocused,
                    onFrameChange: onFrameChange,
                    highlightInputField: $highlightInputField,
                    onHeightChange: onHeightChange
                )
                .background(Color.white.opacity(0.08))
                .cornerRadius(16)
                .transition(.opacity)
                .opacity(isVisible ? 1 : 0)
                .allowsHitTesting(isVisible)
            }
            .padding(.bottom, 12) // Ensure minimum 12px padding from bottom
        }
    }
}





#Preview {
    ConversationalOnboardingView()
}

// Unified Scroll Manager for efficient scrolling
class ScrollManager: ObservableObject {
    private var scrollWorkItem: DispatchWorkItem?
    private var lastScrollTime: Date = Date()
    private let minimumScrollInterval: TimeInterval = 0.1
    
    enum ScrollTarget {
        case bottom
        case input
        case picker
        case typing
        case lastMessage
    }
    
    func scheduleScroll(to target: ScrollTarget, proxy: ScrollViewProxy, delay: Double = 0.0, messageId: UUID? = nil) {
        // Cancel any pending scroll
        scrollWorkItem?.cancel()
        
        // Check if enough time has passed since last scroll
        let timeSinceLastScroll = Date().timeIntervalSince(lastScrollTime)
        var adjustedDelay = delay
        if timeSinceLastScroll < minimumScrollInterval {
            adjustedDelay += minimumScrollInterval - timeSinceLastScroll
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performScroll(to: target, proxy: proxy, messageId: messageId)
            self?.lastScrollTime = Date()
        }
        
        scrollWorkItem = workItem
        
        if adjustedDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + adjustedDelay, execute: workItem)
        } else {
            DispatchQueue.main.async(execute: workItem)
        }
    }
    
    private func performScroll(to target: ScrollTarget, proxy: ScrollViewProxy, messageId: UUID? = nil) {
        withAnimation(.easeInOut(duration: 0.4)) {
            switch target {
            case .bottom:
                proxy.scrollTo("bottom", anchor: .bottom)
            case .input:
                proxy.scrollTo("inputSection", anchor: .bottom)
            case .picker:
                proxy.scrollTo("interactivePicker", anchor: .center)
            case .typing:
                proxy.scrollTo("typingIndicator", anchor: .center)
            case .lastMessage:
                if let messageId = messageId {
                    proxy.scrollTo(messageId, anchor: .center)
                } else {
                    proxy.scrollTo("chatBottom", anchor: .center)
                }
            }
        }
    }
    
    func cancelPendingScroll() {
        scrollWorkItem?.cancel()
    }
}

// Preference key for header height
struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




