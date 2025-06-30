//
//  SecretsManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation
import SwiftUI

// MARK: - Secrets Manager

@MainActor
class SecretsManager: ObservableObject {
    @Published var isCheckingSecrets = false
    @Published var secretsStatus: SecretsStatus = .unknown
    @Published var errorMessage: String?
    
    enum SecretsStatus {
        case unknown
        case allConfigured
        case partiallyConfigured
        case notConfigured
        
        var description: String {
            switch self {
            case .unknown:
                return "Checking secrets..."
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
    
    init() {
        checkSecretsStatus()
    }
    
    // MARK: - Public Methods
    
    /// Check the status of all secrets
    func checkSecretsStatus() {
        isCheckingSecrets = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateSecretsStatus()
            self.isCheckingSecrets = false
        }
    }
    
    /// Save all available secrets to keychain
    func saveSecretsToKeychain() {
        SecureKeychain.saveAllSecrets()
        checkSecretsStatus()
    }
    
    /// Clear all secrets from keychain
    func clearSecretsFromKeychain() {
        SecureKeychain.clearAllSecrets()
        checkSecretsStatus()
    }
    
    /// Get detailed secrets report
    func getSecretsReport() -> String {
        var report = "🔐 SECRETS STATUS REPORT\n"
        report += "========================\n\n"
        
        // Check OpenAI
        let openAIStatus = APIConfig.isAPIKeyConfigured ? "✅" : "❌"
        report += "\(openAIStatus) OpenAI API Key: \(openAIStatus == "✅" ? "Configured" : "Missing")\n"
        
        // Check Firebase
        let firebaseURLStatus = !APIConfig.firebaseURL.contains("YOUR_FIREBASE_URL_HERE") ? "✅" : "❌"
        report += "\(firebaseURLStatus) Firebase URL: \(firebaseURLStatus == "✅" ? "Configured" : "Missing")\n"
        
        let firebaseAPIStatus = !APIConfig.firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE") ? "✅" : "❌"
        report += "\(firebaseAPIStatus) Firebase API Key: \(firebaseAPIStatus == "✅" ? "Configured" : "Missing")\n"
        
        let firebasePasswordStatus = !APIConfig.firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE") ? "✅" : "❌"
        report += "\(firebasePasswordStatus) Firebase Password: \(firebasePasswordStatus == "✅" ? "Configured" : "Missing")\n"
        
        // Check keychain
        let keychainStatus = SecureKeychain.areAllSecretsInKeychain() ? "✅" : "❌"
        report += "\(keychainStatus) Keychain Storage: \(keychainStatus == "✅" ? "Available" : "Not Available")\n"
        
        // Overall status
        let overallStatus = APIConfig.areAllSecretsConfigured ? "✅" : "❌"
        report += "\n\(overallStatus) Overall Status: \(overallStatus == "✅" ? "Ready" : "Needs Configuration")\n"
        
        return report
    }
    
    // MARK: - Private Methods
    
    private func updateSecretsStatus() {
        if APIConfig.areAllSecretsConfigured {
            secretsStatus = .allConfigured
        } else if APIConfig.isAPIKeyConfigured || APIConfig.isFirebaseConfigured {
            secretsStatus = .partiallyConfigured
        } else {
            secretsStatus = .notConfigured
        }
    }
}

// MARK: - Secrets Debug View

struct SecretsDebugView: View {
    @StateObject private var secretsManager = SecretsManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🔐 Secrets Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(secretsManager.secretsStatus.description)
                        .font(.subheadline)
                        .foregroundColor(secretsManager.secretsStatus.color)
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
                            isConfigured: APIConfig.isAPIKeyConfigured
                        )
                        
                        StatusRow(
                            title: "Firebase URL",
                            isConfigured: !APIConfig.firebaseURL.contains("YOUR_FIREBASE_URL_HERE")
                        )
                        
                        StatusRow(
                            title: "Firebase API Key",
                            isConfigured: !APIConfig.firebaseAPIKey.contains("YOUR_FIREBASE_API_KEY_HERE")
                        )
                        
                        StatusRow(
                            title: "Firebase Password",
                            isConfigured: !APIConfig.firebasePassword.contains("YOUR_FIREBASE_PASSWORD_HERE")
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
                        secretsManager.saveSecretsToKeychain()
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
                        secretsManager.clearSecretsFromKeychain()
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
                        secretsManager.checkSecretsStatus()
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
                        
                        Text(secretsManager.getSecretsReport())
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
    SecretsDebugView()
} 