//
//  GitHubSecretManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation

// MARK: - GitHub Secret Manager

@MainActor
class GitHubSecretManager: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    // GitHub API configuration
    private let baseURL = "https://api.github.com"
    private let repository = "your-username/zodiaccurate-ios" // Replace with your actual repo
    private let secretName = "OPENAI_API_KEY"
    
    // For public repos, you can use a GitHub Personal Access Token
    // For private repos, you'll need to implement OAuth or use a different approach
    private let accessToken: String? = nil // Optional: Add your GitHub token if needed
    
    /// Fetch API key from GitHub Secrets
    /// Note: This is a simplified approach. For production, consider:
    /// 1. Using a backend service to proxy the request
    /// 2. Implementing proper OAuth flow
    /// 3. Using GitHub Actions to inject secrets during build
    func fetchAPIKey() async -> String? {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            // For this example, we'll use a different approach since GitHub Secrets
            // are primarily for GitHub Actions, not direct API access
            
            // Option 1: Use GitHub Actions to inject the secret during build
            // This is the most secure approach
            if let apiKey = getAPIKeyFromBuildEnvironment() {
                return apiKey
            }
            
            // Option 2: Use a GitHub Gist or public file (less secure, but simpler)
            if let apiKey = await fetchAPIKeyFromGist() {
                return apiKey
            }
            
            // Option 3: Fallback to local configuration
            error = "Unable to fetch API key. Please configure it locally."
            return nil
            
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    /// Get API key from build environment (set by GitHub Actions)
    private func getAPIKeyFromBuildEnvironment() -> String? {
        // This would be set by GitHub Actions during build
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
    
    /// Fetch API key from a private GitHub Gist (alternative approach)
    private func fetchAPIKeyFromGist() async -> String? {
        // This is a less secure approach but easier to implement
        // You would store your API key in a private GitHub Gist
        guard let accessToken = accessToken else {
            return nil
        }
        
        let gistId = "your-gist-id" // Replace with your actual gist ID
        let urlString = "\(baseURL)/gists/\(gistId)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Parse the gist response to extract the API key
            // This depends on how you structure your gist
            let gistData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            // Extract API key from gist files...
            
            return nil // Implement based on your gist structure
            
        } catch {
            return nil
        }
    }
}

// MARK: - Alternative: GitHub Actions Integration

/*
 For the most secure approach, use GitHub Actions to inject secrets during build:

 1. Create .github/workflows/build.yml:
 
 name: Build iOS App
 on:
   push:
     branches: [ main ]
   pull_request:
     branches: [ main ]

 jobs:
   build:
     runs-on: macos-latest
     steps:
     - uses: actions/checkout@v2
     
     - name: Set up Xcode
       uses: maxim-lobanov/setup-xcode@v1
       with:
         xcode-version: '15.0'
     
     - name: Build with secrets
       env:
         OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
       run: |
         # Your build commands here
         # The secret will be available as an environment variable
 */

// MARK: - Updated APIConfig with GitHub Integration

struct APIConfig {
    // MARK: - API Key Management
    
    /// Get API key from the most secure available source
    static var openAIAPIKey: String {
        // Priority order:
        // 1. Build environment (GitHub Actions)
        // 2. Keychain (if previously stored)
        // 3. Local configuration (development)
        
        if let buildKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return buildKey
        }
        
        if let keychainKey = SecureKeychain.getAPIKey() {
            return keychainKey
        }
        
        // Fallback for development
        return "YOUR_OPENAI_API_KEY_HERE"
    }
    
    // MARK: - Configuration
    
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    static let defaultModel = "gpt-4"
    static let defaultTemperature: Double = 0.8
    static let maxTokens = 500
    
    // MARK: - Validation
    
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.contains("YOUR_OPENAI_API_KEY_HERE") && !openAIAPIKey.isEmpty
    }
    
    // MARK: - Error Messages
    
    static let apiKeyNotConfiguredMessage = """
    Please configure your OpenAI API key:
    
    Option 1 (Recommended): Set up GitHub Secrets
    1. Go to your GitHub repo → Settings → Secrets and variables → Actions
    2. Add repository secret: OPENAI_API_KEY
    3. Push to trigger GitHub Actions build
    
    Option 2 (Development): Configure locally
    1. Replace "YOUR_OPENAI_API_KEY_HERE" in APIConfig.swift
    2. Restart the app
    
    Get your API key from: https://platform.openai.com/api-keys
    """
}

// MARK: - Secure Keychain (Backup Storage)

import Security

class SecureKeychain {
    /// Save any secret to the keychain
    static func saveAPIKey(_ key: String, for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        // Delete any existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("❌ Failed to save \(account) to keychain: \(status)")
        } else {
            print("✅ Successfully saved \(account) to keychain")
        }
    }
    
    /// Get any secret from the keychain
    static func getAPIKey(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let key = String(data: data, encoding: .utf8) {
            return key
        }
        
        return nil
    }
    
    /// Delete any secret from the keychain
    static func deleteAPIKey(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Save all secrets to keychain (for development/testing)
    static func saveAllSecrets() {
        // Save OpenAI API key
        if !APIConfig.openAIAPIKey.contains("YOUR_OPENAI_API_KEY_HERE") {
            saveAPIKey(APIConfig.openAIAPIKey, for: "OpenAI_API_Key")
        }
        
        // Save Firebase secrets
        if !APIConfig.firebaseURL.contains("YOUR_FIREBASE_URL_HERE") {
            saveAPIKey(APIConfig.firebaseURL, for: "FIREBASE_URL")
        }
        
        if !APIConfig.firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE") {
            saveAPIKey(APIConfig.firebaseAPIKey, for: "FIREBASE_API_KEY")
        }
        
        if !APIConfig.firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE") {
            saveAPIKey(APIConfig.firebasePassword, for: "FIREBASE_PASSWORD")
        }
    }
    
    /// Clear all secrets from keychain
    static func clearAllSecrets() {
        deleteAPIKey(for: "OpenAI_API_Key")
        deleteAPIKey(for: "FIREBASE_URL")
        deleteAPIKey(for: "FIREBASE_API_KEY")
        deleteAPIKey(for: "FIREBASE_PASSWORD")
        print("🗑️ All secrets cleared from keychain")
    }
    
    /// Check if all secrets are available in keychain
    static func areAllSecretsInKeychain() -> Bool {
        return getAPIKey(for: "OpenAI_API_Key") != nil &&
               getAPIKey(for: "FIREBASE_URL") != nil &&
               getAPIKey(for: "FIREBASE_API_KEY") != nil &&
               getAPIKey(for: "FIREBASE_PASSWORD") != nil
    }
} 