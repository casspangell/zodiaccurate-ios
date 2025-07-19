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
    
    init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }
    

    
    var body: some View {
        ZStack {
            if showOnboardingHoroscope {
                OnboardingHoroscopeView()
                    .transition(.opacity)
            } else {
                ZodiacChatView(
                    conversationSteps: onboardingConversationSteps,
                    profileImage: currentProfileImage,
                    onUserDataUpdate: { input, step in
                        storeUserData(input: input, step: step)
                    },
                    onStepComplete: { step in
                        // Handle step completion if needed
                    },
                    onConversationComplete: {
                        saveOnboardingData()
                        showOnboardingHoroscope = true
                        
                        // Generate horoscope on background thread
                        // Task {
                        //     await generateWelcomeHoroscope()
                        // }
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
                    badgeAnimationManager: badgeAnimationManager
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
            let (zodiacSign, assetName) = determineZodiacSignAndAsset(from: input)
            userData.zodiacSign = zodiacSign
            
            // Trigger badge acquisition animation, swapping the image mid-way
            badgeAnimationManager.triggerBadgeAnimation(andSwapTo: assetName)
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
    
    // private func generateWelcomeHoroscope() async {
    //     print("✨ ConversationalOnboardingView: Starting welcome horoscope generation...")
    //     print("📊 User data for horoscope generation:")
    //     print("   - First Name: \(userData.firstName)")
    //     print("   - Birth Date: \(userData.birthDate)")
    //     print("   - Birth Time: \(userData.birthTime)")
    //     print("   - Zodiac Sign: \(userData.zodiacSign)")
    //     print("   - Responses count: \(userData.responses.count)")
    //     
    //     let onboardingAI = OnboardingAI()
    //     await onboardingAI.generateWelcomeHoroscope(
    //         firstName: userData.firstName,
    //         birthDate: userData.birthDate,
    //         birthTime: userData.birthTime,
    //         zodiacSign: userData.zodiacSign,
    //         responses: userData.responses
    //     )
    //     
    //     if let horoscope = onboardingAI.generatedHoroscope {
    //         print("🎉 ConversationalOnboardingView: Welcome Horoscope Generated Successfully!")
    //         print("📜 Horoscope Content:")
    //         print(String(repeating: "=", count: 50))
    //         print(horoscope)
    //         print(String(repeating: "=", count: 50))
    //         
    //         // Save horoscope to Core Data
    //         await saveHoroscopeToCoreData(horoscope)
    //         
    //     } else if let error = onboardingAI.error {
    //         print("❌ ConversationalOnboardingView: Failed to generate horosc ope: \(error)")
    //         await MainActor.run {
    //         zodiacAlertMessage = error
    //         showZodiacAlert = true
    //         isTyping = false
    //         showInputField = true
    //         showSecondaryElements = true
    //         }
    //     } else {
    //         print("⚠️ ConversationalOnboardingView: Horoscope generation completed but no result received")
    //     }
    // }
    
    // private func saveHoroscopeToCoreData(_ horoscope: String) async {
    //     print("💾 Saving horoscope to Core Data...")
    //     
    //     // Ensure we have a UserDataManager
    //     if userDataManager == nil {
    //         userDataManager = UserDataManager(modelContext: modelContext)
    //     }
    //     
    //     // Get the onboarding UUID if it exists
    //     let onboardingUUID = UserDefaults.standard.string(forKey: "onboardingUUID")
    //     print("🆔 Using onboarding UUID for horoscope save: \(onboardingUUID ?? "nil")")
    //     
    //     // Load the existing user data from Core Data
    //     if let existingUserData = userDataManager?.loadUserData(for: onboardingUUID) {
    //         print("📝 Updating existing user data with horoscope...")
    //         print("🔍 Before update - firstName: \(existingUserData.firstName), horoscope: \(existingUserData.welcomeHoroscope?.prefix(30) ?? "nil")")
    //         existingUserData.welcomeHoroscope = horoscope
    //         existingUserData.updatedAt = Date()
    //     
    //         do {
    //             try modelContext.save()
    //             print("✅ Horoscope saved to Core Data successfully!")
    //             print("🌟 Horoscope length: \(horoscope.count) characters")
    //             print("🔍 After save - firstName: \(existingUserData.firstName), horoscope: \(existingUserData.welcomeHoroscope?.prefix(30) ?? "nil")")
    //             
    //             // Award stardust for horoscope generation
    //             if let stardustManager = stardustManager {
    //                 stardustManager.earnHoroscopeGenerationReward()
    //                 print("🪙 Awarded horoscope generation stardust reward")
    //             } else {
    //                 print("⚠️ StardustManager not available for horoscope reward")
    //             }
    //             
    //             // Post notification to update OnboardingHoroscopeView
    //             await MainActor.run {
    //                 print("📢 ConversationalOnboardingView: Posting horoscopeGenerated notification...")
    //                 NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
    //                 print("✅ ConversationalOnboardingView: horoscopeGenerated notification posted successfully")
    //             }
    //         } catch {
    //             print("❌ Error saving horoscope to Core Data: \(error)")
    //         }
    //     } else {
    //         print("⚠️ No existing user data found in Core Data, creating new entry...")
    //         
    //         // Create a new UserDataModel with the horoscope
    //         let responses = userData.responses.map { "\($0.0)|\($0.1)|\($0.2)" }
    //         let userDataModel = UserDataModel(
    //             firstName: userData.firstName,
    //             birthDate: userData.birthDate,
    //             birthTime: userData.birthTime,
    //             zodiacSign: userData.zodiacSign,
    //             responses: responses,
    //             userId: onboardingUUID,
    //             welcomeHoroscope: horoscope
    //         )
    //         
    //         modelContext.insert(userDataModel)
    //         
    //         do {
    //                 try modelContext.save()
    //                 print("✅ New user data with horoscope saved to Core Data successfully!")
    //                 print("🔍 New record - firstName: \(userDataModel.firstName), horoscope: \(userDataModel.welcomeHoroscope?.prefix(30) ?? "nil")")
    //                  
    //                 // Award stardust for horoscope generation
    //                 if let stardustManager = stardustManager {
    //                     stardustManager.earnHoroscopeGenerationReward()
    //                     print("🪙 Awarded horoscope generation stardust reward")
    //                 } else {
    //                     print("⚠️ StardustManager not available for horoscope reward")
    //                 }
    //                 
    //                 // Post notification to update OnboardingHoroscopeView
    //                 await MainActor.run {
    //                     print("📢 ConversationalOnboardingView: Posting horoscopeGenerated notification...")
    //                     NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
    //                     print("✅ ConversationalOnboardingView: horoscopeGenerated notification posted successfully")
    //                 }
    //             } catch {
    //                 print("❌ Error saving new user data with horoscope to Core Data: \(error)")
    //             }
    //         }
    //     }
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




