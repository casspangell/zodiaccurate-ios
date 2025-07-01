import SwiftUI
import FirebaseAuth
import SwiftData

// MARK: - Notification Names
extension Notification.Name {
    static let horoscopeGenerated = Notification.Name("horoscopeGenerated")
}

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var horoscopeSavedToCoreData = false
    @Published var shouldShowOnboardingHoroscope = false
    
    private let auth = Auth.auth()
    private var onboardingDataAccess: OnboardingDataAccess?
    
    init() {
        // Listen for authentication state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                print("🔄 AuthenticationManager: Auth state changed - isAuthenticated: \(user != nil)")
            }
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
    
    func setOnboardingDataAccess(_ dataAccess: OnboardingDataAccess) {
        self.onboardingDataAccess = dataAccess
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
            
            // Store the email for future auto-population
            OnboardingDataAccess.storeLastLoggedInEmail(email)
            print("💾 Stored last logged-in email: \(email)")
            
            // Store current user ID for tracking
            UserDefaults.standard.set(result.user.uid, forKey: "currentUserId")
            
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signUp(email: String, password: String, modelContext: ModelContext) async throws {
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
            
            // Generate profile UUID
            let profileUUID = UUID().uuidString
            
            // Store the email for future auto-population
            OnboardingDataAccess.storeLastLoggedInEmail(email)
            print("💾 Stored last logged-in email: \(email)")
            
            // Store the profile UUID
            OnboardingDataAccess.storeProfileUUID(profileUUID)
            print("💾 Stored profile UUID: \(profileUUID)")
            
            // Store current user ID for tracking
            UserDefaults.standard.set(result.user.uid, forKey: "currentUserId")
            
            // Update Core Data with userId and profile
            updateCoreDataProfile(with: result.user.uid, modelContext: modelContext)
            
            // Set flag to show onboarding horoscope view immediately
            shouldShowOnboardingHoroscope = true
            
            // Set loading state for horoscope
            onboardingDataAccess?.setHoroscopeGenerationState(isGenerating: true)
            
            // Generate welcome horoscope after successful registration
            await generateWelcomeHoroscope(modelContext: modelContext)
            onboardingDataAccess?.setHoroscopeGenerationState(isGenerating: false, didGenerate: true)
            
            // Mark that horoscope has been saved to Core Data
            horoscopeSavedToCoreData = true
            
        } catch {
            self.error = error.localizedDescription
            print("❌ AuthenticationManager: Sign up error - \(error.localizedDescription)")
            throw error
        }
    }
    
    private func updateCoreDataProfile(with userId: String, modelContext: ModelContext) {
        print("🔄 updateCoreDataProfile called for userId: \(userId)")
        print("✅ Using provided model context for profile update")
        let userDataManager = UserDataManager(modelContext: modelContext)
        // Gather profile data from UserDefaults
        let firstName = UserDefaults.standard.string(forKey: "userFirstName") ?? ""
        let birthDate = UserDefaults.standard.string(forKey: "userBirthDate") ?? ""
        let birthTime = UserDefaults.standard.string(forKey: "userBirthTime") ?? ""
        let zodiacSign = UserDefaults.standard.string(forKey: "userZodiacSign") ?? ""
        print("🔄 Profile data - firstName: \(firstName), zodiacSign: \(zodiacSign)")
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
        let userData = UserData(
            firstName: firstName,
            birthDate: birthDate,
            birthTime: birthTime,
            zodiacSign: zodiacSign,
            responses: responses
        )
        print("🔄 Saving user data to Core Data...")
        userDataManager.saveUserData(userData, userId: userId)
        print("✅ User data saved to Core Data")
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
        
        // Clear OnboardingDataAccess data
        OnboardingDataAccess.clearAllData()
        
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
    
    /// Generate welcome horoscope after successful registration
    private func generateWelcomeHoroscope(modelContext: ModelContext) async {
        print("✨ Generating welcome horoscope after registration...")
        
        // Check if we have onboarding data
        guard OnboardingDataAccess.hasCompletedOnboarding else {
            print("⚠️ No onboarding data found, skipping horoscope generation")
            return
        }
        
        // Check if welcome horoscope already exists in Core Data
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            let userDataManager = UserDataManager(modelContext: modelContext)
            if let userDataModel = userDataManager.loadUserData(for: userId),
               let existingHoroscope = userDataModel.welcomeHoroscope,
               !existingHoroscope.isEmpty {
                print("✅ Welcome horoscope already exists in Core Data, skipping generation")
                return
            }
        }
        
        let onboardingAI = OnboardingAI()
        await onboardingAI.generateWelcomeHoroscope()
        
        if let horoscope = onboardingAI.generatedHoroscope {
            // Save to Core Data only (not UserDefaults)
            if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
                print("🔄 Attempting to save horoscope to Core Data for userId: \(userId)")
                print("✅ Using provided model context, loading user data...")
                let userDataManager = UserDataManager(modelContext: modelContext)
                if let userDataModel = userDataManager.loadUserData(for: userId) {
                    print("✅ Found user data model, updating horoscope...")
                    userDataModel.welcomeHoroscope = horoscope
                    do {
                        try modelContext.save()
                        print("✅ Welcome horoscope saved to Core Data for user: \(userId)")
                        // Reload user data in OnboardingDataAccess to update UI
                        DispatchQueue.main.async {
                            print("🔄 Posting horoscopeGenerated notification...")
                            self.onboardingDataAccess?.loadUserData()
                            // Post notification to refresh MainView UI
                            NotificationCenter.default.post(name: .horoscopeGenerated, object: nil)
                            print("✅ horoscopeGenerated notification posted successfully")
                        }
                    } catch {
                        print("❌ Error saving welcome horoscope to Core Data: \(error)")
                    }
                } else {
                    print("❌ No user data model found for userId: \(userId)")
                }
            } else {
                print("❌ No currentUserId found in UserDefaults")
            }
        } else if let error = onboardingAI.error {
            print("❌ Failed to generate welcome horoscope: \(error)")
        }
    }
} 
