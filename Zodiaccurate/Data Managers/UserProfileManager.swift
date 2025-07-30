//
//  UserProfileManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/30/25.
//

import Foundation
import SwiftUI

class UserProfileManager: ObservableObject {
    @Published var firstName: String = ""
    @Published var birthDate: String = ""
    @Published var birthTime: String = ""
    @Published var zodiacSign: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let firstNameKey = "userFirstName"
    private let birthDateKey = "userBirthDate"
    private let birthTimeKey = "userBirthTime"
    private let zodiacSignKey = "userZodiacSign"
    
    init() {
        print("👤 UserProfileManager initialized")
        loadProfile()
    }
    
    // MARK: - Profile Loading
    
    func loadProfile() {
        print("👤 Loading user profile...")
        
        firstName = userDefaults.string(forKey: firstNameKey) ?? ""
        birthDate = userDefaults.string(forKey: birthDateKey) ?? ""
        birthTime = userDefaults.string(forKey: birthTimeKey) ?? ""
        zodiacSign = userDefaults.string(forKey: zodiacSignKey) ?? ""
        
        print("👤 Profile loaded - Name: '\(firstName)', Zodiac: '\(zodiacSign)'")
    }
    
    // MARK: - Profile Updates
    
    func updateFirstName(_ name: String) {
        firstName = name
        userDefaults.set(name, forKey: firstNameKey)
        print("👤 First name updated to: '\(name)'")
    }
    
    func updateBirthDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        birthDate = formatter.string(from: date)
        userDefaults.set(birthDate, forKey: birthDateKey)
        
        // Recalculate zodiac sign when birth date changes
        calculateZodiacSign()
        
        print("👤 Birth date updated to: '\(birthDate)'")
    }
    
    func updateBirthTime(_ time: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        birthTime = formatter.string(from: time)
        userDefaults.set(birthTime, forKey: birthTimeKey)
        
        // Recalculate zodiac sign when birth time changes
        calculateZodiacSign()
        
        print("👤 Birth time updated to: '\(birthTime)'")
    }
    
    // MARK: - Zodiac Sign Calculation
    
    private func calculateZodiacSign() {
        zodiacSign = ZodiacUtility.calculateZodiacSign(birthDate: birthDate, birthTime: birthTime)
        userDefaults.set(zodiacSign, forKey: zodiacSignKey)
        
        print("♈ Zodiac sign calculated: '\(zodiacSign)'")
    }
    
    // MARK: - Save Changes
    
    func saveChanges() throws {
        print("👤 Saving profile changes...")
        
        // Validate required fields
        guard !firstName.isEmpty else {
            throw UserProfileError.missingFirstName
        }
        
        guard !birthDate.isEmpty else {
            throw UserProfileError.missingBirthDate
        }
        
        guard !birthTime.isEmpty else {
            throw UserProfileError.missingBirthTime
        }
        
        // All data is already saved to UserDefaults in the update methods
        // Just ensure zodiac sign is calculated
        calculateZodiacSign()
        
        print("👤 Profile changes saved successfully")
    }
    
    // MARK: - Profile Validation
    
    var isProfileComplete: Bool {
        return !firstName.isEmpty && !birthDate.isEmpty && !birthTime.isEmpty && !zodiacSign.isEmpty
    }
    
    var hasValidBirthData: Bool {
        return ZodiacUtility.getBirthDateTime(birthDate: birthDate, birthTime: birthTime) != nil
    }
    
    // MARK: - Profile Reset
    
    func resetProfile() {
        print("👤 Resetting user profile...")
        
        firstName = ""
        birthDate = ""
        birthTime = ""
        zodiacSign = ""
        
        userDefaults.removeObject(forKey: firstNameKey)
        userDefaults.removeObject(forKey: birthDateKey)
        userDefaults.removeObject(forKey: birthTimeKey)
        userDefaults.removeObject(forKey: zodiacSignKey)
        
        print("👤 Profile reset complete")
    }
}

// MARK: - User Profile Errors

enum UserProfileError: Error, LocalizedError {
    case missingFirstName
    case missingBirthDate
    case missingBirthTime
    case invalidBirthData
    
    var errorDescription: String? {
        switch self {
        case .missingFirstName:
            return "First name is required"
        case .missingBirthDate:
            return "Birth date is required"
        case .missingBirthTime:
            return "Birth time is required"
        case .invalidBirthData:
            return "Invalid birth date or time"
        }
    }
}

