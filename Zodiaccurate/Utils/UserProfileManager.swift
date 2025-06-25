//
//  UserProfileManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData

@MainActor
class UserProfileManager: ObservableObject {
    @Published var profile: UserProfile?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProfile()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadProfile()
    }
    
    private func loadProfile() {
        // Load from SwiftData first
        let descriptor = FetchDescriptor<UserDataModel>()
        do {
            let results = try modelContext.fetch(descriptor)
            if let userData = results.first {
                profile = UserProfile(from: userData)
                return
            }
        } catch {
            print("❌ Error loading user data from SwiftData: \(error)")
        }
        
        // Fallback to UserDefaults
        profile = UserProfile.fromUserDefaults()
    }
    
    // Get user's zodiac sign
    var zodiacSign: String {
        return profile?.zodiacSign ?? OnboardingDataAccess.zodiacSign
    }
    
    // Get user's name
    var firstName: String {
        return profile?.firstName ?? OnboardingDataAccess.firstName
    }
    
    // Get user's birth date
    var birthDate: String {
        return profile?.birthDate ?? OnboardingDataAccess.birthDate
    }
    
    // Get user's birth time
    var birthTime: String {
        return profile?.birthTime ?? OnboardingDataAccess.birthTime
    }
    
    // Get user's responses
    var responses: [(String, String, String)] {
        return profile?.responses ?? OnboardingDataAccess.responses
    }
    
    // Get a specific response
    func getResponse(for key: String) -> (question: String, answer: String)? {
        guard let tuple = responses.first(where: { $0.1 == key }) else { return nil }
        return (question: tuple.0, answer: tuple.2)
    }
    
    // Get just the answer for a key (backward compatibility)
    func getAnswer(for key: String) -> String? {
        return getResponse(for: key)?.answer
    }
    
    // Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        return OnboardingDataAccess.hasCompletedOnboarding
    }
    
    // Get zodiac sign asset name for UI
    var zodiacSignAssetName: String {
        let sign = zodiacSign.lowercased()
        switch sign {
        case "aries": return "Aries"
        case "taurus": return "Taurus"
        case "gemini": return "Gemini"
        case "cancer": return "Cancer"
        case "leo": return "Leo"
        case "virgo": return "Virgo"
        case "libra": return "Libra"
        case "scorpio": return "Scorpio"
        case "sagittarius": return "Saggitarius"
        case "capricorn": return "Capricorn"
        case "aquarius": return "Aquarius"
        case "pisces": return "Pisces"
        default: return "logo"
        }
    }
}

// User Profile struct for easy data access
struct UserProfile {
    let firstName: String
    let birthDate: String
    let birthTime: String
    let zodiacSign: String
    let responses: [(String, String, String)]
    let createdAt: Date
    let updatedAt: Date
    
    init(firstName: String = "", 
         birthDate: String = "", 
         birthTime: String = "", 
         zodiacSign: String = "", 
         responses: [(String, String, String)] = [], 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.responses = responses
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Initialize from UserDataModel
    init(from userData: UserDataModel) {
        self.firstName = userData.firstName
        self.birthDate = userData.birthDate
        self.birthTime = userData.birthTime
        self.zodiacSign = userData.zodiacSign
        self.responses = userData.responseTuples.map { ($0.0, $0.1, $0.2) }
        self.createdAt = userData.createdAt
        self.updatedAt = userData.updatedAt
    }
    
    // Initialize from UserDefaults
    static func fromUserDefaults() -> UserProfile {
        return UserProfile(
            firstName: OnboardingDataAccess.firstName,
            birthDate: OnboardingDataAccess.birthDate,
            birthTime: OnboardingDataAccess.birthTime,
            zodiacSign: OnboardingDataAccess.zodiacSign,
            responses: OnboardingDataAccess.responses.map { ($0.0, $0.1, $0.2) }
        )
    }
    
    // Get a specific response
    func getResponse(for key: String) -> (question: String, answer: String)? {
        guard let tuple = responses.first(where: { $0.1 == key }) else { return nil }
        return (question: tuple.0, answer: tuple.2)
    }
    
    // Check if profile is complete
    var isComplete: Bool {
        return !firstName.isEmpty && !birthDate.isEmpty && !zodiacSign.isEmpty
    }
} 