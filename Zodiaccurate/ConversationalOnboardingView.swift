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
    @State private var userData = UserData(firstName: "", birthDate: "", birthTime: "", zodiacSign: "", responses: [])
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
    @StateObject private var badgeAnimationManager = BadgeAnimationManager()

    var onComplete: () -> Void = {}
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
    init(onComplete: @escaping () -> Void = {}, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil) {
        self.onComplete = onComplete
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
    }
    

    
    var body: some View {
        ZStack {
            if showOnboardingHoroscope {
                MainZodiacView()
                    .transition(.opacity)
            } else {
                ZodiacChatView(
                    conversationSteps: onboardingConversationSteps,
                    profileImage: currentProfileImage,
                    userName: $userData.firstName,
                    onUserDataUpdate: { input, step in
                        storeUserData(input: input, step: step)
                        
                        // Handle badge animation for birth date specifically
                        if step.dataKey == "birthDate" {
                            handleZodiacSignAcquisition(from: input)
                        }
                    },
                    onStepComplete: { step in
                        // Handle step completion if needed
                    },
                    onConversationComplete: {
                        saveOnboardingData()
                        showOnboardingHoroscope = true
                        Task {
                            await generateWelcomeHoroscope()
                        }
                    },
                    personalizeMessage: { message, name in
                        personalizeMessage(message, with: name)
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
        }
        .animation(Animation.easeInOut(duration: 0.7), value: showOnboardingHoroscope)
    }
        

    private func storeUserData(input: String, step: ConversationStep) {
        switch step.dataKey {
        case "firstName":
            userData.firstName = input
        case "birthDate":
            userData.birthDate = input
            let (zodiacSign, _) = determineZodiacSignAndAsset(from: input)
            userData.zodiacSign = zodiacSign
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
        
        // Set trial flag to true when user completes onboarding
        UserDefaults.standard.set(true, forKey: "isTrialActive")
        
        // Award stardust for completing onboarding
        if let stardustManager = stardustManager {
            stardustManager.earnOnboardingReward()
            print("🪙 Awarded onboarding stardust reward")
        } else {
            print("⚠️ StardustManager not available for onboarding reward")
        }
        
        print("✅ Onboarding data saved successfully to Core Data!")
        print("🎯 hasCompletedOnboarding set to: \(UserDefaults.standard.bool(forKey: "hasCompletedOnboarding"))")
        print("🎫 Trial flag set to: \(UserDefaults.standard.bool(forKey: "isTrialActive"))")
        print("🆔 Onboarding UUID stored: \(onboardingUUID)")
    }
    
    private func generateWelcomeHoroscope() async {
        print("✨ ConversationalOnboardingView: Starting welcome horoscope generation...")
        let onboardingAI = Onboarding()
        await onboardingAI.generateWelcomeHoroscope(
            firstName: userData.firstName,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            zodiacSign: userData.zodiacSign,
            responses: userData.responses
        )
        if let horoscope = onboardingAI.generatedHoroscope {
            print("🎉 ConversationalOnboardingView: Welcome Horoscope Generated Successfully!")
            print(horoscope)
            await saveHoroscopeToCoreData(horoscope)
        } else if let error = onboardingAI.error {
            print("❌ ConversationalOnboardingView: Failed to generate horoscope: \(error)")
            await MainActor.run {
                zodiacAlertMessage = error
                showZodiacAlert = true
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
    
    // MARK: - Event Handlers
    
    /// Handles badge animation when zodiac sign is determined
    private func handleZodiacSignAcquisition(from dateString: String) {
        let (_, assetName) = determineZodiacSignAndAsset(from: dateString)
        badgeAnimationManager.triggerBadgeAnimation(andSwapTo: assetName)
    }
    
    // MARK: - Data Management
}

#Preview {
    ConversationalOnboardingView(bubbleColor: .active)
}

// Preference key for header height
struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




