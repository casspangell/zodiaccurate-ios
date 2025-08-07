//
//  APIConfig.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import SwiftUI

// MARK: - Configuration Status

enum ConfigStatus {
    case unknown
    case allConfigured
    case partiallyConfigured
    case notConfigured
    
    var description: String {
        switch self {
        case .unknown:
            return "Checking configuration..."
        case .allConfigured:
            return "✅ All secrets configured"
        case .partiallyConfigured:
            return "⚠️ Some secrets missing"
        case .notConfigured:
            return "❌ No secrets configured"
        }
    }
    
    var color: Color {
        switch self {
        case .unknown:
            return .gray
        case .allConfigured:
            return .green
        case .partiallyConfigured:
            return .orange
        case .notConfigured:
            return .red
        }
    }
}

// MARK: - API Configuration

struct APIConfig {
    
    // MARK: - Configuration Manager
    
    private static let configManager = ConfigManager.shared
    
    // MARK: - OpenAI Configuration
    
    /// Get OpenAI API key from Config.plist
    static var openAIAPIKey: String {
        return configManager.openAIAPIKey
    }
    
    /// OpenAI API base URL
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    
    /// Default model to use for horoscope generation
    static let defaultModel = "gpt-4"
    
    /// Temperature setting for creative responses (0.0 = focused, 1.0 = creative)
    static let defaultTemperature: Double = 0.8
    
    /// Maximum tokens for horoscope generation
    static let maxTokens = 500
    
    // MARK: - Firebase Configuration
    
    /// Get Firebase URL from Config.plist
    static var firebaseURL: String {
        return configManager.firebaseURL
    }
    
    /// Get Firebase API Key from Config.plist
    static var firebaseAPIKey: String {
        return configManager.firebaseAPIKey
    }
    
    /// Get Firebase Password from Config.plist
    static var firebasePassword: String {
        return configManager.firebasePassword
    }
    
    // MARK: - Stripe Configuration
    
    /// Get Stripe API Key from Config.plist
    static var stripeAPIKey: String {
        return configManager.stripeAPIKey
    }
    
    // MARK: - Validation
    
    /// Check if the API key is properly configured
    static var isAPIKeyConfigured: Bool {
        return configManager.isOpenAIConfigured
    }
    
    /// Check if Firebase is properly configured
    static var isFirebaseConfigured: Bool {
        return configManager.isFirebaseConfigured
    }
    
    /// Check if Stripe is properly configured
    static var isStripeConfigured: Bool {
        return configManager.isStripeConfigured
    }
    
    /// Check if all secrets are properly configured
    static var areAllSecretsConfigured: Bool {
        return configManager.areAllSecretsConfigured
    }
    
    // MARK: - Status Management
    
    /// Get the current configuration status
    static var configStatus: ConfigStatus {
        return configManager.configStatus
    }
    
    /// Check if configuration is being validated
    static var isCheckingConfig: Bool {
        return configManager.isCheckingConfig
    }
    
    /// Get any error message from configuration loading
    static var errorMessage: String? {
        return configManager.errorMessage
    }
    
    /// Check the status of all configuration
    static func checkConfigStatus() {
        configManager.checkConfigStatus()
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
}

// MARK: - Configuration Manager (Internal)

private class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var isCheckingConfig = false
    @Published var configStatus: ConfigStatus = .unknown
    @Published var errorMessage: String?
    
    private var configDict: [String: Any]?
    
    private init() {
        loadConfig()
        checkConfigStatus()
    }
    
    // MARK: - Configuration Loading
    
    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("❌ ConfigManager: Could not load Config.plist")
            Task { @MainActor in
                self.errorMessage = "Could not load Config.plist"
            }
            return
        }
        
        configDict = dict
        print("✅ ConfigManager: Config.plist loaded successfully")
    }
    
    // MARK: - Public Methods
    
    /// Check the status of all configuration
    func checkConfigStatus() {
        isCheckingConfig = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task { @MainActor in
                self.updateConfigStatus()
                self.isCheckingConfig = false
            }
        }
    }
    
    // MARK: - Configuration Properties
    
    var openAIAPIKey: String {
        return getStringValue(for: "OpenAI.APIKey") ?? ""
    }
    
    var firebaseURL: String {
        return getStringValue(for: "Firebase.URL") ?? ""
    }
    
    var firebaseAPIKey: String {
        return getStringValue(for: "Firebase.APIKey") ?? ""
    }
    
    var firebasePassword: String {
        return getStringValue(for: "Firebase.Password") ?? ""
    }
    
    var stripeAPIKey: String {
        return getStringValue(for: "Stripe.APIKey") ?? ""
    }
    
    // MARK: - Validation
    
    var isOpenAIConfigured: Bool {
        return !openAIAPIKey.contains("YOUR_OPENAI_API_KEY_HERE") && !openAIAPIKey.isEmpty
    }
    
    var isFirebaseConfigured: Bool {
        return !firebaseURL.contains("YOUR_FIREBASE_URL_HERE") &&
               !firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE") &&
               !firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE")
    }
    
    var isStripeConfigured: Bool {
        return !stripeAPIKey.contains("YOUR_STRIPE_API_KEY_HERE") && !stripeAPIKey.isEmpty
    }
    
    var areAllSecretsConfigured: Bool {
        return isOpenAIConfigured && isFirebaseConfigured && isStripeConfigured
    }
    
    // MARK: - Helper Methods
    
    private func getStringValue(for key: String) -> String? {
        let keys = key.components(separatedBy: ".")
        var current: Any? = configDict
        
        for k in keys {
            if let dict = current as? [String: Any] {
                current = dict[k]
            } else {
                return nil
            }
        }
        
        return current as? String
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func updateConfigStatus() {
        if areAllSecretsConfigured {
            configStatus = .allConfigured
        } else if isOpenAIConfigured || isFirebaseConfigured || isStripeConfigured {
            configStatus = .partiallyConfigured
        } else {
            configStatus = .notConfigured
        }
    }
} 
