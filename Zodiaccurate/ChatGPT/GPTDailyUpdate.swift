//
//  GPTDailyUpdate.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/6/25.
//

import Foundation

// MARK: - Response Bank for Daily Updates
struct GPTDailyUpdate {
    // MARK: - Fallback Response Generator
    static func getRandomResponse() -> (line1: String, line2: String) {
        let fallbackResponses = [
            ("Thanks for sharing!", "I'm here for you"),
            ("Got it!", "Your voice matters"),
            ("I hear you!", "You're doing great"),
            ("Noted!", "You've got this"),
            ("Received!", "You're not alone")
        ]
        return fallbackResponses.randomElement() ?? fallbackResponses[0]
    }
    
    // MARK: - ChatGPT API Integration
    static func generatePersonalizedResponse(for userUpdate: String) async -> (line1: String, line2: String) {
        print("🤖 GPTDailyUpdate: Starting API call for user update: '\(userUpdate)'")
        let prompt = """
        Based on this daily update from a user, generate a personalized response with two parts separated by "|||":
        
        User's update: "\(userUpdate)"
        
        Generate a response that:
        1. Acknowledges their sharing (header - 2-4 words)
        2. Small response regarding the message (subtext - 3-6 words)
        
        Use the tone and style of these examples as a guide:
        - "Thanks for sharing!|||I'm here for you"
        - "Got it!|||Your voice matters"
        - "I hear you!|||You're doing great"
        
        Keep each part concise and warm. Respond with only the two parts separated by "|||".
        """
        
        do {
            let response = try await callChatGPTAPI(with: prompt, systemMessage: "You are a supportive AI assistant that responds to daily updates with warm, encouraging messages.")
            let parsedResponse = ChatGPT.parseResponse(response)
            return parsedResponse.line1.isEmpty ? getRandomResponse() : parsedResponse
        } catch {
            print("Error generating personalized response: \(error)")
            return getRandomResponse()
        }
    }
    
    // MARK: - ChatGPT API Call
    private static func callChatGPTAPI(with prompt: String, systemMessage: String = "You are a supportive AI assistant that responds to daily updates with warm, encouraging messages.") async throws -> String {
        return try await ChatGPT.callChatGPTAPI(with: prompt, systemMessage: systemMessage)
    }
    

}
