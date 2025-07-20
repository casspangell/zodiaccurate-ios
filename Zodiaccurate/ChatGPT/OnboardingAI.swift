//
//  Onboarding.swift
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

// MARK: - Onboarding Manager

@MainActor
class Onboarding: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var generatedHoroscope: String?
    var onHoroscopeGenerated: (() -> Void)?
    
    private let apiKey: String
    private let baseURL: String
    private let firebaseDatabaseService = FirebaseDatabaseService()
    
    init() {
        print("🔍 [OnboardingAI] ===== INITIALIZATION DEBUG =====")
        print("🔍 [OnboardingAI] APIConfig.isAPIKeyConfigured: \(APIConfig.isAPIKeyConfigured)")
        print("🔍 [OnboardingAI] APIConfig.openAIAPIKey length: \(APIConfig.openAIAPIKey.count)")
        print("🔍 [OnboardingAI] APIConfig.openAIAPIKey prefix: \(APIConfig.openAIAPIKey.prefix(10))...")
        print("🔍 [OnboardingAI] APIConfig.openAIBaseURL: \(APIConfig.openAIBaseURL)")
        print("🔍 [OnboardingAI] APIConfig.defaultModel: \(APIConfig.defaultModel)")
        print("🔍 [OnboardingAI] APIConfig.defaultTemperature: \(APIConfig.defaultTemperature)")
        print("🔍 [OnboardingAI] APIConfig.maxTokens: \(APIConfig.maxTokens)")
        
        self.apiKey = APIConfig.openAIAPIKey
        self.baseURL = APIConfig.openAIBaseURL
        
        print("🔍 [OnboardingAI] Instance variables set:")
        print("   - apiKey length: \(self.apiKey.count)")
        print("   - baseURL: \(self.baseURL)")
        print("🔍 [OnboardingAI] ===== INITIALIZATION DEBUG END =====")
    }
    
    // MARK: - Public Methods
    
    /// Generate a captivating horoscope for a new user based on their onboarding data
    /// DEPRECATED: Use generateWelcomeHoroscope(firstName:birthDate:birthTime:zodiacSign:responses:) instead
    func generateWelcomeHoroscope() async {
        print("⚠️ [OnboardingAI] DEPRECATED: generateWelcomeHoroscope() called without parameters")
        print("⚠️ [OnboardingAI] Use generateWelcomeHoroscope(firstName:birthDate:birthTime:zodiacSign:responses:) instead")
        
        isLoading = true
        error = "This method is deprecated. Please use the parameter-based version."
        isLoading = false
    }
    
    /// Generate a welcome horoscope with provided user data (for Core Data integration)
    func generateWelcomeHoroscope(firstName: String, birthDate: String, birthTime: String, zodiacSign: String, responses: [(String, String, String)]) async {
        print("[OnboardingAI] generateWelcomeHoroscope() called with provided data")
        
        // Test network connectivity first
        await testNetworkConnectivity()
        
        isLoading = true
        error = nil
        
        // Only generate horoscope via API - no fallback
        if APIConfig.isAPIKeyConfigured {
            do {
                let userData = createUserDataDict(firstName: firstName, birthDate: birthDate, birthTime: birthTime, zodiacSign: zodiacSign, responses: responses)
                let prompt = createWelcomePrompt(with: userData)
                let horoscope = try await callChatGPTAPI(prompt: prompt)
                
                generatedHoroscope = horoscope
                print("✨ Generated welcome horoscope via API: \(horoscope)")
                
                // Track horoscope generation in Firebase
                await trackHoroscopeGeneration(type: "welcome", success: true)
                
                self.onHoroscopeGenerated?()
                
            } catch {
                self.error = "Unable to generate horoscope. Please check your internet connection and try again."
                print("❌ API Error generating horoscope: \(error)")
                
                // Track failed horoscope generation
                await trackHoroscopeGeneration(type: "welcome", success: false)
            }
        } else {
            self.error = APIConfig.apiKeyNotConfiguredMessage
            print("[OnboardingAI] API key not configured: \(APIConfig.apiKeyNotConfiguredMessage)")
            
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
            // Use OnboardingDataAccess to get current user data from SwiftData
            let firstName = OnboardingDataAccess.firstName
            let zodiacSign = OnboardingDataAccess.zodiacSign
            
            let userData: [String: Any] = [
                "firstName": firstName,
                "zodiacSign": zodiacSign,
                "hasCompletedOnboarding": OnboardingDataAccess.hasCompletedOnboarding
            ]
            
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
        print("🔍 [OnboardingAI] ===== API CALL DEBUG START =====")
        print("🔍 [OnboardingAI] callChatGPTAPI() called with prompt length: \(prompt.count) characters")
        print("🔍 [OnboardingAI] API Key configured: \(!apiKey.isEmpty ? "YES" : "NO")")
        print("🔍 [OnboardingAI] API Key length: \(apiKey.count) characters")
        print("🔍 [OnboardingAI] API Key prefix: \(apiKey.prefix(10))...")
        print("🔍 [OnboardingAI] Base URL: \(baseURL)")
        print("🔍 [OnboardingAI] Model: \(APIConfig.defaultModel)")
        print("🔍 [OnboardingAI] Temperature: \(APIConfig.defaultTemperature)")
        print("🔍 [OnboardingAI] Max Tokens: \(APIConfig.maxTokens)")
        
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
            print("❌ [OnboardingAI] Invalid API URL: \(baseURL)")
            throw OnboardingError.invalidURL
        }
        
        print("🔍 [OnboardingAI] URL created successfully: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0 // 30 second timeout
        
        print("🔍 [OnboardingAI] Request headers set:")
        print("   - Authorization: Bearer \(apiKey.prefix(10))...")
        print("   - Content-Type: application/json")
        print("   - Timeout: 30.0 seconds")
        
        do {
            let encoded = try JSONEncoder().encode(requestBody)
            request.httpBody = encoded
            print("🔍 [OnboardingAI] Request body encoded successfully, size: \(encoded.count) bytes")
            print("🔍 [OnboardingAI] Request body preview: \(String(data: encoded, encoding: .utf8)?.prefix(200) ?? "<encoding failed>")...")
        } catch {
            print("❌ [OnboardingAI] Encoding error: \(error)")
            throw OnboardingError.encodingError(error)
        }
        
        // Try with retry logic
        for attempt in 1...3 {
            do {
                print("🔍 [OnboardingAI] ===== API ATTEMPT \(attempt)/3 =====")
                print("🔍 [OnboardingAI] Starting network request to: \(url)")
                print("🔍 [OnboardingAI] Request method: \(request.httpMethod ?? "Unknown")")
                print("🔍 [OnboardingAI] Request body size: \(request.httpBody?.count ?? 0) bytes")
                
                let startTime = Date()
                let (data, response) = try await URLSession.shared.data(for: request)
                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                
                print("✅ [OnboardingAI] Network request completed successfully!")
                print("🔍 [OnboardingAI] Request duration: \(String(format: "%.2f", duration)) seconds")
                print("🔍 [OnboardingAI] Response received: \(response)")
                print("🔍 [OnboardingAI] Response data size: \(data.count) bytes")
                
                // Log response headers if available
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔍 [OnboardingAI] HTTP Status Code: \(httpResponse.statusCode)")
                    print("🔍 [OnboardingAI] Response Headers:")
                    for (key, value) in httpResponse.allHeaderFields {
                        print("   - \(key): \(value)")
                    }
                }
                
                print("🔍 [OnboardingAI] Raw response data preview: \(String(data: data, encoding: .utf8)?.prefix(500) ?? "<decoding failed>")...")
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ [OnboardingAI] Invalid HTTP response type")
                    throw OnboardingError.invalidResponse
                }
                
                guard httpResponse.statusCode == 200 else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("❌ [OnboardingAI] API error: HTTP \(httpResponse.statusCode): \(errorMessage)")
                    throw OnboardingError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
                }
                
                do {
                    let chatGPTResponse = try JSONDecoder().decode(OpenAIChatGPTResponse.self, from: data)
                    print("✅ [OnboardingAI] Successfully decoded API response")
                    print("🔍 [OnboardingAI] Response has \(chatGPTResponse.choices.count) choices")
                    
                    guard let firstChoice = chatGPTResponse.choices.first else {
                        print("❌ [OnboardingAI] No choices in API response")
                        throw OnboardingError.noResponse
                    }
                    
                    let horoscopeContent = firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("✅ [OnboardingAI] Horoscope content length: \(horoscopeContent.count) characters")
                    print("🔍 [OnboardingAI] Horoscope preview: \(horoscopeContent.prefix(100))...")
                    print("🔍 [OnboardingAI] ===== API CALL DEBUG END =====")
                    
                    return horoscopeContent
                } catch {
                    print("❌ [OnboardingAI] Decoding error: \(error)")
                    print("🔍 [OnboardingAI] Raw data that failed to decode: \(String(data: data, encoding: .utf8) ?? "<unable to decode>")")
                    throw OnboardingError.decodingError(error)
                }
            } catch {
                print("❌ [OnboardingAI] ===== API ATTEMPT \(attempt) FAILED =====")
                print("❌ [OnboardingAI] Error type: \(type(of: error))")
                print("❌ [OnboardingAI] Error description: \(error.localizedDescription)")
                
                // Detailed error analysis
                if let urlError = error as? URLError {
                    print("🔍 [OnboardingAI] URL Error Details:")
                    print("   - Code: \(urlError.code.rawValue)")
                    print("   - Description: \(urlError.localizedDescription)")
                    print("   - Failure URL: \(urlError.failingURL?.absoluteString ?? "Unknown")")
                    
                    // Common URL error codes
                    switch urlError.code {
                    case .notConnectedToInternet:
                        print("🔍 [OnboardingAI] Issue: No internet connection")
                    case .networkConnectionLost:
                        print("🔍 [OnboardingAI] Issue: Network connection was lost")
                    case .timedOut:
                        print("🔍 [OnboardingAI] Issue: Request timed out")
                    case .cannotFindHost:
                        print("🔍 [OnboardingAI] Issue: Cannot find host")
                    case .cannotConnectToHost:
                        print("🔍 [OnboardingAI] Issue: Cannot connect to host")
                    case .dnsLookupFailed:
                        print("🔍 [OnboardingAI] Issue: DNS lookup failed")
                    default:
                        print("🔍 [OnboardingAI] Issue: Other network error")
                    }
                }
                
                if attempt < 3 {
                    // Wait before retrying (exponential backoff)
                    let delay = Double(attempt) * 2.0
                    print("⏳ [OnboardingAI] Waiting \(delay) seconds before retry...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    // All attempts failed
                    print("💥 [OnboardingAI] All API attempts failed - giving up")
                    print("🔍 [OnboardingAI] ===== API CALL DEBUG END =====")
                    throw error
                }
            }
        }
        
        // This should never be reached, but Swift requires it for compilation
        throw OnboardingError.apiError("All retry attempts failed")
    }
    
    // MARK: - Network Connectivity Test
    
    /// Test basic network connectivity to OpenAI API
    private func testNetworkConnectivity() async {
        print("🔍 [OnboardingAI] ===== NETWORK CONNECTIVITY TEST =====")
        
        guard let url = URL(string: "https://api.openai.com/v1/models") else {
            print("❌ [OnboardingAI] Invalid test URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30.0 // Increased timeout for simulator
        
        do {
            print("🔍 [OnboardingAI] Testing basic connectivity to OpenAI API...")
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ [OnboardingAI] Network connectivity test successful!")
                print("🔍 [OnboardingAI] HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ [OnboardingAI] API Key authentication failed - check your API key")
                } else if httpResponse.statusCode == 200 {
                    print("✅ [OnboardingAI] API Key is valid and working")
                } else {
                    print("⚠️ [OnboardingAI] Unexpected status code: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("❌ [OnboardingAI] Network connectivity test failed: \(error)")
            if let urlError = error as? URLError {
                print("🔍 [OnboardingAI] URL Error Code: \(urlError.code.rawValue)")
                print("🔍 [OnboardingAI] URL Error Description: \(urlError.localizedDescription)")
            }
        }
        
        print("🔍 [OnboardingAI] ===== NETWORK TEST END =====")
    }
    
    // MARK: - Fallback Horoscope Generation
    
    /// Generate a fallback horoscope when API is unavailable
    private func generateFallbackHoroscope(firstName: String, zodiacSign: String, responses: [(String, String, String)]) -> String {
        let intuition = responses.first { $0.1 == "intuition" }?.2 ?? ""
        let energy = responses.first { $0.1 == "energy" }?.2 ?? ""
        let dreams = responses.first { $0.1 == "dreams" }?.2 ?? ""
        
        let zodiacTraits = getZodiacTraits(for: zodiacSign)
        let cosmicEnergy = getCosmicEnergy(from: energy)
        let intuitiveInsight = getIntuitiveInsight(from: intuition)
        let dreamGuidance = getDreamGuidance(from: dreams)
        
        return """
        ✨ Welcome to your cosmic journey, \(firstName)! ✨

        As a \(zodiacSign), you carry the unique energy of \(zodiacTraits). The stars have aligned to bring you here, and I can sense the powerful cosmic connection that drew you to Zodiaccurate.

        \(intuitiveInsight)

        \(cosmicEnergy)

        \(dreamGuidance)

        Your cosmic signature is extraordinary, \(firstName). The universe has been trying to communicate with you, and now you're ready to receive its messages. Your journey with Zodiaccurate will unlock daily insights that will guide you through life's cosmic currents.

        The stars are speaking to you, \(firstName). Are you ready to listen? 🌟
        """
    }
    
    private func getZodiacTraits(for sign: String) -> String {
        switch sign.lowercased() {
        case "aries": return "the bold pioneer, ruled by Mars"
        case "taurus": return "the grounded earth sign, ruled by Venus"
        case "gemini": return "the curious communicator, ruled by Mercury"
        case "cancer": return "the intuitive nurturer, ruled by the Moon"
        case "leo": return "the radiant leader, ruled by the Sun"
        case "virgo": return "the analytical perfectionist, ruled by Mercury"
        case "libra": return "the harmonious diplomat, ruled by Venus"
        case "scorpio": return "the mysterious transformer, ruled by Pluto"
        case "sagittarius": return "the adventurous philosopher, ruled by Jupiter"
        case "capricorn": return "the ambitious achiever, ruled by Saturn"
        case "aquarius": return "the innovative visionary, ruled by Uranus"
        case "pisces": return "the mystical dreamer, ruled by Neptune"
        default: return "a unique cosmic being"
        }
    }
    
    private func getCosmicEnergy(from energy: String) -> String {
        if energy.lowercased().contains("absorb") || energy.lowercased().contains("empath") {
            return "I can see you're an energy absorber - you naturally take in the emotions and vibes around you. This is a powerful gift. Your sensitivity allows you to navigate the unseen currents of energy that flow through our world."
        } else if energy.lowercased().contains("drawn") || energy.lowercased().contains("magnetic") {
            return "Your magnetic energy draws people to you like moths to a flame. You have a natural charisma that lights up any room you enter. This is the universe's way of saying you're meant to lead and inspire others."
        } else {
            return "Your energy signature is beautifully balanced - you have the rare ability to both give and receive cosmic energy in perfect harmony. This makes you a natural bridge between different worlds and perspectives."
        }
    }
    
    private func getIntuitiveInsight(from intuition: String) -> String {
        if intuition.lowercased().contains("gut") || intuition.lowercased().contains("feeling") {
            return "Your intuitive gifts are extraordinary. Those 'gut feelings' you experience are actually messages from the universe, guiding you toward your highest path. Trust these cosmic whispers - they're your inner compass."
        } else if intuition.lowercased().contains("dream") || intuition.lowercased().contains("vision") {
            return "Your intuitive abilities manifest through dreams and visions. The universe speaks to you in the language of symbols and metaphors. Pay attention to these nocturnal messages - they hold the keys to your destiny."
        } else {
            return "Your intuition is a powerful cosmic tool that's been developing throughout your life. Even if you don't always recognize it, you're receiving guidance from the stars every day."
        }
    }
    
    private func getDreamGuidance(from dreams: String) -> String {
        if dreams.lowercased().contains("future") || dreams.lowercased().contains("prophetic") {
            return "Your dreams are not just random thoughts - they're glimpses into possible futures and cosmic guidance. The universe is showing you the paths that lie ahead, helping you make choices that align with your soul's purpose."
        } else if dreams.lowercased().contains("symbol") || dreams.lowercased().contains("meaning") {
            return "The symbols in your dreams are the universe's way of communicating with you. Each image, color, and scenario carries deep meaning about your journey and the guidance you need right now."
        } else {
            return "Your dreams are a sacred space where the universe can speak directly to your soul. They hold wisdom about your past, present, and future - all waiting to be discovered."
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

enum OnboardingError: Error, LocalizedError {
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
    @StateObject private var onboardingAI = Onboarding()
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
    @ObservedObject var onboardingAI: Onboarding
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

