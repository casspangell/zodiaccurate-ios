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
            let response = try await ChatGPT.callChatGPTAPI(
                with: userPrompt,
                systemMessage: systemMessage
            )
            
            // Remove double quotes from the beginning and end of the response
            let cleanedMessage = response
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
    
    // MARK: - Welcome Horoscope Generation
    
    static func generateWelcomeHoroscope(for userData: User) async -> Horoscope {
        print("✨ Generating welcome horoscope for \(userData.firstName)...")
        
        let systemMessage = """
        You are a mystical, captivating astrologer who creates deeply personal and enchanting horoscopes. 
        Your mission is to create a short, magical welcome horoscope for a new user.
        Keep the tone warm and personal but not overly flowery.
        Make it feel like the universe is speaking directly to them.
        """
        
        let userPrompt = """
        Create a personalized welcome horoscope for a new user with a title and message:
        
        User Information:
        - Name: \(userData.firstName)
        - Zodiac Sign: \(userData.zodiacSign)
        - Birth Date: \(userData.birthDate)
        - Birth Time: \(userData.birthTime)
        
        TASK: Create a welcome horoscope with two parts separated by "|||":
        1. TITLE: A short, captivating title (3-6 words)
        2. MESSAGE: A concise, personalized welcome horoscope in 2-3 short paragraphs (2-3 sentences each)
        
        Address the user by name, reference their zodiac sign and birth details. 
        Make it feel magical and personal, as if the universe is speaking directly to them.
        Keep it warm and encouraging without being overly mystical.
        
        Format: "Title|||Message"
        """
        
        do {
            let response = try await ChatGPT.callChatGPTWithTTS(
                with: userPrompt,
                systemMessage: systemMessage,
                saveKey: "welcome"
            )
            
            // Clean the response
            let cleanedResponse = response.text
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            // Parse the title and message
            let parts = cleanedResponse.components(separatedBy: "|||")
            let title = parts.count > 0 ? parts[0].trimmingCharacters(in: .whitespacesAndNewlines) : "Welcome to Your Cosmic Journey"
            let message = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : cleanedResponse
            
            let horoscope = Horoscope(
                title: title, 
                message: message, 
                key: "welcome",
                audioFilePath: response.audioFilePath
            )
            
            print("✨ Generated welcome horoscope:")
            print("Title: \(horoscope.title)")
            print("Message: \(horoscope.message)")
            if let audioPath = horoscope.audioFilePath {
                print("🎤 TTS audio saved: \(audioPath)")
            }
            
            return horoscope
            
        } catch {
            print("❌ Failed to generate welcome horoscope: \(error)")
            
            // Return a fallback horoscope with TTS
            let fallbackTitle = "Welcome to Your Cosmic Journey"
            let fallbackMessage = """
            Welcome to your cosmic journey, \(userData.firstName)! 
            
            As a \(userData.zodiacSign), you carry unique gifts that the universe has bestowed upon you. Your birth on \(userData.birthDate) at \(userData.birthTime) has created a special alignment that will guide you through life's adventures.
            
            The stars are ready to share their wisdom with you. Your personalized horoscopes will help you navigate life's twists and turns with confidence and grace.
            """
            
            // Generate TTS for fallback message
            var fallbackAudioPath: String?
            do {
                fallbackAudioPath = try await ChatGPT.generateAndSaveTTSAudio(
                    from: fallbackMessage,
                    for: "welcome"
                )
                print("🎤 Generated TTS audio for fallback horoscope")
            } catch {
                print("❌ Failed to generate TTS audio for fallback: \(error)")
                // Continue without audio if TTS fails
            }
            
            let fallbackHoroscope = Horoscope(
                title: fallbackTitle, 
                message: fallbackMessage, 
                key: "welcome",
                audioFilePath: fallbackAudioPath
            )
            print("✅ Using fallback horoscope")
            
            return fallbackHoroscope
        }
    }
}

