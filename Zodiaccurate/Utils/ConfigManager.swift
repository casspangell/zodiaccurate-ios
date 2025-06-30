//
//  ConfigManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import SwiftUI

// MARK: - Configuration Manager

class ConfigManager: ObservableObject {
    static let shared = ConfigManager()
    
    @Published var isCheckingConfig = false
    @Published var configStatus: ConfigStatus = .unknown
    @Published var errorMessage: String?
    
    private var configDict: [String: Any]?
    
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
    
    /// Save all available secrets to keychain
    func saveSecretsToKeychain() {
        SecureKeychain.saveAllSecrets()
        Task { @MainActor in
            checkConfigStatus()
        }
    }
    
    /// Clear all secrets from keychain
    func clearSecretsFromKeychain() {
        SecureKeychain.clearAllSecrets()
        Task { @MainActor in
            checkConfigStatus()
        }
    }
    
    // MARK: - OpenAI Configuration
    
    var openAIAPIKey: String {
        return getStringValue(for: "OpenAI.APIKey") ?? "YOUR_OPENAI_API_KEY_HERE"
    }
    
    var openAIBaseURL: String {
        return getStringValue(for: "OpenAI.BaseURL") ?? "https://api.openai.com/v1/chat/completions"
    }
    
    var openAIDefaultModel: String {
        return getStringValue(for: "OpenAI.DefaultModel") ?? "gpt-4"
    }
    
    var openAIDefaultTemperature: Double {
        return getDoubleValue(for: "OpenAI.DefaultTemperature") ?? 0.8
    }
    
    var openAIMaxTokens: Int {
        return getIntValue(for: "OpenAI.MaxTokens") ?? 500
    }
    
    // MARK: - Firebase Configuration
    
    var firebaseURL: String {
        return getStringValue(for: "Firebase.URL") ?? "YOUR_FIREBASE_URL_HERE"
    }
    
    var firebaseAPIKey: String {
        return getStringValue(for: "Firebase.APIKey") ?? "YOUR_FIREBASE_API_KEY_HERE"
    }
    
    var firebasePassword: String {
        return getStringValue(for: "Firebase.Password") ?? "YOUR_FIREBASE_PASSWORD_HERE"
    }
    
    // MARK: - Stripe Configuration
    
    var stripeAPIKey: String {
        return getStringValue(for: "Stripe.APIKey") ?? "YOUR_STRIPE_API_KEY_HERE"
    }
    
    // MARK: - App Configuration
    
    var appEnvironment: String {
        return getStringValue(for: "App.Environment") ?? "development"
    }
    
    var appVersion: String {
        return getStringValue(for: "App.Version") ?? "1.0.0"
    }
    
    var appBuildNumber: String {
        return getStringValue(for: "App.BuildNumber") ?? "1"
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
    
    private func getIntValue(for key: String) -> Int? {
        let keys = key.components(separatedBy: ".")
        var current: Any? = configDict
        
        for k in keys {
            if let dict = current as? [String: Any] {
                current = dict[k]
            } else {
                return nil
            }
        }
        
        return current as? Int
    }
    
    private func getDoubleValue(for key: String) -> Double? {
        let keys = key.components(separatedBy: ".")
        var current: Any? = configDict
        
        for k in keys {
            if let dict = current as? [String: Any] {
                current = dict[k]
            } else {
                return nil
            }
        }
        
        return current as? Double
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
    
    // MARK: - Debug Methods
    
    func printConfig() {
        print("🔧 ConfigManager: Current Configuration")
        print("=====================================")
        print("OpenAI API Key: \(isOpenAIConfigured ? "✅ Configured" : "❌ Not Configured")")
        print("OpenAI Base URL: \(openAIBaseURL)")
        print("OpenAI Model: \(openAIDefaultModel)")
        print("OpenAI Temperature: \(openAIDefaultTemperature)")
        print("OpenAI Max Tokens: \(openAIMaxTokens)")
        print("Firebase URL: \(isFirebaseConfigured ? "✅ Configured" : "❌ Not Configured")")
        print("App Environment: \(appEnvironment)")
        print("App Version: \(appVersion)")
        print("App Build: \(appBuildNumber)")
        print("=====================================")
    }
    
    func getConfigReport() -> String {
        var report = "🔧 CONFIGURATION REPORT\n"
        report += "======================\n\n"
        
        // OpenAI
        let openAIStatus = isOpenAIConfigured ? "✅" : "❌"
        report += "\(openAIStatus) OpenAI API Key: \(openAIStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   Base URL: \(openAIBaseURL)\n"
        report += "   Model: \(openAIDefaultModel)\n"
        report += "   Temperature: \(openAIDefaultTemperature)\n"
        report += "   Max Tokens: \(openAIMaxTokens)\n\n"
        
        // Firebase
        let firebaseStatus = isFirebaseConfigured ? "✅" : "❌"
        report += "\(firebaseStatus) Firebase Configuration: \(firebaseStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   URL: \(firebaseURL)\n"
        report += "   API Key: \(firebaseAPIKey.contains("YOUR_") ? "Missing" : "Configured")\n"
        report += "   Password: \(firebasePassword.contains("YOUR_") ? "Missing" : "Configured")\n\n"
        
        // Stripe
        let stripeStatus = isStripeConfigured ? "✅" : "❌"
        report += "\(stripeStatus) Stripe Configuration: \(stripeStatus == "✅" ? "Configured" : "Missing")\n"
        report += "   API Key: \(stripeAPIKey.contains("YOUR_") ? "Missing" : "Configured")\n\n"
        
        // App
        report += "📱 App Configuration:\n"
        report += "   Environment: \(appEnvironment)\n"
        report += "   Version: \(appVersion)\n"
        report += "   Build: \(appBuildNumber)\n\n"
        
        // Keychain
        let keychainStatus = SecureKeychain.areAllSecretsInKeychain() ? "✅" : "❌"
        report += "\(keychainStatus) Keychain Storage: \(keychainStatus == "✅" ? "Available" : "Not Available")\n"
        
        // Overall
        let overallStatus = areAllSecretsConfigured ? "✅" : "❌"
        report += "\n\(overallStatus) Overall Status: \(overallStatus == "✅" ? "Ready" : "Needs Configuration")\n"
        
        return report
    }
}

// MARK: - Configuration Debug View

@MainActor
struct ConfigDebugView: View {
    @StateObject private var configManager = ConfigManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🔧 Configuration Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(configManager.configStatus.description)
                        .font(.subheadline)
                        .foregroundColor(configManager.configStatus.color)
                }
                .padding(.top)
                
                // Status Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuration Status")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        StatusRow(
                            title: "OpenAI API Key",
                            isConfigured: configManager.isOpenAIConfigured
                        )
                        
                        StatusRow(
                            title: "Firebase URL",
                            isConfigured: !configManager.firebaseURL.contains("YOUR_FIREBASE_URL_HERE")
                        )
                        
                        StatusRow(
                            title: "Firebase API Key",
                            isConfigured: !configManager.firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE")
                        )
                        
                        StatusRow(
                            title: "Firebase Password",
                            isConfigured: !configManager.firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE")
                        )
                        
                        StatusRow(
                            title: "Stripe API Key",
                            isConfigured: configManager.isStripeConfigured
                        )
                        
                        StatusRow(
                            title: "Keychain Storage",
                            isConfigured: SecureKeychain.areAllSecretsInKeychain()
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: {
                        configManager.saveSecretsToKeychain()
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                            Text("Save to Keychain")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        configManager.clearSecretsFromKeychain()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Clear Keychain")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        configManager.checkConfigStatus()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh Status")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                // Debug Report
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Report")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text(configManager.getConfigReport())
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// MARK: - Status Row Component

struct StatusRow: View {
    let title: String
    let isConfigured: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isConfigured ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isConfigured ? .green : .red)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(isConfigured ? "Configured" : "Missing")
                .font(.caption)
                .foregroundColor(isConfigured ? .green : .red)
        }
    }
}

// MARK: - Preview

#Preview {
    ConfigDebugView()
} 