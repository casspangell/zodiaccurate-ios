//
//  OnboardingDataAccess.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData

class OnboardingDataAccess: ObservableObject {
    @Published var userData: UserDataModel?
    private var modelContext: ModelContext
    
    @Published var isGeneratingHoroscope: Bool = false
    @Published var didGenerateHoroscope: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUserData()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadUserData()
    }
    
    // Load user data from SwiftData
    func loadUserData() {
        print("🔄 OnboardingDataAccess: Loading user data...")
        
        // Try to load data for the current user ID first
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            loadUserData(for: userId)
        } else {
            // Fallback to loading any available data
            let descriptor = FetchDescriptor<UserDataModel>()
            do {
                let results = try modelContext.fetch(descriptor)
                userData = results.first
                print("🔄 OnboardingDataAccess: Loaded user data (fallback) - firstName: \(userData?.firstName ?? "nil"), horoscope: \(userData?.welcomeHoroscope?.prefix(50) ?? "nil")")
            } catch {
                print("❌ Error loading user data: \(error)")
            }
        }
    }
    
    // Load user data for a specific user ID
    func loadUserData(for userId: String) {
        print("🔄 OnboardingDataAccess: Loading user data for userId: \(userId)")
        let descriptor = FetchDescriptor<UserDataModel>(
            predicate: #Predicate<UserDataModel> { user in
                user.userId == userId
            }
        )
        do {
            let results = try modelContext.fetch(descriptor)
            userData = results.first
            print("🔄 OnboardingDataAccess: Loaded user data for userId \(userId) - firstName: \(userData?.firstName ?? "nil"), horoscope: \(userData?.welcomeHoroscope?.prefix(50) ?? "nil")")
        } catch {
            print("❌ Error loading user data for userId \(userId): \(error)")
        }
    }
    
    // Instance properties for Core Data access
    var coreDataFirstName: String {
        userData?.firstName ?? ""
    }
    var coreDataBirthDate: String {
        userData?.birthDate ?? ""
    }
    var coreDataBirthTime: String {
        userData?.birthTime ?? ""
    }
    var coreDataZodiacSign: String {
        userData?.zodiacSign ?? ""
    }
    var coreDataWelcomeHoroscope: String? {
        userData?.welcomeHoroscope
    }
    
    // Static properties: UserDefaults only
    static var firstName: String {
        return UserDefaults.standard.string(forKey: "userFirstName") ?? ""
    }
    static var birthDate: String {
        return UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
    }
    static var birthTime: String {
        return UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
    }
    static var zodiacSign: String {
        return UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
    }
    static var welcomeHoroscope: String? {
        return UserDefaults.standard.string(forKey: "welcomeHoroscope")
    }
    
    static var responses: [(String, String, String)] {
        guard let data = UserDefaults.standard.data(forKey: "userResponses"),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            return []
        }
        
        return jsonArray.compactMap { dict in
            guard let question = dict["question"], 
                  let key = dict["key"], 
                  let answer = dict["answer"] else { return nil }
            return (question, key, answer)
        }
    }
    
    static var hasCompletedOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    // Get a specific response with question
    static func getResponse(for key: String) -> (question: String, answer: String)? {
        let response = responses.first { $0.1 == key }
        guard let response = response else { return nil }
        return (question: response.0, answer: response.2)
    }
    
    // Get just the answer for a key (backward compatibility)
    static func getAnswer(for key: String) -> String? {
        return getResponse(for: key)?.answer
    }
    
    // Clear all onboarding data (useful for testing or logout)
    static func clearOnboardingData() {
        UserDefaults.standard.removeObject(forKey: "userFirstName")
        UserDefaults.standard.removeObject(forKey: "userBirthDate")
        UserDefaults.standard.removeObject(forKey: "userBirthTime")
        UserDefaults.standard.removeObject(forKey: "userZodiacSign")
        UserDefaults.standard.removeObject(forKey: "userResponses")
        // Note: hasCompletedOnboarding is preserved and managed separately
    }
    
    // Clear onboarding completion flag (for testing purposes)
    static func clearOnboardingCompletionFlag() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    
    // Clear all data (called on first launch after installation)
    static func clearAllData() {
        print("🗑️ OnboardingDataAccess: Clearing all data")
        
        // Clear all UserDefaults data
        clearOnboardingData()
        clearOnboardingCompletionFlag()
        
        // Clear additional keys
        UserDefaults.standard.removeObject(forKey: "lastLoggedInEmail")
        UserDefaults.standard.removeObject(forKey: "profileUUID")
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "welcomeHoroscope")
        
        print("✅ OnboardingDataAccess: All data cleared")
    }
    
    // Store last logged-in email
    static func storeLastLoggedInEmail(_ email: String) {
        UserDefaults.standard.set(email, forKey: "lastLoggedInEmail")
    }
    
    // Get last logged-in email
    static var lastLoggedInEmail: String {
        return UserDefaults.standard.string(forKey: "lastLoggedInEmail") ?? ""
    }
    
    // Store profile UUID
    static func storeProfileUUID(_ profileUUID: String) {
        UserDefaults.standard.set(profileUUID, forKey: "profileUUID")
    }
    
    // Get profile UUID
    static var profileUUID: String {
        return UserDefaults.standard.string(forKey: "profileUUID") ?? ""
    }
    
    func setHoroscopeGenerationState(isGenerating: Bool, didGenerate: Bool = false) {
        self.isGeneratingHoroscope = isGenerating
        self.didGenerateHoroscope = didGenerate
        print("🔄 OnboardingDataAccess: Horoscope state updated - generating: \(isGenerating), didGenerate: \(didGenerate)")
    }
    
    /// Check if horoscope generation is currently in progress
    var isHoroscopeGenerating: Bool {
        return isGeneratingHoroscope
    }
    
    /// Check if horoscope has been generated
    var hasGeneratedHoroscope: Bool {
        return didGenerateHoroscope
    }
    
    /// Get the current horoscope generation status as a tuple
    var horoscopeGenerationStatus: (isGenerating: Bool, didGenerate: Bool) {
        return (isGeneratingHoroscope, didGenerateHoroscope)
    }
} 