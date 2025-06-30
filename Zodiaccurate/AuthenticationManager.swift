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
            
            // Generate a unique profile UUID
            let profileUUID = UUID().uuidString
            print("🆔 Generated profile UUID: \(profileUUID)")
            
            // Store the email for future auto-population
            OnboardingDataAccess.storeLastLoggedInEmail(email)
            print("💾 Stored last logged-in email: \(email)")
            
            // Store the profile UUID
            OnboardingDataAccess.storeProfileUUID(profileUUID)
            print("💾 Stored profile UUID: \(profileUUID)")
            
            // Create user document in Firestore
            try await createUserProfile(userId: result.user.uid, email: email, profileUUID: profileUUID)
            print("✅ AuthenticationManager: User profile created in Firestore")
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
    
    private func createUserProfile(userId: String, email: String, profileUUID: String) async throws {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp(),
            "profileUUID": profileUUID
        ]
        
        try await db.collection("users").document(userId).setData(userData)
    }
} 