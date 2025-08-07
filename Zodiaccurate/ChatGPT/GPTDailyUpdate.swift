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
        1. Acknowledges their sharing (header - 1-2 words)
        2. Small sentiment regarding the message (subtext - no more than 240 characters)
        
        Use the tone and style of these examples as a guide:
        - "Thanks for sharing!|||Sounds like a lot"
        - "Got it!|||Sounds frustrating"
        - "I hear you!|||You're doing great"
        
        Keep each part concise and warm. Respond with only the two parts separated by "|||".
        """
        
        do {
            let response = try await callChatGPTAPI(with: prompt)
            return parseResponse(response)
        } catch {
            print("Error generating personalized response: \(error)")
            return getRandomResponse()
        }
    }
    
    // MARK: - ChatGPT API Call
    private static func callChatGPTAPI(with prompt: String) async throws -> String {
        guard APIConfig.isAPIKeyConfigured else {
            throw APIError.apiKeyNotConfigured
        }
        
        let url = URL(string: APIConfig.openAIBaseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ChatGPTRequest(
            model: APIConfig.defaultModel,
            messages: [
                ChatGPTMessage(role: "system", content: "You are a supportive AI assistant that responds to daily updates with a creative honest response and acknowledgment."),
                ChatGPTMessage(role: "user", content: prompt)
            ],
            temperature: APIConfig.defaultTemperature,
            max_tokens: APIConfig.maxTokens
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            // Log the request for debugging
            if let requestString = String(data: jsonData, encoding: .utf8) {
                print("🤖 ChatGPT API Request: \(requestString)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                // Log the error response body for debugging
                if let errorString = String(data: data, encoding: .utf8) {
                    print("🤖 ChatGPT API Error Response: \(errorString)")
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let chatResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            guard let content = chatResponse.choices.first?.message.content else {
                throw APIError.noContent
            }
            
            return content
        } catch {
            print("ChatGPT API Error: \(error)")
            throw APIError.requestFailed(error)
        }
    }
    
    // MARK: - API Models
    private struct ChatGPTRequest: Codable {
        let model: String
        let messages: [ChatGPTMessage]
        let temperature: Double
        let max_tokens: Int
        
        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case temperature
            case max_tokens
        }
    }
    
    private struct ChatGPTMessage: Codable {
        let role: String
        let content: String
    }
    
    private struct ChatGPTResponse: Codable {
        let choices: [ChatGPTChoice]
    }
    
    private struct ChatGPTChoice: Codable {
        let message: ChatGPTMessage
    }
    
    // MARK: - API Errors
    private enum APIError: Error {
        case apiKeyNotConfigured
        case invalidResponse
        case httpError(statusCode: Int)
        case noContent
        case requestFailed(Error)
        
        var localizedDescription: String {
            switch self {
            case .apiKeyNotConfigured:
                return "OpenAI API key not configured"
            case .invalidResponse:
                return "Invalid response from API"
            case .httpError(let statusCode):
                return "HTTP error: \(statusCode)"
            case .noContent:
                return "No content in response"
            case .requestFailed(let error):
                return "Request failed: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Response Parser
    private static func parseResponse(_ response: String) -> (line1: String, line2: String) {
        let parts = response.components(separatedBy: "|||")
        
        guard parts.count >= 2 else {
            return getRandomResponse()
        }
        
        return (
            line1: parts[0].trimmingCharacters(in: .whitespacesAndNewlines),
            line2: parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
