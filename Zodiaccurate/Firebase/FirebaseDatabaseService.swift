//
//  FirebaseDatabaseService.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import FirebaseDatabase

// MARK: - Firebase Realtime Database Service

@MainActor
class FirebaseDatabaseService: ObservableObject {
    private let database = Database.database().reference()
    
    // MARK: - User Management
    
    /// Save or update user data to /users/{uid}
    func saveUser(userId: String, email: String, name: String, timezone: String? = nil) async throws {
        var userData: [String: Any] = [
            "uuid": userId,
            "email": email,
            "name": name
        ]
        
        // Add timezone if provided
        if let timezone = timezone, !timezone.isEmpty {
            userData["timezone"] = timezone
        }
        
        do {
            try await database.child("users").child(userId).setValue(userData)
            print("✅ User saved to Firebase: /users/\(userId)")
        } catch {
            print("❌ Failed to save user to Firebase: \(error)")
            throw error
        }
    }
    
    /// Update user name
    func updateUserName(userId: String, name: String) async throws {
        do {
            try await database.child("users").child(userId).child("name").setValue(name)
            print("✅ User name updated in Firebase: /users/\(userId)/name")
        } catch {
            print("❌ Failed to update user name in Firebase: \(error)")
            throw error
        }
    }
    
    /// Update user profile data at /users/{uid} (name and timezone only, as email is not editable)
    func updateUserProfile(userId: String, name: String, timezone: String?) async throws {
        var updates: [String: Any] = [
            "name": name
        ]
        
        // Add timezone if provided
        if let timezone = timezone, !timezone.isEmpty {
            updates["timezone"] = timezone
        } else {
            // If timezone is nil/empty, remove it from Firebase
            updates["timezone"] = NSNull()
        }
        
        do {
            // Update each field individually to avoid overwriting other fields like email, uuid
            for (key, value) in updates {
                if value is NSNull {
                    try await database.child("users").child(userId).child(key).removeValue()
                } else {
                    try await database.child("users").child(userId).child(key).setValue(value)
                }
            }
            print("✅ User profile updated in Firebase: /users/\(userId)")
        } catch {
            print("❌ Failed to update user profile in Firebase: \(error)")
            throw error
        }
    }
    
    // MARK: - Response Management
    
    /// Save or update onboarding responses to /responses/{uid}
    func saveOnboardingResponses(userId: String, responses: [String: Any]) async throws {
        do {
            try await database.child("responses").child(userId).setValue(responses)
            print("✅ Onboarding responses saved to Firebase: /responses/\(userId)")
        } catch {
            print("❌ Failed to save onboarding responses to Firebase: \(error)")
            throw error
        }
    }
    
    /// Update a single response value
    func updateResponse(userId: String, key: String, value: Any) async throws {
        do {
            try await database.child("responses").child(userId).child(key).setValue(value)
            print("✅ Response updated in Firebase: /responses/\(userId)/\(key)")
        } catch {
            print("❌ Failed to update response in Firebase: \(error)")
            throw error
        }
    }
    
    /// Update onboarding profile fields in /responses/{uid}/Onboarding (firstName, birthDate, birthTime, zodiacSign, timezone)
    func updateOnboardingProfileFields(userId: String, firstName: String, birthDate: String, birthTime: String, zodiacSign: String, timezone: String?) async throws {
        let updates: [String: Any] = [
            "firstName": firstName,
            "birthDate": birthDate,
            "birthTime": birthTime,
            "zodiacSign": zodiacSign
        ]
        
        do {
            // Get existing onboarding responses first
            var existingResponses: [String: Any] = [:]
            if let responses = try? await getQuestionnaireResponses(userId: userId, questionnaireTitle: "Onboarding") {
                existingResponses = responses
            }
            
            // Merge updates with existing responses
            for (key, value) in updates {
                existingResponses[key] = value
            }
            
            // Add timezone if provided
            if let timezone = timezone, !timezone.isEmpty {
                existingResponses["timezone"] = timezone
            }
            
            // Save updated responses
            try await saveQuestionnaireResponses(userId: userId, questionnaireTitle: "Onboarding", responses: existingResponses)
            print("✅ Onboarding profile fields updated in Firebase: /responses/\(userId)/Onboarding")
        } catch {
            print("❌ Failed to update onboarding profile fields in Firebase: \(error)")
            throw error
        }
    }
    
    /// Get all responses for a user
    func getResponses(userId: String) async throws -> [String: Any]? {
        let snapshot = try await database.child("responses").child(userId).getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        
        return value
    }
    
    /// Save questionnaire responses to /responses/{uuid}/{questionnaire title}
    func saveQuestionnaireResponses(userId: String, questionnaireTitle: String, responses: [String: Any]) async throws {
        do {
            // Sanitize questionnaire title for Firebase (replace spaces with underscores or remove special chars)
            let sanitizedTitle = questionnaireTitle.replacingOccurrences(of: " ", with: "_")
            try await database.child("responses").child(userId).child(sanitizedTitle).setValue(responses)
            print("✅ Questionnaire responses saved to Firebase: /responses/\(userId)/\(sanitizedTitle)")
        } catch {
            print("❌ Failed to save questionnaire responses to Firebase: \(error)")
            throw error
        }
    }
    
    /// Get questionnaire responses from /responses/{uuid}/{questionnaire title}
    func getQuestionnaireResponses(userId: String, questionnaireTitle: String) async throws -> [String: Any]? {
        let sanitizedTitle = questionnaireTitle.replacingOccurrences(of: " ", with: "_")
        let snapshot = try await database.child("responses").child(userId).child(sanitizedTitle).getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        
        return value
    }
    
    /// Get user data
    func getUser(userId: String) async throws -> [String: Any]? {
        let snapshot = try await database.child("users").child(userId).getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        
        return value
    }
    
    // MARK: - Horoscope Management
    
    /// Save horoscope to /zodiac/{uuid}/{key}
    func saveHoroscope(userId: String, horoscope: Horoscope) async throws {
        var horoscopeData: [String: Any] = [
            "title": horoscope.title,
            "message": horoscope.message,
            "key": horoscope.key,
            "createdAt": horoscope.createdAt.timeIntervalSince1970
        ]
        
        // Add audioFilePath if available
        if let audioFilePath = horoscope.audioFilePath {
            horoscopeData["audioFilePath"] = audioFilePath
        }
        
        do {
            try await database.child("zodiac").child(userId).child(horoscope.key).setValue(horoscopeData)
            print("✅ Horoscope saved to Firebase: /zodiac/\(userId)/\(horoscope.key)")
        } catch {
            print("❌ Failed to save horoscope to Firebase: \(error)")
            throw error
        }
    }
}
