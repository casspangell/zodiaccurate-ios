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
        
        CRITICAL RULES - YOU MUST FOLLOW THESE:
        1. ONLY use information that is explicitly provided in the User Information section below.
        2. If a field says "Unknown" or is empty, DO NOT make up or infer any information about it.
        3. DO NOT add details, facts, or assumptions that were not provided by the user.
        4. DO NOT reference zodiac sign traits, characteristics, or predictions unless the user explicitly mentioned them.
        5. ONLY reference previous responses that are explicitly listed in the "Previous User Responses" section.
        6. If the user hasn't provided information about something, DO NOT mention it or make assumptions about it.
        7. Keep the original message's core meaning - only personalize it using the EXACT information provided.
        
        IMPORTANT: Respond as if you're having a real conversation, acknowledging their previous answers, but ONLY use information they have actually provided.
        """
        
        let previousResponsesText = previousResponses.isEmpty ? "" : """
        
        Previous User Responses:
        \(previousResponses.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        """
        
        let userPrompt = """
        Please personalize this message for the user, taking into account their previous responses.
        
        CRITICAL: You may ONLY use the information explicitly provided below. Do NOT add, infer, or assume any information that is not listed.
        
        Original Message: "\(message)"
        
        User Information (ONLY use what is provided - if it says "Unknown", do not use it):
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)\(previousResponsesText)
        
        Please return only the personalized message, nothing else. Only reference information that is explicitly provided above.
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
    
    // MARK: - Enhanced Personalize Message for All Questionnaires
    static func personalizeQuestionnaireMessage(
        _ message: String,
        with userData: User,
        questionnaireTopic: String,
        previousResponses: [String] = [],
        otherQuestionnaireResponses: [String: [String: String]] = [:]
    ) async -> String {
        let topicDisplayName = getTopicDisplayName(topic: questionnaireTopic)
        
        let systemMessage = """
        You are a warm, intuitive AI chatbot conducting a personalized questionnaire conversation about \(topicDisplayName).
        You have access to the user's name, birth date, birth time, zodiac sign, and their previous responses from this questionnaire and other questionnaires.
        You should reference their previous responses to create a natural, flowing conversation that feels deeply personal.
        Keep the tone warm and personal but not overly flowery or mystical.
        Be conversational and natural - like talking to a friend who knows you well.
        Keep the response concise and genuine.
        Don't restate date of birth or time.
        Don't assume the user's gender.
        
        CRITICAL RULES - YOU MUST FOLLOW THESE:
        1. ONLY use information that is explicitly provided in the User Information section below.
        2. If a field says "Unknown" or is empty, DO NOT make up or infer any information about it.
        3. DO NOT add details, facts, or assumptions that were not provided by the user.
        4. DO NOT reference zodiac sign traits, characteristics, or predictions unless the user explicitly mentioned them in their responses.
        5. ONLY reference previous responses that are explicitly listed in the "Previous Responses" sections.
        6. When using insights from other questionnaires, ONLY reference the exact key-value pairs provided - do not infer or expand on them.
        7. If the user hasn't provided information about something, DO NOT mention it or make assumptions about it.
        8. Keep the original message's core meaning - only personalize it using the EXACT information provided.
        9. DO NOT make connections or inferences that aren't explicitly stated in the provided responses.
        
        IMPORTANT: Use insights from their other questionnaire responses to make connections ONLY when the information is explicitly provided. Respond as if you're having a real conversation, acknowledging their previous answers, but ONLY use information they have actually provided.
        """
        
        // Format previous responses from current questionnaire
        let currentResponsesText = previousResponses.isEmpty ? "" : """
        
        Previous Responses in This Questionnaire:
        \(previousResponses.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        """
        
        // Format responses from other questionnaires
        var otherResponsesText = ""
        if !otherQuestionnaireResponses.isEmpty {
            otherResponsesText = "\n\nInsights from Other Questionnaires:\n"
            for (topic, responses) in otherQuestionnaireResponses.sorted(by: { $0.key < $1.key }) {
                let topicName = getTopicDisplayName(topic: topic)
                if !responses.isEmpty {
                    otherResponsesText += "\n\(topicName):\n"
                    for (key, value) in responses.sorted(by: { $0.key < $1.key }) {
                        // Only include meaningful responses (not empty or question keys)
                        if !key.hasPrefix("question_") && !value.isEmpty && value.count > 3 {
                            otherResponsesText += "  - \(key): \(value)\n"
                        }
                    }
                }
            }
        }
        
        let userPrompt = """
        Please personalize this message for the user, taking into account their previous responses and insights from other questionnaires.
        
        CRITICAL: You may ONLY use the information explicitly provided below. Do NOT add, infer, or assume any information that is not listed. Do NOT make connections or inferences beyond what is explicitly stated.
        
        Original Message: "\(message)"
        
        User Information (ONLY use what is provided - if it says "Unknown", do not use it):
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)
        - Current Questionnaire Topic: \(topicDisplayName)\(currentResponsesText)\(otherResponsesText)
        
        Please return only the personalized message, nothing else. Only reference information that is explicitly provided above. Do not add details or make assumptions.
        """
        
        do {
            let response = try await ChatGPT.callChatGPTAPI(
                with: userPrompt,
                systemMessage: systemMessage
            )
            
            let cleanedMessage = response
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            print("🤖 GPTOnboarding [\(topicDisplayName)] - Original: '\(message)'")
            print("🤖 GPTOnboarding [\(topicDisplayName)] - Personalized: '\(cleanedMessage)'")
            
            return cleanedMessage
        } catch {
            print("❌ GPTOnboarding [\(topicDisplayName)] - Failed to personalize message: \(error)")
            return message
        }
    }
    
    // MARK: - Personalize Placeholder Text
    
    static func personalizePlaceholder(
        originalPlaceholder: String,
        questionMessage: String,
        with userData: User,
        questionnaireTopic: String? = nil,
        previousResponses: [String] = [],
        otherQuestionnaireResponses: [String: [String: String]] = [:]
    ) async -> String {
        // If placeholder is empty, don't personalize
        guard !originalPlaceholder.isEmpty else {
            return originalPlaceholder
        }
        
        let topicDisplayName = questionnaireTopic != nil ? getTopicDisplayName(topic: questionnaireTopic!) : "Onboarding"
        
        let systemMessage = """
        You are a warm, intuitive AI chatbot creating helpful placeholder text suggestions for a questionnaire question.
        The placeholder text should be a brief, personalized example or hint that relates to the question being asked.
        Keep it concise (10-30 words), natural, and relevant to the user's context.
        Make it feel personal and relatable based on the user's information and previous responses.
        Don't restate the question - provide a helpful example or hint.
        """
        
        // Format previous responses from current questionnaire
        let currentResponsesText = previousResponses.isEmpty ? "" : """
        
        Previous Responses in This Questionnaire:
        \(previousResponses.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        """
        
        // Format responses from other questionnaires
        var otherResponsesText = ""
        if let topic = questionnaireTopic, !otherQuestionnaireResponses.isEmpty {
            otherResponsesText = "\n\nInsights from Other Questionnaires:\n"
            for (otherTopic, responses) in otherQuestionnaireResponses.sorted(by: { $0.key < $1.key }) {
                if otherTopic != topic {
                    let topicName = getTopicDisplayName(topic: otherTopic)
                    if !responses.isEmpty {
                        otherResponsesText += "\n\(topicName):\n"
                        for (key, value) in responses.sorted(by: { $0.key < $1.key }) {
                            if !key.hasPrefix("question_") && !value.isEmpty && value.count > 3 {
                                otherResponsesText += "  - \(key): \(value)\n"
                            }
                        }
                    }
                }
            }
        }
        
        let userPrompt = """
        Create a personalized placeholder text suggestion for this question:
        
        Question: "\(questionMessage)"
        Original Placeholder: "\(originalPlaceholder)"
        
        User Information:
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)
        - Current Questionnaire Topic: \(topicDisplayName)\(currentResponsesText)\(otherResponsesText)
        
        Please return only the personalized placeholder text (10-30 words), nothing else. Make it feel natural and relevant to the user's context.
        """
        
        do {
            let response = try await ChatGPT.callChatGPTAPI(
                with: userPrompt,
                systemMessage: systemMessage
            )
            
            let cleanedPlaceholder = response
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            print("💡 GPTOnboarding [\(topicDisplayName)] - Original Placeholder: '\(originalPlaceholder)'")
            print("💡 GPTOnboarding [\(topicDisplayName)] - Personalized Placeholder: '\(cleanedPlaceholder)'")
            
            return cleanedPlaceholder
        } catch {
            print("❌ GPTOnboarding [\(topicDisplayName)] - Failed to personalize placeholder: \(error)")
            return originalPlaceholder
        }
    }
    
    // MARK: - Helper Methods
    
    private static func getTopicDisplayName(topic: String) -> String {
        switch topic.lowercased() {
        case "wellness":
            return "Wellness"
        case "relationship":
            return "Relationships"
        case "importantpeople", "important_people":
            return "Important People"
        case "children":
            return "Children"
        case "employment":
            return "Employment"
        case "onboarding":
            return "Onboarding"
        default:
            return topic.capitalized
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
        
        CRITICAL RULES - YOU MUST FOLLOW THESE:
        1. ONLY use information that is explicitly provided in the User Information section below.
        2. If a field says "Unknown" or is empty, DO NOT make up or infer any information about it.
        3. DO NOT add details, facts, or assumptions that were not provided by the user.
        4. DO NOT reference specific zodiac sign traits, characteristics, or predictions unless the user explicitly mentioned them.
        5. You may reference the zodiac sign name if provided, but do not add detailed astrological interpretations or traits.
        6. Keep the message general and welcoming - do not make specific claims about the user's personality, future, or life based on their zodiac sign.
        """
        
        let userPrompt = """
        Create a personalized welcome horoscope for a new user with a title and message.
        
        CRITICAL: You may ONLY use the information explicitly provided below. Do NOT add, infer, or assume any information that is not listed. Do NOT make specific astrological predictions or detailed personality traits.
        
        User Information (ONLY use what is provided - if it says "Unknown", do not use it):
        - Name: \(userData.firstName.isEmpty ? "Unknown" : userData.firstName)
        - Zodiac Sign: \(userData.zodiacSign.isEmpty ? "Unknown" : userData.zodiacSign)
        - Birth Date: \(userData.birthDate.isEmpty ? "Unknown" : userData.birthDate)
        - Birth Time: \(userData.birthTime.isEmpty ? "Unknown" : userData.birthTime)
        
        TASK: Create a welcome horoscope with two parts separated by "|||":
        1. TITLE: A short, captivating title (3-6 words)
        2. MESSAGE: A concise, personalized welcome horoscope in 2-3 short paragraphs (2-3 sentences each)
        
        You may address the user by name if provided, and mention their zodiac sign if provided, but keep it general and welcoming. 
        Make it feel magical and personal, as if the universe is speaking directly to them.
        Keep it warm and encouraging without being overly mystical or making specific predictions.
        Do NOT add detailed astrological interpretations or personality traits.
        
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

