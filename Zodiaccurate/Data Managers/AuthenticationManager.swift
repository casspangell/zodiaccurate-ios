import SwiftUI
import FirebaseAuth

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var horoscopeSavedToCoreData = false
    @Published var shouldShowOnboardingHoroscope = false
    
    private let auth = Auth.auth()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let firebaseDatabaseService = FirebaseDatabaseService()
    
    init() {
        // Listen for authentication state changes
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                print("🔄 AuthenticationManager: Auth state changed - isAuthenticated: \(user != nil)")
            }
        }
    }
    
    deinit {
        // Remove the auth state listener when the manager is deallocated
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
            print("🔄 AuthenticationManager: Auth state listener removed")
        }
    }
    
    /// Clear all authentication state and data (called on first launch after installation)
    func clearAllData() {
        print("🗑️ AuthenticationManager: Clearing all authentication data")
        
        // Clear Firebase Auth state
        do {
            try auth.signOut()
            print("✅ Firebase Auth state cleared")
        } catch {
            print("⚠️ Error clearing Firebase Auth state: \(error)")
        }
        
        // Reset all published properties
        user = nil
        isAuthenticated = false
        isLoading = false
        error = nil
        horoscopeSavedToCoreData = false
        shouldShowOnboardingHoroscope = false
        
        // Clear cached data
        clearCachedData()
        
        print("✅ All authentication data cleared")
    }

    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            user = result.user
            // For sign-in, we can set isAuthenticated immediately since no horoscope generation is needed
            isAuthenticated = true
            
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        print("🔄 AuthenticationManager: Starting sign up...")
        isLoading = true
        error = nil
        horoscopeSavedToCoreData = false
        defer {
            isLoading = false
            print("🔄 AuthenticationManager: Loading state reset to false")
        }
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            user = result.user
            print("✅ AuthenticationManager: User created successfully, isAuthenticated = \(isAuthenticated)")
            
            // Get onboarding data from UserDefaults
            let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
            let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
            let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
            let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
            let timezone = UserDefaults.standard.string(forKey: "userTimezone") ?? ""
            
            // Save user data to Firebase /users/{uid}
            do {
                try await firebaseDatabaseService.saveUser(
                    userId: result.user.uid,
                    email: email,
                    name: firstName,
                    timezone: timezone.isEmpty ? nil : timezone
                )
            } catch {
                print("⚠️ Failed to save user to Firebase: \(error)")
                // Continue even if Firebase save fails
            }
            
            // Get all onboarding responses (stored as dictionary with both Q&A pairs)
            var responses: [String: Any] = [:]
            if let storedResponses = UserDefaults.standard.dictionary(forKey: "onboardingResponses") as? [String: String] {
                // Copy all stored responses (includes both questions and answers)
                responses = storedResponses
            } else {
                // Fallback: reconstruct from individual keys if dictionary format not available
                if !firstName.isEmpty {
                    responses["firstName"] = firstName
                    // Try to get question if available
                    if let question = UserDefaults.standard.string(forKey: "question_firstName") {
                        responses["question_firstName"] = question
                    }
                }
                if !birthDate.isEmpty {
                    responses["birthDate"] = birthDate
                    if let question = UserDefaults.standard.string(forKey: "question_birthDate") {
                        responses["question_birthDate"] = question
                    }
                }
                if !birthTime.isEmpty {
                    responses["birthTime"] = birthTime
                    if let question = UserDefaults.standard.string(forKey: "question_birthTime") {
                        responses["question_birthTime"] = question
                    }
                }
                if !zodiacSign.isEmpty {
                    responses["zodiacSign"] = zodiacSign
                }
                
                // Try to get any other questions/responses stored individually
                let possibleKeys = ["intuition", "energy", "final"]
                for key in possibleKeys {
                    if let answer = UserDefaults.standard.string(forKey: key), !answer.isEmpty {
                        responses[key] = answer
                    }
                    if let question = UserDefaults.standard.string(forKey: "question_\(key)") {
                        responses["question_\(key)"] = question
                    }
                }
            }
            
            // Add timezone if available
            if !timezone.isEmpty {
                responses["timezone"] = timezone
            }
            
            // Add consent given flag
            responses["consentGiven"] = true // Assuming consent was given if onboarding completed
            
            // Save all onboarding responses (including Q&A pairs) to Firebase /responses/{uid}
            do {
                try await firebaseDatabaseService.saveOnboardingResponses(
                    userId: result.user.uid,
                    responses: responses
                )
            } catch {
                print("⚠️ Failed to save onboarding responses to Firebase: \(error)")
                // Continue even if Firebase save fails
            }
            
            // Update profile data (SwiftData removed)
            updateProfileData(with: result.user.uid)
            
            // Set flag to show onboarding horoscope view immediately
            shouldShowOnboardingHoroscope = true

            // Mark that horoscope has been saved to Core Data
            horoscopeSavedToCoreData = true
            
        } catch {
            self.error = error.localizedDescription
            print("❌ AuthenticationManager: Sign up error - \(error.localizedDescription)")
            throw error
        }
    }
    
    private func updateProfileData(with userId: String) {
        print("🔄 updateProfileData called for userId: \(userId)")
        
        // No longer storing in UserDefaults
        
        // Check if there's existing onboarding data with a temporary UUID
        if let onboardingUUID = UserDefaults.standard.string(forKey: "onboardingUUID") {
            print("🔄 Found onboarding UUID: \(onboardingUUID), updating existing data...")
            
            // Clear the onboarding UUID since we've migrated to Firebase UID
            UserDefaults.standard.removeObject(forKey: "onboardingUUID")
            print("🗑️ Cleared onboarding UUID from UserDefaults")
        }
        
        // Gather profile data from UserDefaults and ensure it's stored
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
        let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
        let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
        
        print("🔄 Profile data - firstName: \(firstName), zodiacSign: \(zodiacSign)")
        print("✅ Profile data processed")
    }
    
    func signOut() throws {
        do {
            // Clear any cached data
            clearCachedData()
            
            // Clear all local data
            clearAllLocalData()
            
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
    
    private func clearAllLocalData() {
        print("🗑️ AuthenticationManager: Clearing all local data")
        
        // Clear keychain data
        SecureKeychain.clearAllSecrets()
        
        // Clear additional UserDefaults keys
        let additionalKeys = [
            "currentUserId",
            "hasLaunchedBefore"
        ]
        
        for key in additionalKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        print("✅ All local data cleared")
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
    
    /// Complete the sign-up process and navigate to main app
    func completeSignUp() {
        isAuthenticated = true
        horoscopeSavedToCoreData = false
        shouldShowOnboardingHoroscope = false
        print("✅ AuthenticationManager: Sign-up completed, navigating to main app")
    }
    
    /// Set trial mode for users who have completed onboarding
    func setTrialMode() {
        isAuthenticated = true
        horoscopeSavedToCoreData = false
        shouldShowOnboardingHoroscope = false
        print("🎫 AuthenticationManager: Trial mode activated, bypassing authentication")
    }
    
    /// Generate welcome horoscope after successful registration
    private func generateWelcomeHoroscope() async {
        print("✨ AuthenticationManager: Checking if horoscope generation is needed...")
        
        // Check if welcome horoscope already exists
        print("🔄 No existing horoscope found, generating new one...")
        
        // Load user data for horoscope generation
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
        let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
        let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
    }
} 
