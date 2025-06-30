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