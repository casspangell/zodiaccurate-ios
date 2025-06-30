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
    @Published var isLoading = false
    @Published var error: String?
    
    private let database = Database.database(url: "https://zodiaccurate-e9aaf-default-rtdb.firebaseio.com")
    private let trialUsersRef: DatabaseReference
    private let onboardingRef: DatabaseReference
    
    init() {
        self.trialUsersRef = database.reference().child("trial_users")
        self.onboardingRef = database.reference().child("onboarding")
    }
    
    // MARK: - Trial Users Management
    
    /// Save user email to trial_users table
    func saveTrialUser(email: String, userId: String, profileUUID: String) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Format email: remove periods and replace @ with _at_
            let formattedEmail = formatEmailForDatabase(email)
            
            let trialUserData: [String: Any] = [
                "email": formattedEmail,
                "originalEmail": email, // Keep original email for reference
                "userId": userId,
                "profileUUID": profileUUID,
                "createdAt": ServerValue.timestamp(),
                "lastLogin": ServerValue.timestamp(),
                "status": "active",
                "trialStartDate": ServerValue.timestamp()
            ]
            
            // Save to trial_users table using userId as key
            try await trialUsersRef.child(userId).setValue(trialUserData)
            
            print("✅ Trial user saved successfully: \(email) -> \(formattedEmail)")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error saving trial user: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Update trial user last login
    func updateTrialUserLastLogin(userId: String) async throws {
        do {
            let updateData: [String: Any] = [
                "lastLogin": ServerValue.timestamp()
            ]
            
            try await trialUsersRef.child(userId).updateChildValues(updateData)
            print("✅ Trial user last login updated: \(userId)")
            
        } catch {
            print("❌ Error updating trial user last login: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get trial user data
    func getTrialUser(userId: String) async throws -> [String: Any]? {
        do {
            let snapshot = try await trialUsersRef.child(userId).getData()
            
            if snapshot.exists() {
                return snapshot.value as? [String: Any]
            } else {
                return nil
            }
            
        } catch {
            print("❌ Error getting trial user: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Onboarding Data Management
    
    /// Save onboarding data to onboarding table
    func saveOnboardingData(userId: String, profileUUID: String, userData: UserData) async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // Convert responses to a more structured format
            var responsesDict: [String: Any] = [:]
            for (question, key, answer) in userData.responses {
                responsesDict[key] = [
                    "question": question,
                    "answer": answer
                ]
            }
            
            let onboardingData: [String: Any] = [
                "userId": userId,
                "profileUUID": profileUUID,
                "firstName": userData.firstName,
                "birthDate": userData.birthDate,
                "birthTime": userData.birthTime,
                "zodiacSign": userData.zodiacSign,
                "responses": responsesDict,
                "completedAt": ServerValue.timestamp(),
                "hasCompletedOnboarding": true
            ]
            
            // Save to onboarding table using userId as key
            try await onboardingRef.child(userId).setValue(onboardingData)
            
            print("✅ Onboarding data saved successfully for user: \(userId)")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ Error saving onboarding data: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get onboarding data for a user
    func getOnboardingData(userId: String) async throws -> [String: Any]? {
        do {
            let snapshot = try await onboardingRef.child(userId).getData()
            
            if snapshot.exists() {
                return snapshot.value as? [String: Any]
            } else {
                return nil
            }
            
        } catch {
            print("❌ Error getting onboarding data: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Update onboarding data
    func updateOnboardingData(userId: String, updates: [String: Any]) async throws {
        do {
            try await onboardingRef.child(userId).updateChildValues(updates)
            print("✅ Onboarding data updated for user: \(userId)")
            
        } catch {
            print("❌ Error updating onboarding data: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Analytics and Tracking
    
    /// Track user engagement
    func trackUserEngagement(userId: String, action: String, data: [String: Any] = [:]) async {
        do {
            let engagementData: [String: Any] = [
                "action": action,
                "timestamp": ServerValue.timestamp(),
                "data": data
            ]
            
            try await database.reference().child("analytics").child(userId).childByAutoId().setValue(engagementData)
            print("📊 User engagement tracked: \(action) for user: \(userId)")
            
        } catch {
            print("❌ Error tracking user engagement: \(error.localizedDescription)")
        }
    }
    
    /// Track horoscope generation
    func trackHoroscopeGeneration(userId: String, horoscopeType: String, success: Bool) async {
        await trackUserEngagement(
            userId: userId,
            action: "horoscope_generated",
            data: [
                "type": horoscopeType,
                "success": success
            ]
        )
    }
    
    // MARK: - Utility Methods
    
    /// Check if user exists in trial_users
    func isTrialUser(userId: String) async throws -> Bool {
        do {
            let snapshot = try await trialUsersRef.child(userId).getData()
            return snapshot.exists()
        } catch {
            print("❌ Error checking trial user status: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get user's trial status
    func getTrialStatus(userId: String) async throws -> String? {
        do {
            let snapshot = try await trialUsersRef.child(userId).child("status").getData()
            
            if snapshot.exists() {
                return snapshot.value as? String
            } else {
                return nil
            }
            
        } catch {
            print("❌ Error getting trial status: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Find trial user by formatted email
    func findTrialUserByFormattedEmail(_ formattedEmail: String) async throws -> [String: Any]? {
        do {
            let snapshot = try await trialUsersRef.queryOrdered(byChild: "email").queryEqual(toValue: formattedEmail).getData()
            
            if snapshot.exists() {
                // Get the first (and should be only) result
                if let children = snapshot.children.allObjects as? [DataSnapshot], let firstChild = children.first {
                    return firstChild.value as? [String: Any]
                }
            }
            return nil
            
        } catch {
            print("❌ Error finding trial user by formatted email: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Find trial user by original email
    func findTrialUserByOriginalEmail(_ originalEmail: String) async throws -> [String: Any]? {
        do {
            let snapshot = try await trialUsersRef.queryOrdered(byChild: "originalEmail").queryEqual(toValue: originalEmail).getData()
            
            if snapshot.exists() {
                // Get the first (and should be only) result
                if let children = snapshot.children.allObjects as? [DataSnapshot], let firstChild = children.first {
                    return firstChild.value as? [String: Any]
                }
            }
            return nil
            
        } catch {
            print("❌ Error finding trial user by original email: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Utility Methods
    
    /// Format email for database storage: replace periods with _ and @ with _at_
    private func formatEmailForDatabase(_ email: String) -> String {
        return email
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_at_")
    }
    
    /// Reverse format email from database storage back to original format
    func reverseEmailFormat(_ formattedEmail: String) -> String {
        return formattedEmail
            .replacingOccurrences(of: "_at_", with: "@")
            .replacingOccurrences(of: "_", with: ".")
            // Note: This will replace ALL underscores with periods, which may not be accurate
            // if the original email had underscores. Use originalEmail field for exact restoration.
    }
}

// MARK: - Database Models

struct TrialUser {
    let email: String // Formatted email (without periods and @ symbol)
    let originalEmail: String // Original email format
    let userId: String
    let profileUUID: String
    let createdAt: Date
    let lastLogin: Date
    let status: String
    let trialStartDate: Date
    
    init(from dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.originalEmail = dictionary["originalEmail"] as? String ?? ""
        self.userId = dictionary["userId"] as? String ?? ""
        self.profileUUID = dictionary["profileUUID"] as? String ?? ""
        self.createdAt = Date(timeIntervalSince1970: (dictionary["createdAt"] as? TimeInterval ?? 0) / 1000)
        self.lastLogin = Date(timeIntervalSince1970: (dictionary["lastLogin"] as? TimeInterval ?? 0) / 1000)
        self.status = dictionary["status"] as? String ?? "unknown"
        self.trialStartDate = Date(timeIntervalSince1970: (dictionary["trialStartDate"] as? TimeInterval ?? 0) / 1000)
    }
}

struct OnboardingData {
    let userId: String
    let profileUUID: String
    let firstName: String
    let birthDate: String
    let birthTime: String
    let zodiacSign: String
    let responses: [String: [String: String]]
    let completedAt: Date
    let hasCompletedOnboarding: Bool
    
    init(from dictionary: [String: Any]) {
        self.userId = dictionary["userId"] as? String ?? ""
        self.profileUUID = dictionary["profileUUID"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.birthDate = dictionary["birthDate"] as? String ?? ""
        self.birthTime = dictionary["birthTime"] as? String ?? ""
        self.zodiacSign = dictionary["zodiacSign"] as? String ?? ""
        
        // Parse responses
        var parsedResponses: [String: [String: String]] = [:]
        if let responses = dictionary["responses"] as? [String: [String: Any]] {
            for (key, value) in responses {
                if let responseData = value as? [String: String] {
                    parsedResponses[key] = responseData
                }
            }
        }
        self.responses = parsedResponses
        
        self.completedAt = Date(timeIntervalSince1970: (dictionary["completedAt"] as? TimeInterval ?? 0) / 1000)
        self.hasCompletedOnboarding = dictionary["hasCompletedOnboarding"] as? Bool ?? false
    }
} 