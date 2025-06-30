import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let auth = Auth.auth()
    private let firebaseDatabaseService = FirebaseDatabaseService()
    
    init() {
        // Listen for auth state changes
        _ = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
            
            // Store the email for future auto-population
            OnboardingDataAccess.storeLastLoggedInEmail(email)
            print("💾 Stored last logged-in email: \(email)")
            
            // Store current user ID for tracking
            UserDefaults.standard.set(result.user.uid, forKey: "currentUserId")
            
            // Update trial user last login
            try await firebaseDatabaseService.updateTrialUserLastLogin(userId: result.user.uid)
            
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        print("🔄 AuthenticationManager: Starting sign up...")
        isLoading = true
        error = nil
        defer { 
            isLoading = false
            print("🔄 AuthenticationManager: Loading state reset to false")
        }
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
            print("✅ AuthenticationManager: User created successfully, isAuthenticated = \(isAuthenticated)")
            
            // Store the email for future auto-population
            OnboardingDataAccess.storeLastLoggedInEmail(email)
            print("💾 Stored last logged-in email: \(email)")
            
            // Store the profile UUID
            OnboardingDataAccess.storeProfileUUID(profileUUID)
            print("💾 Stored profile UUID: \(profileUUID)")
            
            // Store current user ID for tracking
            UserDefaults.standard.set(result.user.uid, forKey: "currentUserId")
            
            // Save to trial_users table in Firebase Realtime Database
            try await firebaseDatabaseService.saveTrialUser(
                email: email,
                userId: result.user.uid,
                profileUUID: profileUUID
            )
            print("✅ AuthenticationManager: Trial user saved to Firebase Realtime Database")
            
            // Create user document in Firestore (keeping for backward compatibility)
            try await createUserProfile(userId: result.user.uid, email: email, profileUUID: profileUUID)

            print("✅ AuthenticationManager: User profile created in Firestore")
            
            // Save onboarding data to Firebase if pending
            await savePendingOnboardingData(userId: result.user.uid, profileUUID: profileUUID)
        } catch {
            self.error = error.localizedDescription
            print("❌ AuthenticationManager: Sign up error - \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            // Clear any cached data
            clearCachedData()
            
            // Sign out from Firebase
            try auth.signOut()
            
            // Reset authentication state
            user = nil
            isAuthenticated = false
            error = nil
            
            print("✅ AuthenticationManager: Sign out successful")
        } catch {
            self.error = error.localizedDescription
            print("❌ AuthenticationManager: Sign out error - \(error.localizedDescription)")
            throw error
        }
    }
    
    private func clearCachedData() {
        // Clear any cached user data or tokens
        // This can be expanded as needed
        print("🗑️ AuthenticationManager: Clearing cached data")
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    private func createUserProfile(userId: String, email: String) async throws {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(userId).setData(userData)
    }
    
    /// Save pending onboarding data to Firebase after authentication
    private func savePendingOnboardingData(userId: String, profileUUID: String) async {
        // Check if there's pending onboarding data to save
        let hasPendingSave = UserDefaults.standard.bool(forKey: "pendingOnboardingFirebaseSave")
        
        if hasPendingSave {
            print("📝 Saving pending onboarding data to Firebase...")
            
            do {
                // Get onboarding data from UserDefaults
                let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
                let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
                let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
                let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
                
                // Get responses
                var responses: [(String, String, String)] = []
                if let responsesData = UserDefaults.standard.data(forKey: "userResponses"),
                   let responsesArray = try? JSONSerialization.jsonObject(with: responsesData) as? [[String: String]] {
                    for response in responsesArray {
                        if let question = response["question"],
                           let key = response["key"],
                           let answer = response["answer"] {
                            responses.append((question, key, answer))
                        }
                    }
                }
                
                // Create UserData object for Firebase
                let userData = UserData(
                    firstName: firstName,
                    birthDate: birthDate,
                    birthTime: birthTime,
                    zodiacSign: zodiacSign,
                    responses: responses
                )
                
                // Save to Firebase
                try await firebaseDatabaseService.saveOnboardingData(
                    userId: userId,
                    profileUUID: profileUUID,
                    userData: userData
                )
                
                // Clear the pending flag
                UserDefaults.standard.removeObject(forKey: "pendingOnboardingFirebaseSave")
                
                print("✅ Pending onboarding data saved to Firebase successfully")
                
            } catch {
                print("❌ Error saving pending onboarding data to Firebase: \(error.localizedDescription)")
            }
        } else {
            print("📝 No pending onboarding data to save")
        }
    }
} 
