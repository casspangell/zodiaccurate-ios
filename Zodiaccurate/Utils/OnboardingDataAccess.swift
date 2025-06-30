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
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadUserData()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadUserData()
    }
    
    // Load user data from SwiftData
    private func loadUserData() {
        let descriptor = FetchDescriptor<UserDataModel>()
        do {
            let results = try modelContext.fetch(descriptor)
            userData = results.first
        } catch {
            print("❌ Error loading user data: \(error)")
        }
    }
    
    // Quick access methods for UserDefaults data
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
} 