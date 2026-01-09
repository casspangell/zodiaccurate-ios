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
    
    /// Get all responses for a user
    func getResponses(userId: String) async throws -> [String: Any]? {
        let snapshot = try await database.child("responses").child(userId).getData()
        
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
}
