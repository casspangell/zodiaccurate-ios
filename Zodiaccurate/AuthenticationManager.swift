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
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            user = result.user
            isAuthenticated = true
            
            // Create user document in Firestore
            try await createUserProfile(userId: result.user.uid, email: email)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            user = nil
            isAuthenticated = false
        } catch {
            self.error = error.localizedDescription
            throw error
        }
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
} 