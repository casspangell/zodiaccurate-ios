//
//  APIConfig.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation

// MARK: - API Configuration

struct APIConfig {
    // MARK: - OpenAI Configuration
    
    // MARK: - API Keys from GitHub Secrets
    
    /// Get OpenAI API key from the most secure available source
    /// Priority: GitHub Actions → Keychain → Local config
    static var openAIAPIKey: String {
        // 1. Build environment (GitHub Actions)
        if let buildKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return buildKey
        }
        
        // 2. Keychain (if previously stored)
        if let keychainKey = SecureKeychain.getAPIKey(for: "OpenAI_API_Key") {
            return keychainKey
        }
        
        // 3. Fallback for development
        // TODO: Replace with your actual OpenAI API key for development
        return "sk-proj-your-actual-openai-api-key-here"
    }
    
    /// Get Firebase URL from GitHub Secrets
    static var firebaseURL: String {
        if let buildKey = ProcessInfo.processInfo.environment["FIREBASE_URL"] {
            return buildKey
        }
        
        if let keychainKey = SecureKeychain.getAPIKey(for: "FIREBASE_URL") {
            return keychainKey
        }
        
        return "YOUR_FIREBASE_URL_HERE"
    }
    
    /// Get Firebase Password from GitHub Secrets
    static var firebasePassword: String {
        if let buildKey = ProcessInfo.processInfo.environment["FIREBASE_PASSWORD"] {
            return buildKey
        }
        
        if let keychainKey = SecureKeychain.getAPIKey(for: "FIREBASE_PASSWORD") {
            return keychainKey
        }
        
        return "YOUR_FIREBASE_PASSWORD_HERE"
    }
    
    /// Get Firebase API Key from GitHub Secrets
    static var firebaseAPIKey: String {
        if let buildKey = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] {
            return buildKey
        }
        
        if let keychainKey = SecureKeychain.getAPIKey(for: "FIREBASE_API_KEY") {
            return keychainKey
        }
        
        return "YOUR_FIREBASE_API_KEY_HERE"
    }
    
    /// OpenAI API base URL
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    
    /// Default model to use for horoscope generation
    static let defaultModel = "gpt-4"
    
    /// Temperature setting for creative responses (0.0 = focused, 1.0 = creative)
    static let defaultTemperature: Double = 0.8
    
    /// Maximum tokens for horoscope generation
    static let maxTokens = 500
    
    // MARK: - Validation
    
    /// Check if the API key is properly configured
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.contains("YOUR_OPENAI_API_KEY_HERE") && !openAIAPIKey.isEmpty
    }
    
    /// Check if Firebase is properly configured
    static var isFirebaseConfigured: Bool {
        return !firebaseURL.contains("YOUR_FIREBASE_URL_HERE") && 
               !firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE") &&
               !firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE")
    }
    
    /// Check if all secrets are properly configured
    static var areAllSecretsConfigured: Bool {
        return isAPIKeyConfigured && isFirebaseConfigured
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
    
    // MARK: - Development Helper
    
    /// Configure API key for development (call this once)
    static func configureForDevelopment(openAIKey: String) {
        SecureKeychain.saveAPIKey(openAIKey, for: "OpenAI_API_Key")
        print("✅ OpenAI API key saved to keychain for development")
    }
    
    // MARK: - Production Security Notes
    
    /*
     IMPORTANT SECURITY NOTES FOR PRODUCTION:
     
     1. NEVER commit API keys to version control
     2. Store API keys securely using iOS Keychain
     3. Consider using a backend service to proxy API calls
     4. Implement rate limiting and usage monitoring
     5. Add proper error handling and user feedback
     
     Example Keychain implementation:
     
     import Security
     
     class SecureKeychain {
         static func saveAPIKey(_ key: String) {
             let query: [String: Any] = [
                 kSecClass as String: kSecClassGenericPassword,
                 kSecAttrAccount as String: "OpenAI_API_Key",
                 kSecValueData as String: key.data(using: .utf8)!
             ]
             SecItemAdd(query as CFDictionary, nil)
         }
         
         static func getAPIKey() -> String? {
             let query: [String: Any] = [
                 kSecClass as String: kSecClassGenericPassword,
                 kSecAttrAccount as String: "OpenAI_API_Key",
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
     }
     */
} 