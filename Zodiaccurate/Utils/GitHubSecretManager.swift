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
    @Published var secretsStatus: GitHubSecretsStatus = .unknown
    
    // GitHub API configuration
    private let baseURL = "https://api.github.com"
    private let repository = "casspangell/zodiaccurate-ios"
    
    // Expected secret names (matching GitHub Actions workflow)
    private let expectedSecrets = [
        "OPENAI_API_KEY",
        "FIREBASE_URL", 
        "FIREBASE_PASSWORD",
        "FIREBASE_API_KEY"
    ]
    
    enum GitHubSecretsStatus {
        case unknown
        case available
        case partiallyAvailable
        case notAvailable
        case error(String)
        
        var description: String {
            switch self {
            case .unknown:
                return "Checking GitHub Secrets..."
            case .available:
                return "✅ GitHub Secrets available"
            case .partiallyAvailable:
                return "⚠️ Some GitHub Secrets missing"
            case .notAvailable:
                return "❌ GitHub Secrets not available"
            case .error(let message):
                return "❌ Error: \(message)"
            }
        }
        
        var color: String {
            switch self {
            case .unknown:
                return "gray"
            case .available:
                return "green"
            case .partiallyAvailable:
                return "orange"
            case .notAvailable, .error:
                return "red"
            }
        }
    }
    
    init() {
        checkGitHubSecretsStatus()
        // Automatically sync secrets to keychain if available
        syncSecretsToKeychain()
    }
    
    // MARK: - Public Methods
    
    /// Check the status of GitHub Secrets availability
    /// Note: This checks if secrets are available in the build environment
    /// (set by GitHub Actions), not direct access to GitHub Secrets API
    func checkGitHubSecretsStatus() {
        isLoading = true
        error = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateSecretsStatus()
            self.isLoading = false
        }
    }
    
    /// Get a comprehensive report of GitHub Secrets status
    func getGitHubSecretsReport() -> String {
        var report = "🔐 GITHUB SECRETS STATUS REPORT\n"
        report += "================================\n\n"
        
        // Check each expected secret
        var availableCount = 0
        for secretName in expectedSecrets {
            let isAvailable = ProcessInfo.processInfo.environment[secretName] != nil
            let status = isAvailable ? "✅" : "❌"
            report += "\(status) \(secretName): \(isAvailable ? "Available" : "Missing")\n"
            if isAvailable { availableCount += 1 }
        }
        
        // Overall status
        report += "\n📊 Summary:\n"
        report += "- Available: \(availableCount)/\(expectedSecrets.count)\n"
        report += "- Missing: \(expectedSecrets.count - availableCount)/\(expectedSecrets.count)\n"
        
        let overallStatus: String
        if availableCount == expectedSecrets.count {
            overallStatus = "✅ All secrets available"
        } else if availableCount > 0 {
            overallStatus = "⚠️ Partially configured"
        } else {
            overallStatus = "❌ No secrets available"
        }
        
        report += "- Status: \(overallStatus)\n"
        
        // Add helpful information
        if availableCount < expectedSecrets.count {
            report += "\n💡 To configure GitHub Secrets:\n"
            report += "1. Go to your GitHub repo → Settings → Secrets and variables → Actions\n"
            report += "2. Add the missing repository secrets\n"
            report += "3. Push to trigger GitHub Actions build\n"
        }
        
        return report
    }
    
    /// Validate that all required secrets are properly configured
    func validateSecretsConfiguration() -> Bool {
        return expectedSecrets.allSatisfy { secretName in
            ProcessInfo.processInfo.environment[secretName] != nil
        }
    }
    
    /// Get a specific secret from the build environment
    func getSecret(_ secretName: String) -> String? {
        return ProcessInfo.processInfo.environment[secretName]
    }
    
    // MARK: - Private Methods
    
    private func updateSecretsStatus() {
        let availableSecrets = expectedSecrets.filter { secretName in
            ProcessInfo.processInfo.environment[secretName] != nil
        }
        
        if availableSecrets.count == expectedSecrets.count {
            secretsStatus = .available
        } else if availableSecrets.count > 0 {
            secretsStatus = .partiallyAvailable
        } else {
            secretsStatus = .notAvailable
        }
    }
}

// MARK: - GitHub Secrets Integration Helper

extension GitHubSecretManager {
    
    /// Sync GitHub Secrets with local keychain storage
    /// This allows the app to work offline after initial setup
    func syncSecretsToKeychain() {
        var syncedCount = 0
        
        for secretName in expectedSecrets {
            if let secretValue = ProcessInfo.processInfo.environment[secretName] {
                SecureKeychain.saveAPIKey(secretValue, for: secretName)
                syncedCount += 1
                print("✅ Synced \(secretName) to keychain")
            }
        }
        
        print("📦 Synced \(syncedCount)/\(expectedSecrets.count) secrets to keychain")
    }
    
    /// Check if secrets are available from any source (GitHub Actions or Keychain)
    func areSecretsAvailable() -> Bool {
        // First check build environment (GitHub Actions)
        if validateSecretsConfiguration() {
            return true
        }
        
        // Fallback to keychain
        return SecureKeychain.areAllSecretsInKeychain()
    }
    
    /// Get the best available source for secrets
    func getBestAvailableSecretsSource() -> String {
        if validateSecretsConfiguration() {
            return "GitHub Actions (Build Environment)"
        } else if SecureKeychain.areAllSecretsInKeychain() {
            return "iOS Keychain (Local Storage)"
        } else {
            return "None Available"
        }
    }
} 
