# GitHub Secrets Integration for Zodiaccurate iOS

This document explains the improved GitHub Secrets integration for the Zodiaccurate iOS app, which provides secure API key management through GitHub Actions.

## Overview

The GitHub Secrets integration provides a secure way to manage API keys and sensitive configuration data without exposing them in your source code. The system works by:

1. **Storing secrets in GitHub**: API keys are stored as repository secrets
2. **Injecting during build**: GitHub Actions injects secrets as environment variables during CI/CD builds
3. **Local fallback**: The app can work with locally configured keys for development
4. **Keychain sync**: Secrets can be synced to iOS Keychain for offline use

## Architecture

### Components

- **`SecretsManager.swift`**: Comprehensive secrets management with GitHub integration
- **`SecureKeychain.swift`**: iOS Keychain integration for local storage
- **`APIConfig.swift`**: Configuration management with fallback logic
- **`.github/workflows/build.yml`**: GitHub Actions workflow for secret injection

### Security Flow

```
GitHub Secrets → GitHub Actions → Build Environment → iOS App → Keychain (optional)
```

## Setup Instructions

### 1. Configure GitHub Secrets

1. Go to your GitHub repository: https://github.com/casspangell/zodiaccurate-ios
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following repository secrets:

   **OpenAI Integration:**
   - Name: `OPENAI_API_KEY`
   - Value: Your OpenAI API key (starts with `sk-`)

   **Firebase Integration:**
   - Name: `FIREBASE_URL`
   - Value: Your Firebase project URL
   - Name: `FIREBASE_PASSWORD`
   - Value: Your Firebase password
   - Name: `FIREBASE_API_KEY`
   - Value: Your Firebase API key

4. Click **Add secret** for each one

### 2. GitHub Actions Workflow

The `.github/workflows/build.yml` file automatically:
- Triggers on pushes to `main` and `develop` branches
- Sets up Xcode and CocoaPods
- Injects all secrets as environment variables during build
- Runs tests with secrets available

### 3. Local Development

For local development, you can still use the fallback configuration in `APIConfig.swift`:

```swift
// Replace these placeholders with your actual values
return "YOUR_OPENAI_API_KEY_HERE"
return "YOUR_FIREBASE_URL_HERE"
// etc.
```

## How It Works

### Secret Resolution Priority

The app uses the following priority order for secret resolution:

1. **GitHub Actions Environment** (highest priority)
   - Secrets injected by GitHub Actions during build
   - Most secure for production builds

2. **iOS Keychain** (fallback)
   - Secrets synced from GitHub Actions or manually stored
   - Allows offline functionality

3. **Local Configuration** (development)
   - Hardcoded values in `APIConfig.swift`
   - Only for development/testing

## Usage Examples

### Checking Secret Status

```swift
@StateObject private var githubSecretManager = GitHubSecretManager()

// Check if all secrets are available
if githubSecretManager.validateSecretsConfiguration() {
    print("All GitHub Secrets are available")
}

// Get detailed status report
let report = githubSecretManager.getGitHubSecretsReport()
print(report)
```

### Syncing to Keychain

```swift
// Sync GitHub Secrets to iOS Keychain for offline use
if githubSecretManager.validateSecretsConfiguration() {
    githubSecretManager.syncSecretsToKeychain()
}
```

### Getting Secrets

```swift
// Get a specific secret
if let apiKey = githubSecretManager.getSecret("OPENAI_API_KEY") {
    // Use the API key
}
```

## Debugging

### Secrets Debug Interface

The app includes a comprehensive debug interface accessible through:
1. **Settings** → **Development** → **Secrets Manager** (debug builds only)
2. Shows status of all secrets from all sources
3. Provides buttons to sync and manage secrets
4. Displays detailed reports

### Console Logging

The system provides detailed console logging:
- Secret availability status
- Sync operations
- Error conditions
- Configuration validation

### Common Issues

1. **"GitHub Secrets not available"**
   - Ensure secrets are configured in GitHub repository
   - Check that GitHub Actions workflow is running
   - Verify secret names match expected values

2. **"Keychain sync failed"**
   - Check iOS Keychain permissions
   - Ensure device is unlocked
   - Verify secret values are valid

3. **"Build environment missing"**
   - Run app from GitHub Actions build
   - Check workflow configuration
   - Verify environment variable injection

## Security Best Practices

### Production Security

1. **Never commit secrets to source code**
2. **Use GitHub Secrets for all sensitive data**
3. **Rotate API keys regularly**
4. **Monitor secret usage and access**
5. **Use least privilege principle**

### Development Security

1. **Use local configuration for development**
2. **Don't share local API keys**
3. **Use test accounts when possible**
4. **Clear keychain when switching environments**

### Keychain Security

1. **Secrets are encrypted in iOS Keychain**
2. **Access requires device unlock**
3. **Secrets persist across app updates**
4. **Can be cleared manually or programmatically**

## Troubleshooting

### GitHub Actions Issues

1. **Workflow not triggering**
   - Check branch name matches workflow trigger
   - Verify workflow file is in correct location
   - Check GitHub Actions permissions

2. **Secrets not injected**
   - Verify secret names match workflow environment variables
   - Check secret values are not empty
   - Ensure repository has Actions permissions

3. **Build failures**
   - Check Xcode version compatibility
   - Verify CocoaPods dependencies
   - Review build logs for specific errors

### App Integration Issues

1. **Secrets not available in app**
   - Ensure app is built from GitHub Actions
   - Check `APIConfig.swift` fallback logic
   - Verify secret resolution priority

2. **Keychain sync issues**
   - Check iOS Keychain permissions
   - Ensure device is unlocked
   - Verify secret values are valid strings

## Future Enhancements

### Planned Features

1. **Secret Rotation**: Automatic secret rotation support
2. **Usage Monitoring**: Track secret usage and costs
3. **Multi-Environment**: Support for different environments (dev/staging/prod)
4. **Audit Logging**: Comprehensive audit trail for secret access
5. **Backup/Restore**: Secure backup and restore of keychain data

### Integration Opportunities

1. **CI/CD Pipeline**: Enhanced build and deployment automation
2. **Monitoring**: Integration with monitoring and alerting systems
3. **Analytics**: Secret usage analytics and reporting
4. **Compliance**: Support for compliance frameworks (SOC2, GDPR, etc.)

## Support

For issues or questions:

1. **Check this documentation** for common solutions
2. **Review GitHub Actions logs** for build issues
3. **Use the debug interface** in the app for configuration issues
4. **Check console output** for detailed error messages
5. **Verify GitHub repository settings** for secret configuration

## License

This integration is part of the Zodiaccurate iOS app. Please ensure compliance with:
- GitHub's terms of service
- OpenAI's API usage policies
- Firebase's terms of service
- iOS App Store guidelines 