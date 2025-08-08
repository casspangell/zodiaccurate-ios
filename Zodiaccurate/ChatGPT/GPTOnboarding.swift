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
    static func personalizeOnboardingMessage(_ message: String, with userData: User, previousResponses: [String] = []) async -> String {
        let systemMessage = """
        You are a warm, intuitive AI chatbot conducting an onboarding conversation. 
        You have access to the user's name, birth date, birth time, and zodiac sign.
        You should reference their previous responses to create a natural, flowing conversation.
        Keep the tone warm and personal but not overly flowery or mystical.
        Be conversational and natural - like talking to a friend.
        Keep the response concise and genuine.
        Don't restate date of birth or time.
        Don't assume the user's gender.
        IMPORTANT: Respond as if you're having a real conversation, acknowledging their previous answers.
        """
        
        let previousResponsesText = previousResponses.isEmpty ? "" : """
        
        Previous User Responses:
        \(previousResponses.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        """
        
        let userPrompt = """
        Please personalize this message for the user, taking into account their previous responses:
        
        Original Message: "\(message)"
        
        User Information:
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)\(previousResponsesText)
        
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

