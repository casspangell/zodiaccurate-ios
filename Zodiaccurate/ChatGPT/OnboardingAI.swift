//
//  OnboardingAI.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import SwiftUI

// MARK: - ChatGPT API Models

struct ChatGPTRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatGPTResponse: Codable {
    let choices: [Choice]
    let usage: Usage?
}

struct Choice: Codable {
    let message: ChatMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OnboardingAI Manager

@MainActor
class OnboardingAI: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var generatedHoroscope: String?
    
    private let apiKey: String
    private let baseURL: String
    
    init() {
        self.apiKey = APIConfig.openAIAPIKey
        self.baseURL = APIConfig.openAIBaseURL
    }
    
    // MARK: - Public Methods
    
    /// Generate a captivating horoscope for a new user based on their onboarding data
    func generateWelcomeHoroscope() async {
        guard APIConfig.isAPIKeyConfigured else {
            error = APIConfig.apiKeyNotConfiguredMessage
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let userData = collectUserData()
            let prompt = createWelcomePrompt(with: userData)
            let horoscope = try await callChatGPTAPI(prompt: prompt)
            
            generatedHoroscope = horoscope
            print("✨ Generated welcome horoscope: \(horoscope)")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error generating horoscope: \(error)")
        }
        
        isLoading = false
    }
    
    /// Generate a daily horoscope for existing users
    func generateDailyHoroscope() async -> String? {
        guard APIConfig.isAPIKeyConfigured else {
            error = APIConfig.apiKeyNotConfiguredMessage
            return nil
        }
        
        do {
            let userData = collectUserData()
            let prompt = createDailyPrompt(with: userData)
            let horoscope = try await callChatGPTAPI(prompt: prompt)
            
            print("✨ Generated daily horoscope: \(horoscope)")
            return horoscope
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error generating daily horoscope: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func collectUserData() -> [String: Any] {
        let firstName = OnboardingDataAccess.firstName
        let birthDate = OnboardingDataAccess.birthDate
        let birthTime = OnboardingDataAccess.birthTime
        let zodiacSign = OnboardingDataAccess.zodiacSign
        let responses = OnboardingDataAccess.responses
        
        var userData: [String: Any] = [
            "firstName": firstName,
            "birthDate": birthDate,
            "birthTime": birthTime,
            "zodiacSign": zodiacSign,
            "hasCompletedOnboarding": OnboardingDataAccess.hasCompletedOnboarding
        ]
        
        // Add user responses
        var responseDict: [String: String] = [:]
        for (question, key, answer) in responses {
            responseDict[key] = answer
        }
        userData["responses"] = responseDict
        
        return userData
    }
    
    private func createWelcomePrompt(with userData: [String: Any]) -> String {
        let firstName = userData["firstName"] as? String ?? ""
        let zodiacSign = userData["zodiacSign"] as? String ?? ""
        let birthDate = userData["birthDate"] as? String ?? ""
        let birthTime = userData["birthTime"] as? String ?? ""
        let responses = userData["responses"] as? [String: String] ?? [:]
        
        let intuition = responses["intuition"] ?? ""
        let energy = responses["energy"] ?? ""
        let dreams = responses["dreams"] ?? ""
        
        return """
        You are a mystical, captivating astrologer who creates deeply personal and enchanting horoscopes. Your mission is to create a horoscope that will make a new user fall in love with astrology and want to subscribe to get daily insights.

        USER INFORMATION:
        - Name: \(firstName)
        - Zodiac Sign: \(zodiacSign)
        - Birth Date: \(birthDate)
        - Birth Time: \(birthTime)
        - Intuition Response: \(intuition)
        - Energy Response: \(energy)
        - Dreams Response: \(dreams)

        TASK: Create a captivating, personalized welcome horoscope that:
        1. Addresses them by name and feels deeply personal
        2. References their specific zodiac sign and birth details
        3. Incorporates their responses about intuition, energy, and dreams
        4. Creates a sense of wonder and cosmic connection
        5. Hints at deeper insights available through daily horoscopes
        6. Uses mystical, enchanting language that feels magical
        7. Ends with a compelling reason to subscribe for daily cosmic guidance
        8. Is between 150-200 words
        9. Uses emojis sparingly but effectively for cosmic elements

        Make this horoscope feel like a personal message from the universe, specifically crafted for \(firstName). It should make them feel seen, understood, and excited about their cosmic journey ahead.
        """
    }
    
    private func createDailyPrompt(with userData: [String: Any]) -> String {
        let firstName = userData["firstName"] as? String ?? ""
        let zodiacSign = userData["zodiacSign"] as? String ?? ""
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        return """
        You are a mystical astrologer creating a daily horoscope for \(firstName), a \(zodiacSign).

        Create a personalized daily horoscope for \(formattedDate) that:
        1. Addresses them by name
        2. Provides specific guidance for the day
        3. Relates to their \(zodiacSign) traits
        4. Uses mystical, enchanting language
        5. Is encouraging and positive
        6. Is between 100-150 words
        7. Uses 2-3 relevant emojis

        Make it feel personal and magical, as if the stars are speaking directly to \(firstName).
        """
    }
    
    private func callChatGPTAPI(prompt: String) async throws -> String {
        let requestBody = ChatGPTRequest(
            model: APIConfig.defaultModel,
            messages: [
                ChatMessage(role: "system", content: "You are a mystical astrologer who creates deeply personal and enchanting horoscopes."),
                ChatMessage(role: "user", content: prompt)
            ],
            temperature: APIConfig.defaultTemperature,
            maxTokens: APIConfig.maxTokens
        )
        
        guard let url = URL(string: baseURL) else {
            throw OnboardingAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OnboardingAIError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OnboardingAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OnboardingAIError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        do {
            let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            guard let firstChoice = chatGPTResponse.choices.first else {
                throw OnboardingAIError.noResponse
            }
            
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw OnboardingAIError.decodingError(error)
        }
    }
}

// MARK: - Error Types

enum OnboardingAIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noResponse
    case apiError(String)
    case encodingError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noResponse:
            return "No response generated"
        case .apiError(let message):
            return "API Error: \(message)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

// MARK: - SwiftUI View for Displaying Generated Horoscope

struct GeneratedHoroscopeView: View {
    @StateObject private var onboardingAI = OnboardingAI()
    @Environment(\.dismiss) private var dismiss
    var onComplete: () -> Void = {}
    
    init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Cosmic background
            LinearGradient(
                colors: [Color.black, Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("✨ Your Cosmic Welcome ✨")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("The stars have a special message for you...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                // Horoscope content
                ScrollView {
                    VStack(spacing: 20) {
                        if onboardingAI.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.white)
                                
                                Text("Consulting the stars...")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("✨ 🌟 ✨")
                                    .font(.title2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let horoscope = onboardingAI.generatedHoroscope {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(horoscope)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                        } else if let error = onboardingAI.error {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                
                                Text("Cosmic Connection Issue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(error)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if onboardingAI.generatedHoroscope != nil {
                        Button(action: {
                            // TODO: Implement subscription flow
                            print("🌟 User wants to subscribe!")
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Unlock Daily Cosmic Insights")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.gradient)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        dismiss()
                        onComplete()
                    }) {
                        Text("Continue to App")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if onboardingAI.generatedHoroscope == nil && !onboardingAI.isLoading {
                Task {
                    await onboardingAI.generateWelcomeHoroscope()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GeneratedHoroscopeView()
}

// MARK: - Daily Horoscope Sheet

struct DailyHoroscopeSheet: View {
    @Binding var isPresented: Bool
    @Binding var horoscope: String?
    @ObservedObject var onboardingAI: OnboardingAI
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("✨ Daily Horoscope ✨")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        if isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.white)
                                
                                Text("Consulting the stars...")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("✨ 🌟 ✨")
                                    .font(.title2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if let horoscopeText = horoscope {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(horoscopeText)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.largeTitle)
                                    .foregroundColor(.purple)
                                
                                Text("Ready for Your Daily Guidance?")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Tap the button below to receive your personalized cosmic insights for today.")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if horoscope == nil {
                        Button(action: {
                            generateDailyHoroscope()
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Daily Horoscope")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple.gradient)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text(horoscope == nil ? "Cancel" : "Close")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func generateDailyHoroscope() {
        isLoading = true
        
        Task {
            if let generatedHoroscope = await onboardingAI.generateDailyHoroscope() {
                await MainActor.run {
                    horoscope = generatedHoroscope
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

