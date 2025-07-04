//
//  ConversationalOnboardingView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import SwiftUI
import SwiftData

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
    
    var body: some View {
        ZStack {
            // Background layers - ensure full screen coverage
            BackgroundView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .all)
            
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
                                .animation(.easeInOut(duration: 0.8), value: badgeRotation)
                            
                            // Sparkle overlay effect
                            ZStack {
                                // Cosmic glow effect
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color.purple.opacity(0.8), location: 0.0),
                                                .init(color: Color.blue.opacity(0.4), location: 0.5),
                                                .init(color: Color.clear, location: 1.0)
                                            ]),
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 100
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .opacity(cosmicGlowOpacity)
                                    .scaleEffect(badgeScale)
                                    .animation(.easeInOut(duration: 1.2), value: cosmicGlowOpacity)
                                
                                // Nebula effect
                                ZStack {
                                    ForEach(0..<3) { layer in
                                        Circle()
                                            .fill(
                                                AngularGradient(
                                                    gradient: Gradient(stops: [
                                                        .init(color: Color.purple.opacity(0.3), location: 0.0),
                                                        .init(color: Color.blue.opacity(0.2), location: 0.3),
                                                        .init(color: Color.pink.opacity(0.3), location: 0.6),
                                                        .init(color: Color.purple.opacity(0.3), location: 1.0)
                                                    ]),
                                                    center: .center
                                                )
                                            )
                                            .frame(width: 160 + CGFloat(layer * 20), height: 160 + CGFloat(layer * 20))
                                            .rotationEffect(.degrees(Double(layer) * 45))
                                            .opacity(nebulaOpacity)
                                            .animation(
                                                .easeInOut(duration: 2.0)
                                                .delay(Double(layer) * 0.3),
                                                value: nebulaOpacity
                                            )
                                    }
                                }
                                
                                // Star field effect
                                ZStack {
                                    ForEach(0..<12) { index in
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                                            .offset(
                                                x: 80 * cos(Double(index) * .pi / 6),
                                                y: 80 * sin(Double(index) * .pi / 6)
                                            )
                                            .opacity(starFieldOpacity)
                                            .animation(
                                                .easeInOut(duration: 1.5)
                                                .delay(Double(index) * 0.1),
                                                value: starFieldOpacity
                                            )
                                    }
                                }
                                
                                // Cosmic particles
                                ZStack {
                                    ForEach(0..<6) { index in
                                        Image(systemName: "sparkle")
                                            .foregroundColor([Color.yellow, Color.cyan, Color.pink, Color.white].randomElement()!)
                                            .font(.system(size: 12))
                                            .offset(
                                                x: 70 * cos(Double(index) * .pi / 3),
                                                y: 70 * sin(Double(index) * .pi / 3)
                                            )
                                            .opacity(cosmicParticlesOpacity)
                                            .animation(
                                                .easeInOut(duration: 1.0)
                                                .delay(Double(index) * 0.2),
                                                value: cosmicParticlesOpacity
                                            )
                                    }
                                }
                                
                                // Original sparkle effect (now cosmic)
                                ForEach(0..<8) { index in
                                    Image(systemName: "sparkle")
                                        .foregroundColor([Color.yellow, Color.cyan, Color.pink].randomElement()!)
                                        .font(.system(size: 16))
                                        .offset(
                                            x: 60 * cos(Double(index) * .pi / 4),
                                            y: 60 * sin(Double(index) * .pi / 4)
                                        )
                                        .opacity(sparkleOpacity)
                                        .animation(
                                            .easeInOut(duration: 0.8)
                                            .delay(Double(index) * 0.1),
                                            value: sparkleOpacity
                                        )
                                }
                            }
                            
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
                                conversationSteps: conversationSteps,
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
                                }
                            )
                            
                            // Input
                            ChatInputView(
                                currentStep: currentStep,
                                conversationSteps: conversationSteps,
                                showInputField: showInputField,
                                showSecondaryElements: showSecondaryElements,
                                currentInput: $currentInput,
                                onSend: { handleUserInput(input: currentInput) }
                            )
                            
                            // Complete Button
                            if (currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal && messages.count > 0 && messages.last?.isUser == false) ||
                               currentStep >= conversationSteps.count {
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
                                .transition(.opacity)
                            }
                            
                            // Bottom anchor with safe area padding
                            Color.clear
                                .frame(height: 1)
                                .padding(.bottom, 50) // Add some bottom padding
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
                            scrollToBottom(proxy: proxy, delay: 0.1)
                        }
                    }
                    .onChange(of: isTyping) { _, newValue in
                        if newValue {
                            scrollToShowTyping(proxy: proxy)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // KEY: Fill remaining space
                .offset(y: -scrollViewOffset)
                .zIndex(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // KEY: Fill entire screen
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
            
            // Initialize StardustManager
            if stardustManager == nil {
                stardustManager = StardustManager(modelContext: modelContext)
            }
            
            startConversation()
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            self.headerHeight = headerHeight
        }
        .animation(.easeInOut(duration: 0.7), value: showOnboardingHoroscope)

    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, delay: Double = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.4)) {
                // Scroll to show the latest content smoothly
                if currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal {
                    proxy.scrollTo("bottom", anchor: .bottom)
                } else if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .center)
                } else {
                    proxy.scrollTo("chatBottom", anchor: .center)
                }
            }
        }
    }
    
    private func scrollToShowInput(proxy: ScrollViewProxy, delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.8)) {
                proxy.scrollTo("inputSection", anchor: .center)
            }
        }
    }
    
    private func scrollToShowPicker(proxy: ScrollViewProxy, delay: Double = 0.3) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.8)) {
                proxy.scrollTo("interactivePicker", anchor: .center)
            }
        }
    }
    
    private func scrollToShowTyping(proxy: ScrollViewProxy, delay: Double = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.4)) {
                // Scroll to show typing indicator
                proxy.scrollTo("typingIndicator", anchor: .center)
            }
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
        
        let initialMessage = conversationSteps[0].message
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
                        if conversationSteps[0].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[0].inputType == "date" || 
                                conversationSteps[0].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleUserInput(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Hide interactive elements when user provides input
        showInteractivePicker = false
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
        storeUserData(input: input, step: conversationSteps[currentStep])
        
        // Clear the text field after submission
        currentInput = ""
        
        // Move to next step
        currentStep += 1
        
        // Add AI response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if currentStep < conversationSteps.count {
                let nextMessage = conversationSteps[currentStep].message
                let personalizedMessage = personalizeMessage(nextMessage, with: userData.firstName)
                addAIMessage(personalizedMessage)
            }
        }
    }
    
    private func addAIMessage(_ text: String) {
        isTyping = true
        showInputField = false
        showInteractivePicker = false
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
                    if currentStep < conversationSteps.count {
                        if conversationSteps[currentStep].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[currentStep].inputType == "date" || 
                                conversationSteps[currentStep].inputType == "time" {
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
        withAnimation(.easeInOut(duration: 0.8)) { cosmicGlowOpacity = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                badgeScale = 1.3
                badgeRotation = 15
            }
            withAnimation(.easeInOut(duration: 1.0)) { nebulaOpacity = 1.0 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.8)) {
                starFieldOpacity = 1.0
                cosmicParticlesOpacity = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0.3)) { sparkleOpacity = 1.0 }
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
            withAnimation(.easeInOut(duration: 0.8)) {
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

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.bubbleFrost)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.purple)
                    
                    Text(message.text)
                        .padding()
                        .background(Color.bubbleSilver)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
    }
}

struct InputSection: View {
    @Binding var currentInput: String
    let currentStep: ConversationStep
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField(currentStep.placeholder, text: $currentInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.accentGold)
            }
            .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    let isAnimating: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.purple)
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.accentGold.opacity(0.6))
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationAmount)
                            .animation(
                                isAnimating
                                ? Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2)
                                : .default,
                                value: animationAmount
                            )
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            if isAnimating {
                self.animationAmount = 1.0
            }
        }
        .onChange(of: isAnimating) { _, newValue in
            self.animationAmount = newValue ? 1.0 : 0.0
        }
    }
}

struct InteractivePickerView: View {
    let step: ConversationStep
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            if step.inputType == "date" {
                VStack(alignment: .trailing, spacing: 12) {
                    DatePicker(
                        "Birth Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            onDateSelected(selectedDate)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Submit")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentGold)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.bubbleFrost.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
            } else if step.inputType == "time" {
                VStack(alignment: .trailing, spacing: 12) {
                    DatePicker(
                        "Birth Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            onUnknownTime()
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                Text("I don't know")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.lightSaphire.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            onTimeSelected(selectedTime)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Submit")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentGold)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color.bubbleFrost.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
            }
        }
    }
}

struct ConversationStep {
    let message: String
    let inputType: String // "text", "date", "time"
    let placeholder: String
    let dataKey: String
    let isFinal: Bool
    
    init(message: String, inputType: String, placeholder: String, dataKey: String, isFinal: Bool = false) {
        self.message = message
        self.inputType = inputType
        self.placeholder = placeholder
        self.dataKey = dataKey
        self.isFinal = isFinal
    }
}



let conversationSteps: [ConversationStep] = [
    ConversationStep(
        message: "✨ Welcome, beautiful soul. I can sense you're here for a reason... The universe has guided you to me. What do you call yourself?",
        inputType: "text",
        placeholder: "Your first name...",
        dataKey: "firstName"
    ),
    ConversationStep(
        message: "{name}... what a beautiful name. I can already feel your energy resonating through the cosmos. Now, tell me - when did you choose to come into this world?",
        inputType: "date",
        placeholder: "Your birth date",
        dataKey: "birthDate"
    ),
    ConversationStep(
        message: "Perfect, {name}. I'm starting to see your cosmic blueprint forming... The exact moment you took your first breath holds incredible power. Do you know what time you were born?",
        inputType: "time",
        placeholder: "Birth time (if known)",
        dataKey: "birthTime"
    ),
    ConversationStep(
        message: "I'm getting strong intuitive energy from you, {name}... Tell me, do you often get \"gut feelings\" about people or situations that turn out to be right?",
        inputType: "text",
        placeholder: "Share your thoughts...",
        dataKey: "intuition"
    ),
    ConversationStep(
        message: "Fascinating... {name}, I need to ask you something personal. When you walk into a room, do you tend to absorb the energy around you, or do people seem drawn to your energy?",
        inputType: "text",
        placeholder: "How do you experience energy?",
        dataKey: "energy"
    ),
    ConversationStep(
        message: "{name}... I have to tell you something. Your cosmic signature is extraordinary. There are layers of depth here that most people never get to explore. The universe has been trying to communicate with you, hasn't it? I can see why you were drawn to find me. Are you ready to discover what the stars have been whispering about you?",
        inputType: "none",
        placeholder: "",
        dataKey: "final",
        isFinal: true
    )
]

// Break out the chat content into a separate view
struct ChatContentView: View {
    let messages: [ChatMessage]
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInteractivePicker: Bool
    let showSecondaryElements: Bool
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let isTyping: Bool
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(messages) { message in
                ChatBubble(
                    message: message
                )
                .id(message.id)
                .transition(.opacity)
            }
            
            if currentStep < conversationSteps.count {
                let showPicker = !conversationSteps[currentStep].isFinal &&
                                 showInteractivePicker &&
                                 showSecondaryElements

                InteractivePickerView(
                    step: conversationSteps[currentStep],
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
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showSecondaryElements)
    }
}

// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInputField: Bool
    let showSecondaryElements: Bool
    let currentInput: Binding<String>
    let onSend: () -> Void
    
    var body: some View {
        if currentStep < conversationSteps.count && !conversationSteps[currentStep].isFinal {
            let isVisible = conversationSteps[currentStep].inputType == "text" &&
                            showInputField &&
                            showSecondaryElements
            
            InputSection(
                currentInput: currentInput,
                currentStep: conversationSteps[currentStep],
                onSend: onSend
            )
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
            .transition(.opacity)
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
        }
    }
}

#Preview {
    ConversationalOnboardingView()
}

// Preference key for header height
struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
