//
//  OnboardingAI.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import SwiftUI

// MARK: - OpenAI API Models

struct OpenAIChatGPTRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
    let max_tokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature, max_tokens
    }
}

struct OpenAIChatMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIChatGPTResponse: Codable {
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIChatMessage
    let finish_reason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finish_reason
    }
}

struct OpenAIUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
    
    enum CodingKeys: String, CodingKey {
        case prompt_tokens, completion_tokens, total_tokens
    }
}

// MARK: - OnboardingAI Manager

@MainActor
class OnboardingAI: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var generatedHoroscope: String?
    var onHoroscopeGenerated: (() -> Void)?
    
    private let apiKey: String
    private let baseURL: String
    private let firebaseDatabaseService = FirebaseDatabaseService()
    
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
            
            // Track horoscope generation in Firebase
            await trackHoroscopeGeneration(type: "welcome", success: true)
            
            self.onHoroscopeGenerated?()
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error generating horoscope: \(error)")
            
            // Track failed horoscope generation
            await trackHoroscopeGeneration(type: "welcome", success: false)
        }
        
        isLoading = false
    }
    
    /// Generate a welcome horoscope with provided user data (for Core Data integration)
    func generateWelcomeHoroscope(firstName: String, birthDate: String, birthTime: String, zodiacSign: String, responses: [(String, String, String)]) async {
        print("[OnboardingAI] generateWelcomeHoroscope() called with provided data")
        guard APIConfig.isAPIKeyConfigured else {
            print("[OnboardingAI] API key not configured: \(APIConfig.apiKeyNotConfiguredMessage)")
            error = APIConfig.apiKeyNotConfiguredMessage
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let userData = createUserDataDict(firstName: firstName, birthDate: birthDate, birthTime: birthTime, zodiacSign: zodiacSign, responses: responses)
            let prompt = createWelcomePrompt(with: userData)
            let horoscope = try await callChatGPTAPI(prompt: prompt)
            
            generatedHoroscope = horoscope
            print("✨ Generated welcome horoscope: \(horoscope)")
            
            // Track horoscope generation in Firebase
            await trackHoroscopeGeneration(type: "welcome", success: true)
            
            self.onHoroscopeGenerated?()
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error generating horoscope: \(error)")
            
            // Track failed horoscope generation
            await trackHoroscopeGeneration(type: "welcome", success: false)
        }
        
        isLoading = false
    }
    
    /// Generate a daily horoscope for existing users
    func generateDailyHoroscope() async -> String? {
        print("[OnboardingAI] generateDailyHoroscope() called")
        guard APIConfig.isAPIKeyConfigured else {
            print("[OnboardingAI] API key not configured: \(APIConfig.apiKeyNotConfiguredMessage)")
            error = APIConfig.apiKeyNotConfiguredMessage
            return nil
        }
        
        do {
            let userData = collectUserData()
            print("[OnboardingAI] Collected user data: \(userData)")
            let prompt = createDailyPrompt(with: userData)
            print("[OnboardingAI] Created daily prompt: \n\(prompt)")
            let horoscope = try await callChatGPTAPI(prompt: prompt)
            print("[OnboardingAI] Received daily horoscope: \n\(horoscope)")
            
            // Track horoscope generation in Firebase
            await trackHoroscopeGeneration(type: "daily", success: true)
            
            return horoscope
            
        } catch {
            self.error = error.localizedDescription
            print("[OnboardingAI] Error generating daily horoscope: \(error)")
            
            // Track failed horoscope generation
            await trackHoroscopeGeneration(type: "daily", success: false)
            
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func createUserDataDict(firstName: String, birthDate: String, birthTime: String, zodiacSign: String, responses: [(String, String, String)]) -> [String: Any] {
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
    
    private func collectUserData() -> [String: Any] {
        // For now, we'll use UserDefaults as a fallback, but this should be updated
        // to accept data as parameters when called from views with ModelContext access
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
        let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
        let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
        
        // Get responses from UserDefaults for now
        var responses: [(String, String, String)] = []
        if let data = UserDefaults.standard.data(forKey: "userResponses"),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            responses = jsonArray.compactMap { dict in
                guard let question = dict["question"], 
                      let key = dict["key"], 
                      let answer = dict["answer"] else { return nil }
                return (question, key, answer)
            }
        }
        
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
        print("[OnboardingAI] callChatGPTAPI() called with prompt:\n\(prompt)")
        let requestBody = OpenAIChatGPTRequest(
            model: APIConfig.defaultModel,
            messages: [
                OpenAIChatMessage(role: "system", content: "You are a mystical astrologer who creates deeply personal and enchanting horoscopes."),
                OpenAIChatMessage(role: "user", content: prompt)
            ],
            temperature: APIConfig.defaultTemperature,
            max_tokens: APIConfig.maxTokens
        )
        
        guard let url = URL(string: baseURL) else {
            print("[OnboardingAI] Invalid API URL: \(baseURL)")
            throw OnboardingAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoded = try JSONEncoder().encode(requestBody)
            request.httpBody = encoded
            print("[OnboardingAI] Encoded request body: \n\(String(data: encoded, encoding: .utf8) ?? "<encoding failed>")")
        } catch {
            print("[OnboardingAI] Encoding error: \(error)")
            throw OnboardingAIError.encodingError(error)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print("[OnboardingAI] Received response: \(response)")
        print("[OnboardingAI] Raw response data: \n\(String(data: data, encoding: .utf8) ?? "<decoding failed>")")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[OnboardingAI] Invalid HTTP response")
            throw OnboardingAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[OnboardingAI] API error: HTTP \(httpResponse.statusCode): \(errorMessage)")
            throw OnboardingAIError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        do {
            let chatGPTResponse = try JSONDecoder().decode(OpenAIChatGPTResponse.self, from: data)
            print("[OnboardingAI] Decoded API response: \(chatGPTResponse)")
            guard let firstChoice = chatGPTResponse.choices.first else {
                print("[OnboardingAI] No choices in API response")
                throw OnboardingAIError.noResponse
            }
            
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("[OnboardingAI] Decoding error: \(error)")
            throw OnboardingAIError.decodingError(error)
        }
    }
    
    // MARK: - Analytics
    
    /// Track horoscope generation in Firebase
    private func trackHoroscopeGeneration(type: String, success: Bool) async {
        // Get user ID from UserDefaults or other storage
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            await firebaseDatabaseService.trackHoroscopeGeneration(
                userId: userId,
                horoscopeType: type,
                success: success
            )
        } else {
            print("⚠️ No user ID found for horoscope tracking")
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
                    Text("✨ Welcome to Zodiaccurate ✨")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your cosmic journey is about to begin...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 40)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🌟 What's Next?")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "person.badge.plus")
                                        .foregroundColor(.purple)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Create Your Account")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Sign up to unlock your personalized cosmic insights")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Get Your Welcome Horoscope")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Receive a personalized horoscope crafted just for you")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                                
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Daily Cosmic Guidance")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("Access daily horoscopes and cosmic insights")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
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
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Navigate to sign up
                        dismiss()
                        onboardingAI.onHoroscopeGenerated?()
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Create Account to Continue")
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
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe Later")
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

