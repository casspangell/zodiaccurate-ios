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
    @Published var dataRefreshTrigger: Bool = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Don't automatically load data on init to prevent duplicate loading
        // Data will be loaded when explicitly called by views
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        // Don't automatically load data when updating context to prevent duplicate loading
        // Data will be loaded when explicitly called by views
    }
    
    // Refresh the context and reload data
    func refreshAndLoadUserData() {
        print("🔄 OnboardingDataAccess: Refreshing context and reloading data...")
        
        // Add a longer delay to ensure any pending saves have completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadUserData()
        }
    }
    
    // Load user data from SwiftData
    func loadUserData() {
        print("🔄 OnboardingDataAccess: Loading user data...")
        
        // Try to load data for the current user ID first (Firebase UID)
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            print("🔄 OnboardingDataAccess: Found Firebase userId in UserDefaults: \(userId)")
            loadUserData(for: userId)
            return
        }
        
        // Try to load data for onboarding UUID
        if let onboardingUUID = UserDefaults.standard.string(forKey: "onboardingUUID") {
            print("🔄 OnboardingDataAccess: Found onboarding UUID in UserDefaults: \(onboardingUUID)")
            loadUserData(for: onboardingUUID)
            return
        }
        
        print("🔄 OnboardingDataAccess: No specific userId found, loading most recent data (anonymous)")
        // During onboarding, user is anonymous - load the most recent data
        let descriptor = FetchDescriptor<UserDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            let results = try modelContext.fetch(descriptor)
            
            // Debug: Print all results to see what's in the database
            print("🔍 OnboardingDataAccess: Found \(results.count) total user data records:")
            for (index, result) in results.enumerated() {
                print("   Record \(index): firstName=\(result.firstName), userId=\(result.userId ?? "nil"), horoscope=\(result.welcomeHoroscope?.prefix(30) ?? "nil")")
            }
            
            // Prioritize records with horoscopes when there are multiple records
            if results.count > 1 {
                // First, try to find a record with a horoscope
                if let recordWithHoroscope = results.first(where: { $0.welcomeHoroscope != nil && !$0.welcomeHoroscope!.isEmpty }) {
                    userData = recordWithHoroscope
                    print("🔄 OnboardingDataAccess: Found record with horoscope - firstName: \(userData?.firstName ?? "nil"), userId: \(userData?.userId ?? "nil"), horoscope: \(userData?.welcomeHoroscope?.prefix(50) ?? "nil")")
                } else {
                    // Fall back to most recent record
                    userData = results.first
                    print("🔄 OnboardingDataAccess: No horoscope found, using most recent record - firstName: \(userData?.firstName ?? "nil"), userId: \(userData?.userId ?? "nil"), horoscope: \(userData?.welcomeHoroscope?.prefix(50) ?? "nil")")
                }
            } else {
                // Only one record, use it
                userData = results.first
                print("🔄 OnboardingDataAccess: Single record found - firstName: \(userData?.firstName ?? "nil"), userId: \(userData?.userId ?? "nil"), horoscope: \(userData?.welcomeHoroscope?.prefix(50) ?? "nil")")
            }
            
            // Trigger view refresh immediately
            DispatchQueue.main.async {
                self.dataRefreshTrigger.toggle()
            }
        } catch {
            print("❌ Error loading user data: \(error)")
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
    
    // Static properties: UserDefaults only (for flags and app state)
    static var hasCompletedOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    // Static fallback properties for backward compatibility (read from UserDefaults)
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
    
    // Instance properties for Core Data access (replaces static UserDefaults properties)
    var firstName: String {
        return userData?.firstName ?? ""
    }
    
    var birthDate: String {
        return userData?.birthDate ?? ""
    }
    
    var birthTime: String {
        return userData?.birthTime ?? ""
    }
    
    var zodiacSign: String {
        return userData?.zodiacSign ?? ""
    }
    
    var welcomeHoroscope: String? {
        return userData?.welcomeHoroscope
    }
    
    var responses: [(String, String, String)] {
        return userData?.responseTuples ?? []
    }
    
    // Get a specific response with question (instance method for Core Data)
    func getResponse(for key: String) -> (question: String, answer: String)? {
        let response = responses.first { $0.1 == key }
        guard let response = response else { return nil }
        return (question: response.0, answer: response.2)
    }
    
    // Get just the answer for a key (instance method for Core Data)
    func getAnswer(for key: String) -> String? {
        return getResponse(for: key)?.answer
    }
    
    // Static methods for backward compatibility (fallback to UserDefaults)
    static func getResponse(for key: String) -> (question: String, answer: String)? {
        // Fallback to UserDefaults for static access
        if let data = UserDefaults.standard.data(forKey: "userResponses"),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            for response in jsonArray {
                if let question = response["question"], 
                   let responseKey = response["key"], 
                   let answer = response["answer"],
                   responseKey == key {
                    return (question: question, answer: answer)
                }
            }
        }
        return nil
    }
    
    static func getAnswer(for key: String) -> String? {
        return getResponse(for: key)?.answer
    }
    
    // Clear onboarding data flags (user data is now in Core Data)
    static func clearOnboardingData() {
        // User data is now stored in Core Data, so we only clear flags
        // Note: hasCompletedOnboarding is preserved and managed separately
    }
    
    // Clear onboarding completion flag (for testing purposes)
    static func clearOnboardingCompletionFlag() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    
    // Clear all data (called on first launch after installation)
    static func clearAllData() {
        print("🗑️ OnboardingDataAccess: Clearing all data")
        
        // Clear flags and app state (user data is in Core Data)
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