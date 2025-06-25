//
//  UserDataManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserDataManager: ObservableObject {
    @Published var currentUserData: UserDataModel?
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }
    
    func saveUserData(_ userData: UserData, userId: String? = nil) {
        print("💾 UserDataManager: Starting save operation...")
        print("👤 User ID: \(userId ?? "Anonymous")")
        
        // Convert UserData to UserDataModel
        let responses = userData.responses.map { "\($0.0)|\($0.1)|\($0.2)" }
        
        let userDataModel = UserDataModel(
            firstName: userData.firstName,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            zodiacSign: userData.zodiacSign,
            responses: responses,
            userId: userId
        )
        
        print("🔧 Created UserDataModel with zodiac sign: \(userDataModel.zodiacSign)")
        
        // Delete any existing user data for this user
        if let userId = userId {
            print("🗑️ Deleting existing user data for user: \(userId)")
            deleteUserData(for: userId)
        }
        
        // Save new user data
        print("📝 Inserting new user data into Core Data...")
        modelContext.insert(userDataModel)
        
        do {
            try modelContext.save()
            currentUserData = userDataModel
            print("✅ User data saved to Core Data successfully!")
            print("🌟 Zodiac sign '\(userDataModel.zodiacSign)' has been persisted")
            print("📅 User data created at: \(userDataModel.createdAt)")
        } catch {
            print("❌ Error saving user data to Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    func loadUserData(for userId: String? = nil) -> UserDataModel? {
        print("🔍 UserDataManager: Loading user data for user ID: \(userId ?? "Anonymous")")
        
        let descriptor: FetchDescriptor<UserDataModel>
        if let userId = userId {
            descriptor = FetchDescriptor<UserDataModel>(
                predicate: #Predicate<UserDataModel> { user in
                    user.userId == userId
                }
            )
        } else {
            descriptor = FetchDescriptor<UserDataModel>()
        }
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let userData = results.first {
                print("✅ User data loaded successfully from Core Data")
                print("🌟 Found zodiac sign: \(userData.zodiacSign)")
                return userData
            } else {
                print("⚠️ No user data found in Core Data")
                return nil
            }
        } catch {
            print("❌ Error loading user data from Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
        return nil
    }
    
    func deleteUserData(for userId: String) {
        print("🗑️ UserDataManager: Deleting user data for user ID: \(userId)")
        
        let descriptor = FetchDescriptor<UserDataModel>(
            predicate: #Predicate<UserDataModel> { user in
                user.userId == userId
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            print("📊 Found \(results.count) user data records to delete")
            
            for userData in results {
                print("🗑️ Deleting user data with zodiac sign: \(userData.zodiacSign)")
                modelContext.delete(userData)
            }
            try modelContext.save()
            print("✅ User data deleted successfully from Core Data")
        } catch {
            print("❌ Error deleting user data from Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    func updateUserData(_ userData: UserData, userId: String? = nil) {
        print("🔄 UserDataManager: Updating user data for user ID: \(userId ?? "Anonymous")")
        
        if let existingData = loadUserData(for: userId) {
            print("📝 Updating existing user data in Core Data")
            // Update existing data
            existingData.firstName = userData.firstName
            existingData.birthDate = userData.birthDate
            existingData.birthTime = userData.birthTime
            existingData.zodiacSign = userData.zodiacSign
            existingData.responses = userData.responses.map { "\($0.0)|\($0.1)|\($0.2)" }
            
            do {
                try modelContext.save()
                currentUserData = existingData
                print("✅ User data updated successfully in Core Data")
                print("🌟 Updated zodiac sign: \(existingData.zodiacSign)")
            } catch {
                print("❌ Error updating user data in Core Data: \(error)")
                print("🔍 Error details: \(error.localizedDescription)")
            }
        } else {
            print("📝 No existing data found, creating new user data")
            // Create new data
            saveUserData(userData, userId: userId)
        }
    }
} 