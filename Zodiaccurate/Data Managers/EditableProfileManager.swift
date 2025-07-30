//
//  EditableProfileManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class EditableProfileManager: ObservableObject {
    @Published var editableProfile: EditableProfile?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadEditableProfile()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadEditableProfile()
    }
    
    private func loadEditableProfile() {
        // Try to load existing editable profile from UserDefaults
        if let profileData = UserDefaults.standard.data(forKey: "editableProfile"),
           let profile = try? JSONDecoder().decode(EditableProfile.self, from: profileData) {
            editableProfile = profile
            return
        }
        
        // If no editable profile exists, create one from onboarding data
        editableProfile = EditableProfile.fromOnboardingData()
        saveEditableProfile()
    }
    
    private func saveEditableProfile() {
        guard let profile = editableProfile else { return }
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "editableProfile")
        }
    }
    
    // MARK: - Profile Properties
    
    var firstName: String {
        return editableProfile?.firstName ?? OnboardingDataAccess.firstName
    }
    
    var birthDate: Date {
        return editableProfile?.birthDate ?? OnboardingDataAccess.birthDate.toDate() ?? Date()
    }
    
    var birthTime: Date {
        return editableProfile?.birthTime ?? OnboardingDataAccess.birthTime.toDate() ?? Date()
    }
    
    var zodiacSign: String {
        return editableProfile?.zodiacSign ?? OnboardingDataAccess.zodiacSign
    }
    
    // MARK: - Profile Update Methods
    
    func updateFirstName(_ name: String) {
        if editableProfile == nil {
            editableProfile = EditableProfile.fromOnboardingData()
        }
        editableProfile?.firstName = name
        saveEditableProfile()
    }
    
    func updateBirthDate(_ date: Date) {
        if editableProfile == nil {
            editableProfile = EditableProfile.fromOnboardingData()
        }
        editableProfile?.birthDate = date
        saveEditableProfile()
    }
    
    func updateBirthTime(_ time: Date) {
        if editableProfile == nil {
            editableProfile = EditableProfile.fromOnboardingData()
        }
        editableProfile?.birthTime = time
        saveEditableProfile()
    }
    
    func updateZodiacSign(_ sign: String) {
        if editableProfile == nil {
            editableProfile = EditableProfile.fromOnboardingData()
        }
        editableProfile?.zodiacSign = sign
        saveEditableProfile()
    }
    
    // MARK: - Reset Methods
    
    func resetToOnboardingData() {
        editableProfile = EditableProfile.fromOnboardingData()
        saveEditableProfile()
    }
    
    func resetToDefault() {
        editableProfile = EditableProfile.fromOnboardingData()
        saveEditableProfile()
    }
    
    // MARK: - Helper Methods
    
    func formatBirthDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: birthDate)
    }
    
    func formatBirthTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: birthTime)
    }
    
    // Check if profile has been modified from onboarding data
    var hasBeenModified: Bool {
        guard let profile = editableProfile else { return false }
        
        return profile.firstName != OnboardingDataAccess.firstName ||
               profile.birthDate != (OnboardingDataAccess.birthDate.toDate() ?? Date()) ||
               profile.birthTime != (OnboardingDataAccess.birthTime.toDate() ?? Date()) ||
               profile.zodiacSign != OnboardingDataAccess.zodiacSign
    }
}

// MARK: - Editable Profile Struct
struct EditableProfile: Codable {
    var firstName: String
    var birthDate: Date
    var birthTime: Date
    var zodiacSign: String
    var lastModified: Date
    
    init(firstName: String = "", 
         birthDate: Date = Date(), 
         birthTime: Date = Date(), 
         zodiacSign: String = "") {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.lastModified = Date()
    }
    
    // Initialize from onboarding data
    static func fromOnboardingData() -> EditableProfile {
        let onboardingFirstName = OnboardingDataAccess.firstName
        let onboardingBirthDate = OnboardingDataAccess.birthDate.toDate() ?? Date()
        let onboardingBirthTime = OnboardingDataAccess.birthTime.toDate() ?? Date()
        let onboardingZodiacSign = OnboardingDataAccess.zodiacSign
        
        return EditableProfile(
            firstName: onboardingFirstName,
            birthDate: onboardingBirthDate,
            birthTime: onboardingBirthTime,
            zodiacSign: onboardingZodiacSign
        )
    }
}

// MARK: - String Extension for Date Conversion
extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: self) {
            return date
        }
        
        // Try alternative format
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.date(from: self)
    }
} 