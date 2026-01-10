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
    @StateObject private var userProfileManager = UserProfileManager()
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
    @State private var currentStepIndex: Int = 0
    @State private var onboardingResponses: [String: String] = [:]
    let triggerBadgeAnimation: (String) -> Void
    
    var onComplete: () -> Void = {}
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
    init(onComplete: @escaping () -> Void = {}, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil, triggerBadgeAnimation: @escaping (String) -> Void) {
        self.onComplete = onComplete
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
        self.triggerBadgeAnimation = triggerBadgeAnimation
    }
    
    // MARK: - User Data Management
    
    private func saveUserData() {
        // Just log the current user data - no persistence needed during onboarding
        print("👤 User data updated - Name: '\(user.firstName)', Zodiac: '\(user.zodiacSign)'")
    }
    
    private func updateUserData(input: String, step: ConversationStep) {
        // Store the question and answer pair
        // Use the personalized question message if available, otherwise use the step message
        let personalizedQuestion = personalizeMessage(step.message, with: user.firstName)
        
        // Store answer with dataKey as the key
        onboardingResponses[step.dataKey] = input
        
        // Store question with "question_{dataKey}" as the key
        let questionKey = "question_\(step.dataKey)"
        onboardingResponses[questionKey] = personalizedQuestion
        
        // Also store individual keys in UserDefaults for backward compatibility
        UserDefaults.standard.set(personalizedQuestion, forKey: questionKey)
        UserDefaults.standard.set(input, forKey: step.dataKey)
        
        // Store all onboarding responses (including both Q&A) as a dictionary in UserDefaults for Firebase
        UserDefaults.standard.set(onboardingResponses, forKey: "onboardingResponses")
        
        print("💾 Stored Q&A - Question: '\(personalizedQuestion)', Answer: '\(input)', Key: '\(step.dataKey)'")
        
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
                triggerBadgeAnimation(assetName)
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
            timezone: user.timezone,
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

        // Persist onboarding user data into UserProfileManager (UserDefaults)
        userProfileManager.updateFirstName(user.firstName)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        if let parsedBirthDate = dateFormatter.date(from: user.birthDate) {
            userProfileManager.updateBirthDate(parsedBirthDate)
        } else {
            print("⚠️ Failed to parse birthDate '\(user.birthDate)' with .medium format")
        }
        if let parsedBirthTime = timeFormatter.date(from: user.birthTime) {
            userProfileManager.updateBirthTime(parsedBirthTime)
        } else {
            print("⚠️ Failed to parse birthTime '\(user.birthTime)' with .short format")
        }
        do {
            try userProfileManager.saveChanges()
            print("✅ UserProfileManager saved onboarding data to UserDefaults")
        } catch {
            print("❌ Failed saving onboarding data via UserProfileManager: \(error)")
        }
        
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
        
        // Save onboarding responses to Firebase if user is authenticated
        if let userId = authManager.user?.uid, !onboardingResponses.isEmpty {
            Task {
                do {
                    let firebaseService = FirebaseDatabaseService()
                    try await firebaseService.saveQuestionnaireResponses(
                        userId: userId,
                        questionnaireTitle: "Onboarding",
                        responses: onboardingResponses
                    )
                    print("✅ Saved onboarding questionnaire to Firebase: /responses/\(userId)/Onboarding")
                } catch {
                    print("⚠️ Failed to save onboarding questionnaire to Firebase: \(error)")
                }
            }
        }
        
        // Generate welcome horoscope
        Task {
            let horoscope = await GPTOnboarding.generateWelcomeHoroscope(for: user)
            
            // Save horoscope to SwiftData
            do {
                modelContext.insert(horoscope)
                try modelContext.save()
                print("✅ Welcome horoscope saved to SwiftData successfully")
                
                // Save horoscope to Firebase if user is authenticated
                if let userId = authManager.user?.uid {
                    do {
                        let firebaseService = FirebaseDatabaseService()
                        try await firebaseService.saveHoroscope(userId: userId, horoscope: horoscope)
                        print("✅ Welcome horoscope saved to Firebase: /zodiac/\(userId)/welcome")
                    } catch {
                        print("❌ Failed to save welcome horoscope to Firebase: \(error)")
                        // Continue even if Firebase save fails
                    }
                } else {
                    print("⚠️ No user ID available to save welcome horoscope to Firebase")
                }
                
                // Notify that welcome horoscope is ready
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .welcomeHoroscopeReady, object: nil)
                }
            } catch {
                print("❌ Failed to save horoscope to SwiftData: \(error)")
            }
        }
        
        // Initialize StardustManager for animation
        if stardustManager == nil {
            let userId = authManager.user?.uid
            stardustManager = StardustManager(userId: userId)
        } else {
            // Update userId if it changed
            stardustManager?.userId = authManager.user?.uid
        }
        
        // Load stardust data from SwiftData for animation
        stardustManager?.loadFromSwiftData(stardust)
        
        // Don't trigger stardust animation immediately - it will be triggered after tutorial dismissal
        // The animation will be handled in MainZodiacView after the stardust tutorial is dismissed
        
        // Delay the view switch to allow for tutorial display
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        ZStack(alignment: .top) {
            // Chat view extends full screen behind header
            ZodiacChatView(
                conversationSteps: onboardingConversationSteps,
                profileImage: currentProfileImage,
                userName: $user.firstName,
                userData: user,
                onUserDataUpdate: { input, step in
                    updateUserData(input: input, step: step)
                },
                onStepComplete: { step in
                    currentStepIndex = step
                    // Handle step completion if needed
                    //                        print("👤 Completed step \(step)")
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
                triggerBadgeAnimation: triggerBadgeAnimation,
                backgroundColor: backgroundColor,
                bubbleColor: bubbleColor,
                currentStepIndex: $currentStepIndex
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            
            // Header positioned on top
            ZodiacHeader(
                profileImage: "logo",
                displayMode: .initial
            )
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.all, edges: .top)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
        .onAppear {
            // Initialize the user with current timestamp
            user = User(createdAt: Date(), updatedAt: Date())
            // Initialize stardust with 0 balance
            stardust = Stardust(balance: 0)
            // Clear previous onboarding responses
            onboardingResponses = [:]
            UserDefaults.standard.removeObject(forKey: "onboardingResponses")
            print("👤 New onboarding session started")
            print("🪙 Stardust initialized with balance: \(stardust.balance)")
        }
        .animation(Animation.easeInOut(duration: 0.7), value: isOnboardingComplete)
    }
}

#Preview {
    ConversationalOnboardingView(
        bubbleColor: .active,
        triggerBadgeAnimation: { _ in }
    )
}




