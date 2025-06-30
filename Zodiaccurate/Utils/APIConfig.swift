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
    
    /// Get OpenAI API key from Config.plist
    static var openAIAPIKey: String {
        return ConfigManager.shared.openAIAPIKey
    }
    
    /// Get Firebase URL from Config.plist
    static var firebaseURL: String {
        return ConfigManager.shared.firebaseURL
    }
    
    /// Get Firebase Password from Config.plist
    static var firebasePassword: String {
        return ConfigManager.shared.firebasePassword
    }
    
    /// Get Firebase API Key from Config.plist
    static var firebaseAPIKey: String {
        return ConfigManager.shared.firebaseAPIKey
    }
    
    /// Get Stripe API Key from Config.plist
    static var stripeAPIKey: String {
        return ConfigManager.shared.stripeAPIKey
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
        return ConfigManager.shared.isOpenAIConfigured
    }
    
    /// Check if Firebase is properly configured
    static var isFirebaseConfigured: Bool {
        return ConfigManager.shared.isFirebaseConfigured
    }
    
    /// Check if Stripe is properly configured
    static var isStripeConfigured: Bool {
        return ConfigManager.shared.isStripeConfigured
    }
    
    /// Check if all secrets are properly configured
    static var areAllSecretsConfigured: Bool {
        return ConfigManager.shared.areAllSecretsConfigured
    }
    
    // MARK: - Error Messages
    
    static let apiKeyNotConfiguredMessage = """
    Please configure your OpenAI API key:
    
    Option 1 (Recommended): Use Config.plist
    1. Copy Config.template.plist to Config.plist
    2. Add your OpenAI API key to Config.plist
    3. Restart the app
    
    Option 2 (Development): Configure locally
    1. Replace "YOUR_OPENAI_API_KEY_HERE" in Config.plist
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
     
     1. NEVER commit Config.plist to version control (already gitignored)
     2. Store API keys securely using iOS Keychain
     3. Consider using a backend service to proxy API calls
     4. Implement rate limiting and usage monitoring
     5. Add proper error handling and user feedback
     
     The app now uses Config.plist for configuration management.
     See CONFIG_SETUP.md for detailed setup instructions.
     */
} 