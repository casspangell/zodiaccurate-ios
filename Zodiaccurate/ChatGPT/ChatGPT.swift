//
//  ChatGPT.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import Foundation

// MARK: - ChatGPT API Service
struct ChatGPT {
    
    // MARK: - ChatGPT API Call
    static func callChatGPTAPI(with prompt: String, systemMessage: String = "You are a supportive AI assistant that responds to daily updates with warm, encouraging messages.") async throws -> String {
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
                ChatGPTMessage(role: "system", content: systemMessage),
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
    struct ChatGPTRequest: Codable {
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
    
    struct ChatGPTMessage: Codable {
        let role: String
        let content: String
    }
    
    struct ChatGPTResponse: Codable {
        let choices: [ChatGPTChoice]
    }
    
    struct ChatGPTChoice: Codable {
        let message: ChatGPTMessage
    }
    
    // MARK: - API Errors
    enum APIError: Error {
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
    static func parseResponse(_ response: String, separator: String = "|||") -> (line1: String, line2: String) {
        let parts = response.components(separatedBy: separator)
        
        guard parts.count >= 2 else {
            return ("", "")
        }
        
        return (
            line1: parts[0].trimmingCharacters(in: .whitespacesAndNewlines),
            line2: parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

