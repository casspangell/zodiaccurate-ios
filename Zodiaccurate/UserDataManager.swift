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
    
    func saveUserData(firstName: String, 
                     birthDate: String, 
                     birthTime: String, 
                     zodiacSign: String, 
                     responses: [OnboardingResponse], 
                     userId: String? = nil,
                     welcomeHoroscope: String? = nil) {
        print("💾 UserDataManager: Starting save operation...")
        print("👤 User ID: \(userId ?? "Anonymous")")
        
        let userDataModel = UserDataModel(
            firstName: firstName,
            birthDate: birthDate,
            birthTime: birthTime,
            zodiacSign: zodiacSign,
            responses: responses,
            userId: userId,
            welcomeHoroscope: welcomeHoroscope
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
    
    // Convenience method for saving with tuple responses (for backward compatibility)
    func saveUserData(firstName: String, 
                     birthDate: String, 
                     birthTime: String, 
                     zodiacSign: String, 
                     responses: [(String, String, String)], 
                     userId: String? = nil,
                     welcomeHoroscope: String? = nil) {
        let onboardingResponses = responses.map { OnboardingResponse(question: $0.0, key: $0.1, answer: $0.2) }
        saveUserData(firstName: firstName, 
                    birthDate: birthDate, 
                    birthTime: birthTime, 
                    zodiacSign: zodiacSign, 
                    responses: onboardingResponses, 
                    userId: userId, 
                    welcomeHoroscope: welcomeHoroscope)
    }
    
    // MARK: - UserData Methods
    
    /// Save UserData to Core Data
    func saveUserData(_ userData: UserData, userId: String? = nil) {
        print("💾 UserDataManager: Saving UserData...")
        print("👤 User ID: \(userId ?? "Anonymous")")
        print("📝 User data - firstName: \(userData.firstName), zodiac: \(userData.zodiacSign)")
        
        let onboardingResponses = userData.responses.map { OnboardingResponse(question: $0.0, key: $0.1, answer: $0.2) }
        
        let userDataModel = UserDataModel(
            firstName: userData.firstName,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            zodiacSign: userData.zodiacSign,
            responses: onboardingResponses,
            userId: userId,
            welcomeHoroscope: nil,
            hasCompletedOnboarding: true,
            hasAcceptedConsentPolicies: true
        )
        
        print("🔧 Created UserDataModel from UserData")
        print("🌟 Zodiac sign: \(userDataModel.zodiacSign)")
        print("✅ Onboarding complete: \(userDataModel.hasCompletedOnboarding)")
        print("✅ Consent accepted: \(userDataModel.hasAcceptedConsentPolicies)")
        
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
            print("✅ UserData saved to Core Data successfully!")
            print("📅 User data created at: \(userDataModel.createdAt)")
        } catch {
            print("❌ Error saving UserData to Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    /// Save UserData directly to UserDataModel
    func saveUserDataToUserDataModel(_ userData: UserData, userId: String? = nil) -> UserDataModel? {
        print("💾 UserDataManager: Saving UserData directly to UserDataModel...")
        print("👤 User ID: \(userId ?? "Anonymous")")
        print("📝 User data - firstName: \(userData.firstName), zodiac: \(userData.zodiacSign)")
        
        let onboardingResponses = userData.responses.map { OnboardingResponse(question: $0.0, key: $0.1, answer: $0.2) }
        
        let userDataModel = UserDataModel(
            firstName: userData.firstName,
            birthDate: userData.birthDate,
            birthTime: userData.birthTime,
            zodiacSign: userData.zodiacSign,
            responses: onboardingResponses,
            userId: userId,
            welcomeHoroscope: nil,
            hasCompletedOnboarding: true,
            hasAcceptedConsentPolicies: true
        )
        
        print("🔧 Created UserDataModel from UserData")
        print("🌟 Zodiac sign: \(userDataModel.zodiacSign)")
        print("✅ Onboarding complete: \(userDataModel.hasCompletedOnboarding)")
        print("✅ Consent accepted: \(userDataModel.hasAcceptedConsentPolicies)")
        
        // Delete any existing user data for this user
        if let userId = userId {
            print("🗑️ Deleting existing user data for user: \(userId)")
            deleteUserData(for: userId)
        }
        
        // Save new user data
        print("📝 Inserting new UserDataModel into Core Data...")
        modelContext.insert(userDataModel)
        
        do {
            try modelContext.save()
            currentUserData = userDataModel
            print("✅ UserDataModel saved to Core Data successfully!")
            print("📅 UserDataModel created at: \(userDataModel.createdAt)")
            print("🆔 UserDataModel ID: \(userDataModel.userId ?? "nil")")
            return userDataModel
        } catch {
            print("❌ Error saving UserDataModel to Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - UserProfile Methods
    
    /// Save UserProfile to Core Data
    func saveUserProfile(_ userProfile: UserProfile, userId: String? = nil, welcomeHoroscope: String? = nil) {
        print("💾 UserDataManager: Saving UserProfile...")
        print("👤 User ID: \(userId ?? "Anonymous")")
        print("📝 User profile - firstName: \(userProfile.firstName), zodiac: \(userProfile.zodiacSign)")
        
        let userDataModel = UserDataModel(
            profile: userProfile,
            userId: userId,
            welcomeHoroscope: welcomeHoroscope,
            hasCompletedOnboarding: true,
            hasAcceptedConsentPolicies: true
        )
        
        print("🔧 Created UserDataModel from UserProfile")
        print("🌟 Zodiac sign: \(userDataModel.zodiacSign)")
        print("✅ Onboarding complete: \(userDataModel.hasCompletedOnboarding)")
        print("✅ Consent accepted: \(userDataModel.hasAcceptedConsentPolicies)")
        
        // Delete any existing user data for this user
        if let userId = userId {
            print("🗑️ Deleting existing user data for user: \(userId)")
            deleteUserData(for: userId)
        }
        
        // Save new user data
        print("📝 Inserting new UserDataModel into Core Data...")
        modelContext.insert(userDataModel)
        
        do {
            try modelContext.save()
            currentUserData = userDataModel
            print("✅ UserProfile saved to Core Data successfully!")
            print("📅 User data created at: \(userDataModel.createdAt)")
        } catch {
            print("❌ Error saving UserProfile to Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    /// Load OnboardingUserData from Core Data
    func loadOnboardingUserData(for userId: String? = nil) -> OnboardingUserData? {
        guard let userDataModel = loadUserData(for: userId) else {
            print("⚠️ No UserDataModel found for OnboardingUserData conversion")
            return nil
        }
        
        print("🔄 Converting UserDataModel to OnboardingUserData...")
        
        // Convert string dates back to Date objects
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let birthDate = dateFormatter.date(from: userDataModel.birthDate)
        let birthTime = timeFormatter.date(from: userDataModel.birthTime)
        
        let onboardingData = OnboardingUserData(
            name: userDataModel.firstName.isEmpty ? nil : userDataModel.firstName,
            birthDate: birthDate,
            birthTime: birthTime,
            zodiacSign: userDataModel.zodiacSign.isEmpty ? nil : userDataModel.zodiacSign,
            consentGiven: userDataModel.hasAcceptedConsentPolicies
        )
        
        print("✅ Successfully converted to OnboardingUserData")
        print("📝 Name: \(onboardingData.name ?? "nil"), Zodiac: \(onboardingData.zodiacSign ?? "nil")")
        
        return onboardingData
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
                currentUserData = userData
                return userData
            } else {
                print("⚠️ No user data found in Core Data")
                currentUserData = nil
                return nil
            }
        } catch {
            print("❌ Error loading user data from Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            return nil
        }
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
            
            // Clear current user data if it was the one deleted
            if currentUserData?.userId == userId {
                currentUserData = nil
            }
        } catch {
            print("❌ Error deleting user data from Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    func updateUserData(firstName: String? = nil,
                       birthDate: String? = nil,
                       birthTime: String? = nil,
                       zodiacSign: String? = nil,
                       responses: [OnboardingResponse]? = nil,
                       welcomeHoroscope: String? = nil,
                       userId: String? = nil) {
        print("🔄 UserDataManager: Updating user data for user ID: \(userId ?? "Anonymous")")
        
        if let existingData = loadUserData(for: userId) {
            print("📝 Updating existing user data in Core Data")
            
            if let firstName = firstName {
                existingData.firstName = firstName
            }
            if let birthDate = birthDate {
                existingData.birthDate = birthDate
            }
            if let birthTime = birthTime {
                existingData.birthTime = birthTime
            }
            if let zodiacSign = zodiacSign {
                existingData.zodiacSign = zodiacSign
            }
            if let responses = responses {
                existingData.responseArray = responses
            }
            if let welcomeHoroscope = welcomeHoroscope {
                existingData.updateWelcomeHoroscope(welcomeHoroscope)
            }
            
            existingData.updatedAt = Date()
            
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
            print("⚠️ No existing user data found to update")
        }
    }
    
    // Convenience method for updating with tuple responses
    func updateUserData(firstName: String? = nil,
                       birthDate: String? = nil,
                       birthTime: String? = nil,
                       zodiacSign: String? = nil,
                       responses: [(String, String, String)]? = nil,
                       welcomeHoroscope: String? = nil,
                       userId: String? = nil) {
        let onboardingResponses = responses?.map { OnboardingResponse(question: $0.0, key: $0.1, answer: $0.2) }
        updateUserData(firstName: firstName,
                      birthDate: birthDate,
                      birthTime: birthTime,
                      zodiacSign: zodiacSign,
                      responses: onboardingResponses,
                      welcomeHoroscope: welcomeHoroscope,
                      userId: userId)
    }
    
    func markOnboardingComplete(for userId: String? = nil) {
        if let userData = loadUserData(for: userId) {
            userData.markOnboardingComplete()
            do {
                try modelContext.save()
                currentUserData = userData
                print("✅ Onboarding marked as complete")
            } catch {
                print("❌ Error marking onboarding complete: \(error)")
            }
        }
    }
    
    func markConsentAccepted(for userId: String? = nil) {
        if let userData = loadUserData(for: userId) {
            userData.markConsentAccepted()
            do {
                try modelContext.save()
                currentUserData = userData
                print("✅ Consent marked as accepted")
            } catch {
                print("❌ Error marking consent accepted: \(error)")
            }
        }
    }
    
    func addResponse(_ response: OnboardingResponse, for userId: String? = nil) {
        if let userData = loadUserData(for: userId) {
            userData.addResponse(response)
            do {
                try modelContext.save()
                currentUserData = userData
                print("✅ Response added successfully")
            } catch {
                print("❌ Error adding response: \(error)")
            }
        }
    }
    
    func getResponse(for key: String, userId: String? = nil) -> OnboardingResponse? {
        return loadUserData(for: userId)?.getResponse(for: key)
    }
    
    func clearAllUserData() {
        print("🗑️ UserDataManager: Clearing all user data")
        
        let descriptor = FetchDescriptor<UserDataModel>()
        
        do {
            let results = try modelContext.fetch(descriptor)
            print("📊 Found \(results.count) user data records to delete")
            
            for userData in results {
                print("🗑️ Deleting user data with zodiac sign: \(userData.zodiacSign)")
                modelContext.delete(userData)
            }
            try modelContext.save()
            currentUserData = nil
            print("✅ All user data deleted successfully from Core Data")
        } catch {
            print("❌ Error deleting all user data from Core Data: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
} 