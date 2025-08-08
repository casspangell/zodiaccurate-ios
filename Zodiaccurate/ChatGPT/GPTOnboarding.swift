//
//  GPTOnboarding.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import Foundation

// MARK: - GPT Onboarding Service
struct GPTOnboarding {
    
    // MARK: - Personalize Message
    static func personalizeOnboardingMessage(_ message: String, with userData: User) async -> String {
        let systemMessage = """
        You are a mystical, intuitive AI that personalizes messages for users during onboarding. 
        You have access to their name, birth date, birth time, and zodiac sign. 
        Make the message feel personal and magical while maintaining the original intent and tone.
        Keep the response concise and natural - don't over-explain or be too verbose.
        Don't restate date of birth or time.
        """
        
        let userPrompt = """
        Please personalize this message for the user:
        
        Original Message: "\(message)"
        
        User Information:
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)
        
        Please return only the personalized message, nothing else.
        """
        
        do {
            let personalizedMessage = try await ChatGPT.callChatGPTAPI(
                with: userPrompt,
                systemMessage: systemMessage
            )
            
            // Remove double quotes from the beginning and end of the response
            let cleanedMessage = personalizedMessage
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            print("🤖 GPTOnboarding - Original: '\(message)'")
            print("🤖 GPTOnboarding - Personalized: '\(cleanedMessage)'")
            
            return cleanedMessage
        } catch {
            print("❌ GPTOnboarding - Failed to personalize message: \(error)")
            // Return original message if API call fails
            return message
        }
    }
}

