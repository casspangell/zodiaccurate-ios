import SwiftUI
import FirebaseAuth
import SwiftData

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
            
            print("✅ AuthenticationManager: Sign in successful for user: \(result.user.uid)")
            
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    /// Sync Firebase data to SwiftData after login
    func syncDataFromFirebase(modelContext: ModelContext) async {
        guard let userId = user?.uid else {
            print("⚠️ AuthenticationManager: No user ID available for sync")
            return
        }
        
        print("🔄 AuthenticationManager: Starting data sync from Firebase for user: \(userId)")
        
        do {
            // Fetch user data from Firebase
            let userData = try await firebaseDatabaseService.getUser(userId: userId)
            
            // Try to fetch onboarding responses from the correct path first (/responses/{uid}/Onboarding)
            var responses: [String: Any]? = nil
            do {
                responses = try await firebaseDatabaseService.getQuestionnaireResponses(userId: userId, questionnaireTitle: "Onboarding")
                print("✅ AuthenticationManager: Found onboarding responses at /responses/\(userId)/Onboarding")
            } catch {
                print("⚠️ AuthenticationManager: No onboarding responses at /responses/\(userId)/Onboarding, trying fallback path...")
                // Fallback to direct responses path (/responses/{uid})
                do {
                    responses = try await firebaseDatabaseService.getResponses(userId: userId)
                    if responses != nil {
                        print("✅ AuthenticationManager: Found responses at fallback path /responses/\(userId)")
                    }
                } catch {
                    print("⚠️ AuthenticationManager: No responses found at fallback path either")
                }
            }
            
            // Sync User model to SwiftData
            await syncUserData(modelContext: modelContext, userData: userData, responses: responses)
            
            // Sync IntakeData to SwiftData
            await syncIntakeData(modelContext: modelContext, userId: userId, responses: responses)
            
            print("✅ AuthenticationManager: Data sync completed successfully")
            
        } catch {
            print("❌ AuthenticationManager: Failed to sync data from Firebase: \(error)")
            // Continue even if sync fails - don't block login
        }
    }
    
    /// Sync User model to SwiftData
    private func syncUserData(modelContext: ModelContext, userData: [String: Any]?, responses: [String: Any]?) async {
        // Get user data from Firebase responses (contains firstName, birthDate, birthTime, zodiacSign, timezone)
        let firstName = responses?["firstName"] as? String ?? userData?["name"] as? String ?? ""
        let birthDate = responses?["birthDate"] as? String ?? ""
        let birthTime = responses?["birthTime"] as? String ?? ""
        let zodiacSign = responses?["zodiacSign"] as? String ?? ""
        let timezone = responses?["timezone"] as? String ?? userData?["timezone"] as? String ?? TimeZone.current.identifier
        
        // Skip sync if no user data available
        guard !firstName.isEmpty && !birthDate.isEmpty && !birthTime.isEmpty else {
            print("⚠️ AuthenticationManager: Insufficient user data for sync (firstName: \(firstName.isEmpty ? "empty" : "present"), birthDate: \(birthDate.isEmpty ? "empty" : "present"), birthTime: \(birthTime.isEmpty ? "empty" : "present"))")
            return
        }
        
        do {
            // Fetch existing user from SwiftData
            let descriptor = FetchDescriptor<User>()
            let existingUsers = try modelContext.fetch(descriptor)
            
            if let existingUser = existingUsers.first {
                // Update existing user
                existingUser.firstName = firstName
                existingUser.birthDate = birthDate
                existingUser.birthTime = birthTime
                existingUser.zodiacSign = zodiacSign
                existingUser.timezone = timezone
                try modelContext.save()
                print("✅ AuthenticationManager: Updated existing User in SwiftData")
            } else {
                // Create new user
                let newUser = User(
                    firstName: firstName,
                    birthDate: birthDate,
                    birthTime: birthTime,
                    zodiacSign: zodiacSign,
                    timezone: timezone
                )
                modelContext.insert(newUser)
                try modelContext.save()
                print("✅ AuthenticationManager: Created new User in SwiftData")
            }
            
            // Also update UserDefaults for backward compatibility
            UserDefaults.standard.set(firstName, forKey: "userFirstName")
            UserDefaults.standard.set(birthDate, forKey: "userBirthDate")
            UserDefaults.standard.set(birthTime, forKey: "userBirthTime")
            UserDefaults.standard.set(zodiacSign, forKey: "userZodiacSign")
            UserDefaults.standard.set(timezone, forKey: "userTimezone")
            
        } catch {
            print("❌ AuthenticationManager: Failed to sync User data: \(error)")
        }
    }
    
    /// Public method to sync user profile data from Firebase (can be called from views)
    func syncUserProfileFromFirebase(modelContext: ModelContext) async {
        guard let userId = user?.uid else {
            print("⚠️ AuthenticationManager: No user ID available for profile sync")
            return
        }
        
        print("🔄 AuthenticationManager: Syncing user profile from Firebase for user: \(userId)")
        
        do {
            // Fetch user data from Firebase
            let userData = try await firebaseDatabaseService.getUser(userId: userId)
            
            // Try to fetch onboarding responses from the correct path first (/responses/{uid}/Onboarding)
            var responses: [String: Any]? = nil
            do {
                responses = try await firebaseDatabaseService.getQuestionnaireResponses(userId: userId, questionnaireTitle: "Onboarding")
                print("✅ AuthenticationManager: Found onboarding responses at /responses/\(userId)/Onboarding")
            } catch {
                print("⚠️ AuthenticationManager: No onboarding responses at /responses/\(userId)/Onboarding, trying fallback path...")
                // Fallback to direct responses path (/responses/{uid})
                do {
                    responses = try await firebaseDatabaseService.getResponses(userId: userId)
                    if responses != nil {
                        print("✅ AuthenticationManager: Found responses at fallback path /responses/\(userId)")
                    }
                } catch {
                    print("⚠️ AuthenticationManager: No responses found at fallback path either")
                }
            }
            
            // Sync User model to SwiftData
            await syncUserData(modelContext: modelContext, userData: userData, responses: responses)
            
            print("✅ AuthenticationManager: User profile sync completed")
            
        } catch {
            print("❌ AuthenticationManager: Failed to sync user profile from Firebase: \(error)")
            // Don't throw - allow fallback to local data
        }
    }
    
    /// Sync IntakeData to SwiftData by organizing onboarding responses by topic
    private func syncIntakeData(modelContext: ModelContext, userId: String, responses: [String: Any]?) async {
        guard let responses = responses else {
            print("⚠️ AuthenticationManager: No responses data available for IntakeData sync")
            return
        }
        
        // Map dataKeys to topics
        let topicMapping: [String: String] = [
            // Wellness topic
            "overallHealth": "wellness",
            "physicalHealthDescription": "wellness",
            "emotionalImbalances": "wellness",
            "mentalHealthChallenges": "wellness",
            "wellnessGoals": "wellness",
            "goalsAndDreams": "wellness",
            "areasToImprove": "wellness",
            "stressSources": "wellness",
            "joyAndSatisfaction": "wellness",
            "familyValues": "wellness",
            "sexualOrientation": "wellness",
            "beliefSystem": "wellness",
            
            // Relationship topic
            "relationshipStatus": "relationship",
            "relationshipGoals": "relationship",
            "communicationStyle": "relationship",
            "loveLanguage": "relationship",
            "relationshipChallenges": "relationship",
            "pastRelationshipLessons": "relationship",
            "importantPartnerQualities": "relationship",
            "relationshipValues": "relationship",
            "intimacyPreferences": "relationship",
            "futureRelationshipVision": "relationship",
            
            // ImportantPeople topic
            "familyRelationships": "importantPeople",
            "closestFriends": "importantPeople",
            "supportSystem": "importantPeople",
            "mentorsAndRoleModels": "importantPeople",
            "socialCircle": "importantPeople",
            "peopleWhoInspire": "importantPeople",
            "relationshipDynamics": "importantPeople",
            "peopleToConnectWith": "importantPeople",
            "impactOnOthers": "importantPeople",
            "futureRelationships": "importantPeople",
            
            // Children topic
            "childrenStatus": "children",
            "parentingExperience": "children",
            "parentingStyle": "children",
            "parentingChallenges": "children",
            "parentingGoals": "children",
            "familyDynamics": "children",
            "valuesToPassOn": "children",
            "parentingSupport": "children",
            "futureFamilyVision": "children",
            
            // Employment topic
            "employmentStatus": "employment",
            "jobSatisfaction": "employment",
            "careerField": "employment",
            "workEnvironment": "employment",
            "careerGoals": "employment",
            "workLifeBalance": "employment",
            "professionalChallenges": "employment",
            "professionalStrengths": "employment",
            "professionalDevelopment": "employment",
            "futureCareerVision": "employment"
        ]
        
        do {
            // Get or create IntakeData for the user
            let intakeDataManager = IntakeDataManager(modelContext: modelContext)
            let intakeData = intakeDataManager.getOrCreateIntakeData(for: userId)
            
            // Organize responses by topic
            var wellnessData: [String: String] = [:]
            var relationshipData: [String: String] = [:]
            var importantPeopleData: [String: String] = [:]
            var childrenData: [String: String] = [:]
            var employmentData: [String: String] = [:]
            
            // Process each response and assign to appropriate topic
            for (key, value) in responses {
                // Skip question keys and basic user info keys
                if key.hasPrefix("question_") {
                    continue
                }
                
                // Skip basic user info that's handled in User model
                if ["firstName", "birthDate", "birthTime", "zodiacSign", "timezone", "consentGiven", "intuition", "energy", "final"].contains(key) {
                    continue
                }
                
                // Get topic for this dataKey
                if let topic = topicMapping[key], let answer = value as? String, !answer.isEmpty {
                    switch topic {
                    case "wellness":
                        wellnessData[key] = answer
                    case "relationship":
                        relationshipData[key] = answer
                    case "importantPeople":
                        importantPeopleData[key] = answer
                    case "children":
                        childrenData[key] = answer
                    case "employment":
                        employmentData[key] = answer
                    default:
                        break
                    }
                }
            }
            
            // Update IntakeData with topic data
            if !wellnessData.isEmpty {
                intakeData.setData(wellnessData, for: "wellness")
            }
            if !relationshipData.isEmpty {
                intakeData.setData(relationshipData, for: "relationship")
            }
            if !importantPeopleData.isEmpty {
                intakeData.setData(importantPeopleData, for: "importantPeople")
            }
            if !childrenData.isEmpty {
                intakeData.setData(childrenData, for: "children")
            }
            if !employmentData.isEmpty {
                intakeData.setData(employmentData, for: "employment")
            }
            
            // Save to SwiftData
            try modelContext.save()
            
            let totalAnswers = wellnessData.count + relationshipData.count + importantPeopleData.count + childrenData.count + employmentData.count
            print("✅ AuthenticationManager: Synced IntakeData - Total answers: \(totalAnswers) (Wellness: \(wellnessData.count), Relationship: \(relationshipData.count), ImportantPeople: \(importantPeopleData.count), Children: \(childrenData.count), Employment: \(employmentData.count))")
            
        } catch {
            print("❌ AuthenticationManager: Failed to sync IntakeData: \(error)")
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
            
            // Save all onboarding responses (including Q&A pairs) to Firebase /responses/{uid}/Onboarding
            do {
                try await firebaseDatabaseService.saveQuestionnaireResponses(
                    userId: result.user.uid,
                    questionnaireTitle: "Onboarding",
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
