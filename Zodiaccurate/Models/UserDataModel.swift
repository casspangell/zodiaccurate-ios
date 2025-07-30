//
//  UserDataModel.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData

// MARK: - User Data Model
@Model
public final class UserDataModel {
    // MARK: - Properties
    public var profileData: String // JSON-encoded UserProfile
    public var userId: String?
    public var welcomeHoroscope: String?
    public var hasCompletedOnboarding: Bool
    public var hasAcceptedConsentPolicies: Bool
    
    // MARK: - Computed Properties
    
    /// The UserProfile object
    public var profile: UserProfile {
        get {
            guard let data = profileData.data(using: .utf8) else { 
                return UserProfile()
            }
            return (try? JSONDecoder().decode(UserProfile.self, from: data)) ?? UserProfile()
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                profileData = String(data: data, encoding: .utf8) ?? "{}"
            } else {
                profileData = "{}"
            }
        }
    }
    
    /// Backward compatibility: firstName
    public var firstName: String {
        get { return profile.firstName }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: newValue,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: profile.responses,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: birthDate
    public var birthDate: String {
        get { return profile.birthDate }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: newValue,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: profile.responses,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: birthTime
    public var birthTime: String {
        get { return profile.birthTime }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: newValue,
                zodiacSign: profile.zodiacSign,
                responses: profile.responses,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: zodiacSign
    public var zodiacSign: String {
        get { return profile.zodiacSign }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: newValue,
                responses: profile.responses,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: createdAt
    public var createdAt: Date {
        get { return profile.createdAt }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: profile.responses,
                createdAt: newValue,
                updatedAt: profile.updatedAt
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: updatedAt
    public var updatedAt: Date {
        get { return profile.updatedAt }
        set { 
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: profile.responses,
                createdAt: profile.createdAt,
                updatedAt: newValue
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: responseArray
    public var responseArray: [OnboardingResponse] {
        get {
            return profile.responses.map { OnboardingResponse(question: $0.0, key: $0.1, answer: $0.2) }
        }
        set {
            let responses = newValue.map { ($0.question, $0.key, $0.answer) }
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: responses,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    /// Backward compatibility: responseTuples
    public var responseTuples: [(String, String, String)] {
        get { return profile.responses }
        set {
            var updatedProfile = profile
            updatedProfile = UserProfile(
                firstName: profile.firstName,
                birthDate: profile.birthDate,
                birthTime: profile.birthTime,
                zodiacSign: profile.zodiacSign,
                responses: newValue,
                createdAt: profile.createdAt,
                updatedAt: Date()
            )
            profile = updatedProfile
        }
    }
    
    // MARK: - Initialization
    public init(profile: UserProfile = UserProfile(),
         userId: String? = nil,
         welcomeHoroscope: String? = nil,
         hasCompletedOnboarding: Bool = false,
         hasAcceptedConsentPolicies: Bool = false) {
        self.profileData = "{}" // Will be set by computed property
        self.userId = userId
        self.welcomeHoroscope = welcomeHoroscope
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasAcceptedConsentPolicies = hasAcceptedConsentPolicies
        
        // Set profile after initialization
        self.profile = profile
    }
    
    // Backward compatibility initializer
    public init(firstName: String = "", 
         birthDate: String = "", 
         birthTime: String = "", 
         zodiacSign: String = "", 
         responses: [OnboardingResponse] = [], 
         userId: String? = nil,
         welcomeHoroscope: String? = nil,
         hasCompletedOnboarding: Bool = false,
         hasAcceptedConsentPolicies: Bool = false) {
        self.profileData = "{}" // Will be set by computed property
        self.userId = userId
        self.welcomeHoroscope = welcomeHoroscope
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasAcceptedConsentPolicies = hasAcceptedConsentPolicies
        
        // Create UserProfile from individual properties
        let responseTuples = responses.map { ($0.question, $0.key, $0.answer) }
        let userProfile = UserProfile(
            firstName: firstName,
            birthDate: birthDate,
            birthTime: birthTime,
            zodiacSign: zodiacSign,
            responses: responseTuples
        )
        
        // Set profile after initialization
        self.profile = userProfile
    }
    
    // MARK: - Response Management
    public func getResponse(for key: String) -> OnboardingResponse? {
        return responseArray.first { $0.key == key }
    }
    
    public func updateResponse(for key: String, question: String, answer: String) {
        var responses = responseArray
        responses.removeAll { $0.key == key }
        responses.append(OnboardingResponse(question: question, key: key, answer: answer))
        responseArray = responses
        updatedAt = Date()
    }
    
    public func addResponse(_ response: OnboardingResponse) {
        var responses = responseArray
        responses.removeAll { $0.key == response.key }
        responses.append(response)
        responseArray = responses
        updatedAt = Date()
    }
    
    public func removeResponse(for key: String) {
        var responses = responseArray
        responses.removeAll { $0.key == key }
        responseArray = responses
        updatedAt = Date()
    }
    
    public func clearAllResponses() {
        responseArray = []
        updatedAt = Date()
    }
    
    // MARK: - Profile Management
    
    /// Update the entire profile
    public func updateProfile(_ newProfile: UserProfile) {
        profile = newProfile
    }
    
    /// Get a response from the profile
    public func getProfileResponse(for key: String) -> (question: String, answer: String)? {
        return profile.getResponse(for: key)
    }
    
    /// Add a response to the profile
    public func addProfileResponse(question: String, key: String, answer: String) {
        var updatedProfile = profile
        var responses = profile.responses
        responses.removeAll { $0.1 == key }
        responses.append((question, key, answer))
        updatedProfile = UserProfile(
            firstName: profile.firstName,
            birthDate: profile.birthDate,
            birthTime: profile.birthTime,
            zodiacSign: profile.zodiacSign,
            responses: responses,
            createdAt: profile.createdAt,
            updatedAt: Date()
        )
        profile = updatedProfile
    }
    
    /// Update a response in the profile
    public func updateProfileResponse(for key: String, question: String, answer: String) {
        addProfileResponse(question: question, key: key, answer: answer)
    }
    
    /// Remove a response from the profile
    public func removeProfileResponse(for key: String) {
        var updatedProfile = profile
        var responses = profile.responses
        responses.removeAll { $0.1 == key }
        updatedProfile = UserProfile(
            firstName: profile.firstName,
            birthDate: profile.birthDate,
            birthTime: profile.birthTime,
            zodiacSign: profile.zodiacSign,
            responses: responses,
            createdAt: profile.createdAt,
            updatedAt: Date()
        )
        profile = updatedProfile
    }
    
    /// Clear all responses from the profile
    public func clearAllProfileResponses() {
        var updatedProfile = profile
        updatedProfile = UserProfile(
            firstName: profile.firstName,
            birthDate: profile.birthDate,
            birthTime: profile.birthTime,
            zodiacSign: profile.zodiacSign,
            responses: [],
            createdAt: profile.createdAt,
            updatedAt: Date()
        )
        profile = updatedProfile
    }
    
    // MARK: - Validation
    public var isValid: Bool {
        return !firstName.isEmpty && 
               !birthDate.isEmpty && 
               !birthTime.isEmpty && 
               !zodiacSign.isEmpty
    }
    
    public var hasEssentialData: Bool {
        return !firstName.isEmpty && !zodiacSign.isEmpty
    }
    
    // MARK: - Zodiac Sign Validation
    public var isValidZodiacSign: Bool {
        return ZodiacSign.allCases.map { $0.rawValue }.contains(zodiacSign)
    }
    
    // MARK: - Utility Methods
    public func markOnboardingComplete() {
        hasCompletedOnboarding = true
        updatedAt = Date()
    }
    
    public func markConsentAccepted() {
        hasAcceptedConsentPolicies = true
        updatedAt = Date()
    }
    
    public func updateWelcomeHoroscope(_ horoscope: String) {
        welcomeHoroscope = horoscope
        updatedAt = Date()
    }
    
    // MARK: - Data Export
    public var exportData: [String: Any] {
        return [
            "firstName": firstName,
            "birthDate": birthDate,
            "birthTime": birthTime,
            "zodiacSign": zodiacSign,
            "responses": responseArray.map { $0.pipeSeparatedString },
            "userId": userId ?? "",
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "welcomeHoroscope": welcomeHoroscope ?? "",
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "hasAcceptedConsentPolicies": hasAcceptedConsentPolicies
        ]
    }
    
    // MARK: - Mock Data
    public static func createMockUserData() -> UserDataModel {
        let mockResponses = [
            OnboardingResponse(question: "What's your name?", key: "name", answer: "Erika"),
            OnboardingResponse(question: "When were you born?", key: "birthDate", answer: "July 25, 1970")
        ]
        
        return UserDataModel(
            firstName: "Erika",
            birthDate: "July 25, 1970",
            birthTime: "10:31 PM",
            zodiacSign: "Leo",
            responses: mockResponses,
            welcomeHoroscope: """
            Dearest Erika, born under the fiery heart of Leo with the night's twilight as your celestial cloak, the cosmos has whispered your name. Born at 10:31 PM on July 25, 2025, your birth was graced with the shimmering secrets of the evening, and it's those same secrets that have come to symbolize your deep-seated passion and regal spirit, typical of a true Leo.
            
            Your intuitive greeting, filled with multiple hellos, speaks to your innate ability to connect energetically with those around you, a vibrant 'hi' that echoes through the universe. Remember, dear Erika, your dreams may be silent now, but in that silence, there is a boundless potential, a universe of possibilities waiting for you. Embrace this journey, for it's in the quiet moments that your true strength emerges.
            
            The stars have aligned to reveal that your path is one of leadership and creativity. Your natural charisma draws others to you like moths to a flame, and your generous spirit makes you a beacon of warmth in the lives of those around you. Trust in your intuition, for it is sharper than you know.
            
            As you navigate through this cosmic journey, remember that every challenge is an opportunity for growth. Your Leo heart beats with the rhythm of the universe, and your courage will guide you through any storm. The future holds great promise for you, dear Erika.
            """,
            hasCompletedOnboarding: false,
            hasAcceptedConsentPolicies: false
        )
    }
} 
