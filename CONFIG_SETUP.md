# Configuration Setup Guide

This guide explains how to set up API keys and secrets for the Zodiaccurate app using the new plist-based configuration system.

## 📁 Files Created

1. **`Zodiaccurate/Config.plist`** - Main configuration file (gitignored)
2. **`Zodiaccurate/Config.template.plist`** - Template file (committed to git)
3. **`Zodiaccurate/Utils/ConfigManager.swift`** - Configuration manager class
4. **`.gitignore`** - Updated to exclude Config.plist

## 🔧 Setup Instructions

### Step 1: Create Your Configuration File

1. Copy the template file:
   ```bash
   cp Zodiaccurate/Config.template.plist Zodiaccurate/Config.plist
   ```

2. Open `Zodiaccurate/Config.plist` in Xcode or your preferred text editor

### Step 2: Add Your API Keys

Replace the placeholder values with your actual API keys:

#### OpenAI Configuration
```xml
<key>OpenAI</key>
<dict>
    <key>APIKey</key>
    <string>sk-your-actual-openai-api-key-here</string>
    <key>BaseURL</key>
    <string>https://api.openai.com/v1/chat/completions</string>
    <key>DefaultModel</key>
    <string>gpt-4</string>
    <key>DefaultTemperature</key>
    <real>0.8</real>
    <key>MaxTokens</key>
    <integer>500</integer>
</dict>
```

#### Firebase Configuration
```xml
<key>Firebase</key>
<dict>
    <key>URL</key>
    <string>https://your-project.firebaseio.com</string>
    <key>APIKey</key>
    <string>your-firebase-api-key</string>
    <key>Password</key>
    <string>your-firebase-password</string>
</dict>
```

### Step 3: Update App Configuration

```xml
<key>App</key>
<dict>
    <key>Environment</key>
    <string>development</string>
    <key>Version</key>
    <string>1.0.0</string>
    <key>BuildNumber</key>
    <string>1</string>
</dict>
```

## 🚀 Usage in Code

### Basic Usage

```swift
import Foundation

// Access configuration values
let apiKey = ConfigManager.shared.openAIAPIKey
let firebaseURL = ConfigManager.shared.firebaseURL
let model = ConfigManager.shared.openAIDefaultModel

// Check if configuration is complete
if ConfigManager.shared.areAllSecretsConfigured {
    print("✅ All secrets are configured")
} else {
    print("❌ Some secrets are missing")
}
```

### Validation

```swift
// Check individual services
if ConfigManager.shared.isOpenAIConfigured {
    print("OpenAI is configured")
}

if ConfigManager.shared.isFirebaseConfigured {
    print("Firebase is configured")
}
```

### Debug Information

```swift
// Print current configuration (for debugging)
ConfigManager.shared.printConfig()

// Get detailed configuration report
let report = ConfigManager.shared.getConfigReport()
print(report)
```

## 🔒 Security Notes

### Important Security Practices

1. **Never commit `Config.plist` to version control**
   - The file is already added to `.gitignore`
   - Only `Config.template.plist` should be committed

2. **Use different keys for different environments**
   - Development: Use test API keys
   - Production: Use production API keys
   - Staging: Use staging API keys

3. **Rotate API keys regularly**
   - Update keys in the plist file
   - Test the app after key changes

4. **Consider using iOS Keychain for additional security**
   - The existing `SecureKeychain` class can be used
   - Store sensitive keys in keychain instead of plist

## 🔄 Migration from Existing System

The new `ConfigManager` works alongside your existing `APIConfig` and `SecretsManager` classes. You can:

1. **Gradually migrate** to using `ConfigManager` for new features
2. **Keep existing code** working with `APIConfig`
3. **Use both systems** during transition period

### Example: Hybrid Approach

```swift
// Use ConfigManager for new features
let newAPIKey = ConfigManager.shared.openAIAPIKey

// Keep existing APIConfig for backward compatibility
let existingAPIKey = APIConfig.openAIAPIKey
```

## 🛠️ Troubleshooting

### Common Issues

1. **Config.plist not found**
   - Ensure the file exists in the correct location
   - Check that it's added to your Xcode project
   - Verify the file name is exactly `Config.plist`

2. **Configuration values not loading**
   - Check the plist file format
   - Ensure keys match exactly (case-sensitive)
   - Verify the file is included in the app bundle

3. **API keys not working**
   - Verify the keys are correct
   - Check for extra spaces or characters
   - Test the keys independently

### Debug Commands

```swift
// Add this to your app's initialization
ConfigManager.shared.printConfig()
```

## 📋 Configuration Reference

### Available Configuration Keys

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| `OpenAI.APIKey` | String | OpenAI API key | `YOUR_OPENAI_API_KEY_HERE` |
| `OpenAI.BaseURL` | String | OpenAI API base URL | `https://api.openai.com/v1/chat/completions` |
| `OpenAI.DefaultModel` | String | Default model to use | `gpt-4` |
| `OpenAI.DefaultTemperature` | Double | Temperature for responses | `0.8` |
| `OpenAI.MaxTokens` | Integer | Maximum tokens per response | `500` |
| `Firebase.URL` | String | Firebase Realtime Database URL | `YOUR_FIREBASE_URL_HERE` |
| `Firebase.APIKey` | String | Firebase API key | `YOUR_FIREBASE_API_KEY_HERE` |
| `Firebase.Password` | String | Firebase password | `YOUR_FIREBASE_PASSWORD_HERE` |
| `App.Environment` | String | App environment | `development` |
| `App.Version` | String | App version | `1.0.0` |
| `App.BuildNumber` | String | App build number | `1` |

## 🔄 Updates and Maintenance

### Adding New Configuration Keys

1. Add the key to `Config.plist`
2. Add the key to `Config.template.plist`
3. Add a property to `ConfigManager.swift`
4. Update this documentation

### Environment-Specific Configuration

For different environments, you can create multiple plist files:
- `Config.Development.plist`
- `Config.Staging.plist`
- `Config.Production.plist`

And load the appropriate one based on your build configuration. 