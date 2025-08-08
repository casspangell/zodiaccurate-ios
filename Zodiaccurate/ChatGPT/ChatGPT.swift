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
    
    // MARK: - Combined Text and TTS API Call
    static func callChatGPTWithTTS(with prompt: String, 
                                   systemMessage: String = "You are a supportive AI assistant that responds to daily updates with warm, encouraging messages.",
                                   saveKey: String? = nil) async throws -> ChatGPTResponseWithTTS {
        guard APIConfig.isAPIKeyConfigured else {
            throw APIError.apiKeyNotConfigured
        }
        
        // First, get the text response
        let textResponse = try await callChatGPTAPI(with: prompt, systemMessage: systemMessage)
        
        // Then generate TTS audio
        var audioFilePath: String?
        if let key = saveKey {
            do {
                audioFilePath = try await generateAndSaveTTSAudio(from: textResponse, for: key)
                print("🎤 Generated TTS audio for key: \(key)")
            } catch {
                print("❌ Failed to generate TTS audio: \(error)")
                // Continue without audio if TTS fails
            }
        }
        
        return ChatGPTResponseWithTTS(
            text: textResponse,
            audioFilePath: audioFilePath
        )
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
    
    // MARK: - Text-to-Speech
    
    /// Generate audio from text using OpenAI TTS API
    static func generateTTSAudio(from text: String, 
                                model: String = APIConfig.defaultTTSModel,
                                voice: String = APIConfig.defaultTTSVoice) async throws -> Data {
        guard APIConfig.isAPIKeyConfigured else {
            throw APIError.apiKeyNotConfigured
        }
        
        let url = URL(string: APIConfig.openAITTSBaseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = TTSRequest(
            model: model,
            input: text,
            voice: voice
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            print("🎤 TTS API Request for text: \(String(text.prefix(50)))...")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("🎤 TTS API Error Response: \(errorString)")
                }
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            print("✅ TTS audio generated successfully (\(data.count) bytes)")
            return data
        } catch {
            print("🎤 TTS API Error: \(error)")
            throw APIError.requestFailed(error)
        }
    }
    
    /// Save TTS audio to file and return the file path
    static func saveTTSAudio(_ audioData: Data, for key: String) throws -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioDirectory = documentsPath.appendingPathComponent("AudioFiles")
        
        // Create audio directory if it doesn't exist
        try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        
        let fileName = "\(key).mp3"
        let fileURL = audioDirectory.appendingPathComponent(fileName)
        
        try audioData.write(to: fileURL)
        
        print("💾 TTS audio saved to: \(fileURL.path)")
        return fileURL.path
    }
    
    /// Generate TTS audio from text and save it with the specified key
    static func generateAndSaveTTSAudio(from text: String, 
                                       for key: String,
                                       model: String = APIConfig.defaultTTSModel,
                                       voice: String = APIConfig.defaultTTSVoice) async throws -> String {
        let audioData = try await generateTTSAudio(from: text, model: model, voice: voice)
        return try saveTTSAudio(audioData, for: key)
    }
    
    /// Generate horoscope with TTS in one call
    static func generateHoroscopeWithTTS(prompt: String, 
                                        systemMessage: String,
                                        key: String) async throws -> Horoscope {
        let response = try await callChatGPTWithTTS(
            with: prompt,
            systemMessage: systemMessage,
            saveKey: key
        )
        
        // Parse the response (assuming format: "Title|||Message")
        let parts = response.text.components(separatedBy: "|||")
        let title = parts.count > 0 ? parts[0].trimmingCharacters(in: .whitespacesAndNewlines) : "Daily Horoscope"
        let message = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespacesAndNewlines) : response.text
        
        return Horoscope(
            title: title,
            message: message,
            key: key,
            audioFilePath: response.audioFilePath
        )
    }
}

// MARK: - TTS Models

struct TTSRequest: Codable {
    let model: String
    let input: String
    let voice: String
}

// MARK: - Combined Response Model
struct ChatGPTResponseWithTTS {
    let text: String
    let audioFilePath: String?
}

