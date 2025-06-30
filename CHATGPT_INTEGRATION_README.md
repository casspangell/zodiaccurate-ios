# ChatGPT Integration for Zodiaccurate

This document explains how to set up and use the ChatGPT API integration for generating personalized horoscopes in the Zodiaccurate app.

## Overview

The ChatGPT integration provides two main features:
1. **Welcome Horoscope**: Generated when a user completes onboarding to create a captivating first experience
2. **Daily Horoscope**: Generated on-demand for existing users to provide daily cosmic guidance

## Setup Instructions

### 1. Get an OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the generated API key (it starts with `sk-`)

### 2. Configure the API Key (Choose One Option)

#### Option A: GitHub Secrets (Recommended for Production)

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add the following repository secrets:

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

3. Click "Add secret" for each one

The GitHub Actions workflow will automatically inject all secrets during builds.

#### Option B: Local Development

1. Open `Zodiaccurate/Utils/APIConfig.swift`
2. Replace `"YOUR_OPENAI_API_KEY_HERE"` with your actual API key:

```swift
// In the fallback section:
return "sk-your-actual-api-key-here"
```

### 3. Test the Integration

#### For GitHub Secrets Setup:
1. Push your code to GitHub (triggers GitHub Actions)
2. Download the built app or build locally with secrets injected
3. Complete the onboarding process
4. You should see the generated welcome horoscope
5. In the main app, tap "Generate Your Daily Horoscope" to test daily horoscopes
6. **Debug**: Go to Settings → Development → Secrets Manager to verify all secrets are loaded

#### For Local Development:
1. Build and run the app
2. Complete the onboarding process
3. You should see the generated welcome horoscope
4. In the main app, tap "Generate Your Daily Horoscope" to test daily horoscopes
5. **Debug**: Go to Settings → Development → Secrets Manager to check configuration

## How It Works

### Data Collection

The system collects the following user data during onboarding:
- **Name**: User's first name
- **Birth Date**: Date of birth
- **Birth Time**: Time of birth (if known)
- **Zodiac Sign**: Automatically determined from birth date
- **Personal Responses**: Answers to questions about intuition, energy, and dreams

### Prompt Engineering

The system uses carefully crafted prompts to generate personalized horoscopes:

#### Welcome Horoscope Prompt
- Addresses the user by name
- References their specific zodiac sign and birth details
- Incorporates their personal responses
- Creates a sense of wonder and cosmic connection
- Hints at deeper insights available through subscription
- Uses mystical, enchanting language
- Ends with a compelling reason to subscribe

#### Daily Horoscope Prompt
- Provides specific guidance for the current day
- Relates to the user's zodiac sign traits
- Uses encouraging and positive language
- Maintains the mystical, personal tone

### API Configuration

The system uses the following settings:
- **Model**: GPT-4 (configurable in `APIConfig.swift`)
- **Temperature**: 0.8 (balanced creativity and consistency)
- **Max Tokens**: 500 (sufficient for detailed horoscopes)

## Files Overview

### Core Files

- **`OnboardingAI.swift`**: Main AI manager and API integration
- **`APIConfig.swift`**: Configuration and security settings
- **`GeneratedHoroscopeView.swift`**: Welcome horoscope display
- **`DailyHoroscopeSheet.swift`**: Daily horoscope interface
- **`SecretsManager.swift`**: Comprehensive secrets management and debugging

### Integration Points

- **`ConversationalOnboardingView.swift`**: Triggers welcome horoscope after onboarding
- **`MainView.swift`**: Provides daily horoscope generation interface
- **`SettingsView.swift`**: Includes secrets debug interface (debug builds only)

## Security Considerations

### Development
- API keys are stored in plain text for development
- Never commit API keys to version control
- Use environment variables or secure storage in production

### Production Recommendations
1. **Use iOS Keychain** for secure API key storage
2. **Implement a backend service** to proxy API calls
3. **Add rate limiting** to prevent abuse
4. **Monitor API usage** and costs
5. **Implement proper error handling**

### Example Keychain Implementation

```swift
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
```

## Usage Examples

### Generating a Welcome Horoscope

```swift
@StateObject private var onboardingAI = OnboardingAI()

// Generate welcome horoscope
await onboardingAI.generateWelcomeHoroscope()

// Access the generated horoscope
if let horoscope = onboardingAI.generatedHoroscope {
    print("Generated horoscope: \(horoscope)")
}
```

### Generating a Daily Horoscope

```swift
@StateObject private var onboardingAI = OnboardingAI()

// Generate daily horoscope
if let horoscope = await onboardingAI.generateDailyHoroscope() {
    print("Daily horoscope: \(horoscope)")
}
```

## Error Handling

The system includes comprehensive error handling:

- **API Key Not Configured**: Clear instructions for setup
- **Network Errors**: User-friendly error messages
- **API Errors**: Detailed error information for debugging
- **Rate Limiting**: Graceful handling of API limits

## Cost Management

### OpenAI API Pricing (as of 2024)
- **GPT-4**: ~$0.03 per 1K input tokens, ~$0.06 per 1K output tokens
- **Typical horoscope**: ~200-300 tokens total
- **Estimated cost per horoscope**: ~$0.01-0.02

### Optimization Tips
1. **Cache horoscopes** to avoid regenerating the same content
2. **Implement daily limits** per user
3. **Use GPT-3.5-turbo** for cost-sensitive applications
4. **Monitor usage** with OpenAI's dashboard

## Troubleshooting

### Common Issues

1. **"API Key Not Configured" Error**
   - Ensure you've replaced the placeholder in `APIConfig.swift`
   - Restart the app after making changes

2. **Network Timeout**
   - Check internet connection
   - Verify OpenAI API status at https://status.openai.com

3. **Rate Limiting**
   - Implement exponential backoff
   - Add delays between requests

4. **Invalid Response**
   - Check API key permissions
   - Verify account has sufficient credits

### Debug Information

Enable debug logging by checking the console output:
- API requests and responses
- Error details
- Generated horoscope content

## Future Enhancements

### Planned Features
1. **Horoscope Caching**: Store generated horoscopes locally
2. **Personalization**: Learn from user interactions
3. **Multiple Models**: Support for different AI models
4. **Offline Mode**: Pre-generated content for offline use
5. **Analytics**: Track user engagement and preferences

### Integration Opportunities
1. **Push Notifications**: Daily horoscope reminders
2. **Social Sharing**: Share horoscopes with friends
3. **Calendar Integration**: Astrological event notifications
4. **Voice Interface**: Voice-activated horoscope generation

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review OpenAI's API documentation
3. Check the app's console output for error details
4. Verify your API key and account status

## License

This integration is part of the Zodiaccurate app. Please ensure compliance with OpenAI's usage policies and terms of service. 