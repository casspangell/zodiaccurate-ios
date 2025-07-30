//
//  ConversationalOnboardingView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import SwiftUI
import Combine
import SwiftData

struct ConversationalOnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.modelContext) private var modelContext
    @State private var stardustManager: StardustManager?
    // Create a new User instance for this onboarding session
    @State private var user = User()
    @State private var stardust = Stardust()
    @State private var currentProfileImage = "logo"
    @State private var isAcquiringBadge = false
    @State private var badgeScale: CGFloat = 1.0
    @State private var badgeRotation: Double = 0
    @State private var sparkleOpacity: Double = 0
    @State private var cosmicParticlesOpacity: Double = 0
    @State private var nebulaOpacity: Double = 0
    @State private var starFieldOpacity: Double = 0
    @State private var cosmicGlowOpacity: Double = 0
    @State private var isOnboardingComplete = false
    @State private var showZodiacAlert = false
    @State private var zodiacAlertMessage = ""
    @StateObject private var badgeAnimationManager = BadgeAnimationManager()
    
    var onComplete: () -> Void = {}
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
    init(onComplete: @escaping () -> Void = {}, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil) {
        self.onComplete = onComplete
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
    }
    
    // MARK: - User Data Management
    
    private func saveUserData() {
        // Just log the current user data - no persistence needed during onboarding
        print("👤 User data updated - Name: '\(user.firstName)', Zodiac: '\(user.zodiacSign)'")
    }
    
    private func updateUserData(input: String, step: ConversationStep) {
        // Update the user data based on the conversation step
        switch step.dataKey {
        case "firstName":
            user.firstName = input
            print("👤 Updated firstName: '\(input)'")
            
        case "birthDate":
            user.birthDate = input
            // Recalculate zodiac sign when birth date changes
            if !user.birthTime.isEmpty {
                user.zodiacSign = determineZodiacSign(from: input)
            }
            
            // Trigger badge animation when birth date is selected
            let (zodiacSign, assetName) = determineZodiacSignAndAsset(from: input)
            if zodiacSign != "Unknown" {
                badgeAnimationManager.triggerBadgeAnimation(andSwapTo: assetName)
            }
            
            print("👤 Updated birthDate: '\(input)' - Zodiac: \(zodiacSign)")
            
        case "birthTime":
            user.birthTime = input
            // Recalculate zodiac sign when birth time changes
            if !user.birthDate.isEmpty {
                user.zodiacSign = determineZodiacSign(from: user.birthDate)
            }
            print("👤 Updated birthTime: '\(input)'")
            
        default:
            print("👤 Unknown data key: '\(step.dataKey)'")
        }
        
        // Update the updatedAt timestamp
        user = User(
            firstName: user.firstName,
            birthDate: user.birthDate,
            birthTime: user.birthTime,
            zodiacSign: user.zodiacSign,
            createdAt: user.createdAt,
            updatedAt: Date()
        )
        
        // Save the updated user data
        saveUserData()
    }
    
    private func completeOnboarding() {
        // Log final user data
        print("👤 Onboarding completed - Final user data:")
        print("   Name: '\(user.firstName)'")
        print("   Birth Date: '\(user.birthDate)'")
        print("   Birth Time: '\(user.birthTime)'")
        print("   Zodiac Sign: '\(user.zodiacSign)'")
        print("   Created: \(user.createdAt)")
        print("   Updated: \(user.updatedAt)")
        
        // Add 25 stardust for completing onboarding
        stardust.addStardust(
            amount: 25,
            type: .achievement,
            description: "Completed onboarding and received your first horoscope"
        )
        
        print("🪙 Added 25 stardust for completing onboarding - Balance: \(stardust.balance)")
        
        // Save user and stardust to SwiftData
        do {
            modelContext.insert(user)
            modelContext.insert(stardust)
            try modelContext.save()
            print("✅ User and Stardust saved to SwiftData successfully")
        } catch {
            print("❌ Failed to save user and stardust to SwiftData: \(error)")
        }
        
        // Initialize StardustManager for animation
        if stardustManager == nil {
            stardustManager = StardustManager()
        }
        
        // Load stardust data from SwiftData for animation
        stardustManager?.loadFromSwiftData(stardust)
        
        // Trigger stardust animation
        stardustManager?.earnStardust(
            amount: 25,
            type: .achievement,
            description: "Completed onboarding and received your first horoscope"
        )
        
        // Delay the view switch to allow stardust animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Mark onboarding as complete and transition to MainZodiacView
            withAnimation(.easeInOut(duration: 0.7)) {
                isOnboardingComplete = true
            }
            
            // Call the completion handler
            onComplete()
        }
    }
    
    // MARK: - Helper Functions
    
    // Note: Using global functions from Utils.swift:
    // - personalizeMessage(_:with:) 
    // - determineZodiacSign(from:)
    

    
    var body: some View {
        ZStack {
            if isOnboardingComplete {
                MainZodiacView()
                    .transition(.opacity)
            } else {
                ZodiacChatView(
                    conversationSteps: onboardingConversationSteps,
                    profileImage: currentProfileImage,
                    userName: $user.firstName,
                    onUserDataUpdate: { input, step in
                        updateUserData(input: input, step: step)
                    },
                    onStepComplete: { step in
                        // Handle step completion if needed
                        print("👤 Completed step \(step)")
                    },
                    onConversationComplete: {
                        completeOnboarding()
                    },
                    personalizeMessage: { message, name in
                        // Use the user's actual name from the User instance
                        personalizeMessage(message, with: user.firstName)
                    },
                    determineZodiacSign: { dateString in
                        determineZodiacSign(from: dateString)
                    },
                    triggerBadgeAnimation: { newAssetName in
                        badgeAnimationManager.triggerBadgeAnimation(andSwapTo: newAssetName)
                    },
                    badgeAnimationManager: badgeAnimationManager,
                    backgroundColor: backgroundColor,
                    bubbleColor: bubbleColor
                )
            }
            
            if showZodiacAlert {
                ZodiacAlertView(
                    title: "Horoscope Generation Failed",
                    message: zodiacAlertMessage,
                    primaryButtonTitle: "Try Again",
                    primaryButtonAction: {
                        showZodiacAlert = false
                        // Task { await generateWelcomeHoroscope() }
                    }
                )
            }
            
            // Localized stardust animation is now handled by the profile badge components
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            // Initialize the user with current timestamp
            user = User(createdAt: Date(), updatedAt: Date())
            // Initialize stardust with 0 balance
            stardust = Stardust(balance: 0)
            print("👤 New onboarding session started")
            print("🪙 Stardust initialized with balance: \(stardust.balance)")
        }
        .animation(Animation.easeInOut(duration: 0.7), value: isOnboardingComplete)
    }
}

#Preview {
    ConversationalOnboardingView(bubbleColor: .active)
}




