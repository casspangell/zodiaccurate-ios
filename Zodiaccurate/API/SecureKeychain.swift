import Foundation
import Security

class SecureKeychain {
    static func saveAPIKey(_ key: String, for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("❌ Failed to save \(account) to keychain: \(status)")
        } else {
            print("✅ Successfully saved \(account) to keychain")
        }
    }

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

    static func deleteAPIKey(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

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

    static func clearAllSecrets() {
        deleteAPIKey(for: "OpenAI_API_Key")
        deleteAPIKey(for: "FIREBASE_URL")
        deleteAPIKey(for: "FIREBASE_API_KEY")
        deleteAPIKey(for: "FIREBASE_PASSWORD")
        print("🗑️ All secrets cleared from keychain")
    }

    static func areAllSecretsInKeychain() -> Bool {
        return getAPIKey(for: "OpenAI_API_Key") != nil &&
               getAPIKey(for: "FIREBASE_URL") != nil &&
               getAPIKey(for: "FIREBASE_API_KEY") != nil &&
               getAPIKey(for: "FIREBASE_PASSWORD") != nil
    }
} 