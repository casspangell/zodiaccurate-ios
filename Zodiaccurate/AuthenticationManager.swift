import SwiftUI
import FirebaseAuth
import SwiftData

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
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
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
        
        // Check if there's existing onboarding data with a temporary UUID
        if let onboardingUUID = UserDefaults.standard.string(forKey: "onboardingUUID") {
            print("🔄 Found onboarding UUID: \(onboardingUUID), updating existing data...")
            
            // Try to load existing user data with the onboarding UUID
            if let existingUserData = userDataManager.loadUserData(for: onboardingUUID) {
                print("✅ Found existing user data from onboarding, updating userId...")
                
                // Update the userId from onboarding UUID to Firebase UID
                existingUserData.userId = userId
                
                do {
                    try modelContext.save()
                    print("✅ Successfully updated userId from \(onboardingUUID) to \(userId)")
                    
                    // Clear the onboarding UUID since we've migrated to Firebase UID
                    UserDefaults.standard.removeObject(forKey: "onboardingUUID")
                    print("🗑️ Cleared onboarding UUID from UserDefaults")
                    
                    return
                } catch {
                    print("❌ Error updating userId in Core Data: \(error)")
                }
            } else {
                print("⚠️ No existing user data found for onboarding UUID: \(onboardingUUID)")
            }
        }
        
        // Fallback: Create new user data if no onboarding data exists
        print("🔄 Creating new user data with Firebase UID...")
        
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
    
    /// Set trial mode for users who have completed onboarding
    func setTrialMode() {
        isAuthenticated = true
        horoscopeSavedToCoreData = false
        shouldShowOnboardingHoroscope = false
        print("🎫 AuthenticationManager: Trial mode activated, bypassing authentication")
    }
    
    /// Generate welcome horoscope after successful registration
    private func generateWelcomeHoroscope(modelContext: ModelContext) async {
        print("✨ AuthenticationManager: Checking if horoscope generation is needed...")
        
        // Check if we have onboarding data
        guard OnboardingDataAccess.hasCompletedOnboarding else {
            print("⚠️ No onboarding data found, skipping horoscope generation")
            return
        }
        
        // Check if welcome horoscope already exists in Core Data (for any user, not just current user)
        let userDataManager = UserDataManager(modelContext: modelContext)
        let descriptor = FetchDescriptor<UserDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let existingUserData = results.first,
               let existingHoroscope = existingUserData.welcomeHoroscope,
               !existingHoroscope.isEmpty {
                print("✅ Welcome horoscope already exists in Core Data from onboarding, skipping generation")
                
                // Update the existing user data with the current userId if needed
                if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
                    existingUserData.userId = userId
                    try modelContext.save()
                    print("✅ Updated existing user data with userId: \(userId)")
                }
                
                // Post notification to update UI
                DispatchQueue.main.async {
                    print("🔄 Posting horoscopeGenerated notification for existing horoscope...")
                    self.onboardingDataAccess?.loadUserData()
                    NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
                    print("✅ horoscopeGenerated notification posted successfully")
                }
                return
            }
        } catch {
            print("❌ Error checking for existing horoscope: \(error)")
        }
        
        // Only generate horoscope if none exists
        print("🔄 No existing horoscope found, generating new one...")
        
        // Load user data from Core Data for horoscope generation
        if let userId = UserDefaults.standard.string(forKey: "currentUserId") {
            let userDataManager = UserDataManager(modelContext: modelContext)
            if let userDataModel = userDataManager.loadUserData(for: userId) {
                let onboardingAI = Onboarding()
                await onboardingAI.generateWelcomeHoroscope(
                    firstName: userDataModel.firstName,
                    birthDate: userDataModel.birthDate,
                    birthTime: userDataModel.birthTime,
                    zodiacSign: userDataModel.zodiacSign,
                    responses: userDataModel.responseTuples
                )
                
                if let horoscope = onboardingAI.generatedHoroscope {
                    // Save to Core Data
                    print("🔄 Attempting to save horoscope to Core Data for userId: \(userId)")
                    userDataModel.welcomeHoroscope = horoscope
                    do {
                        try modelContext.save()
                        print("✅ Welcome horoscope saved to Core Data for user: \(userId)")
                        // Reload user data in OnboardingDataAccess to update UI
                        DispatchQueue.main.async {
                            print("🔄 Posting horoscopeGenerated notification...")
                            self.onboardingDataAccess?.loadUserData()
                            // Post notification to refresh MainView UI
                            NotificationCenter.default.post(name: Notification.Name("horoscopeGenerated"), object: nil)
                            print("✅ horoscopeGenerated notification posted successfully")
                        }
                    } catch {
                        print("❌ Error saving welcome horoscope to Core Data: \(error)")
                    }
                } else if let error = onboardingAI.error {
                    print("❌ Failed to generate horoscope: \(error)")
                }
            } else {
                print("❌ No user data model found for userId: \(userId)")
            }
        } else {
            print("❌ No currentUserId found in UserDefaults")
        }
    }
} 
