# 🔐 GitHub Secrets Setup Guide

This guide explains how to set up GitHub Secrets for the Zodiaccurate iOS app to securely manage API keys and configuration.

## 📋 Required Secrets

Add these secrets to your GitHub repository:

### 1. **OPENAI_API_KEY**
- **Purpose**: OpenAI API key for horoscope generation
- **Format**: `sk-` or `sk-proj-` followed by your API key
- **Source**: [OpenAI Platform](https://platform.openai.com/api-keys)

### 2. **FIREBASE_URL**
- **Purpose**: Firebase Realtime Database URL
- **Format**: `https://your-project-id.firebaseio.com`
- **Source**: Firebase Console → Realtime Database → Rules

### 3. **FIREBASE_API_KEY**
- **Purpose**: Firebase API key for authentication
- **Format**: Long alphanumeric string
- **Source**: Firebase Console → Project Settings → General

### 4. **FIREBASE_PASSWORD**
- **Purpose**: Firebase password for database access
- **Format**: Your Firebase password
- **Source**: Firebase Console → Authentication → Users

## 🚀 Setup Instructions

### Step 1: Add Secrets to GitHub

1. Go to your GitHub repository: `casspangell/zodiaccurate-ios`
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the exact names listed above

### Step 2: Trigger GitHub Actions

1. **Push to main branch** to trigger automatic build
2. **Or manually trigger** the Development Build workflow:
   - Go to **Actions** tab
   - Select **Development Build**
   - Click **Run workflow**
   - Choose environment (development/staging/production)

### Step 3: Verify Setup

1. Run the app on your device/simulator
2. Navigate to the sign-in screen
3. Tap **"Retrieve GitHub Secrets"** button
4. Check the console output for:
   ```
   ✅ OPENAI_API_KEY: Available
   ✅ FIREBASE_URL: Available
   ✅ FIREBASE_API_KEY: Available
   ✅ FIREBASE_PASSWORD: Available
   ```

## 🔄 How It Works

### Build Environment Injection
- GitHub Actions injects secrets as environment variables
- App reads secrets from `ProcessInfo.processInfo.environment`
- Secrets are automatically synced to iOS Keychain for offline access

### Fallback Chain
1. **GitHub Actions** (production builds)
2. **iOS Keychain** (local storage)
3. **Local config** (development fallback)

### Security Features
- ✅ Secrets never committed to code
- ✅ Automatic keychain sync
- ✅ Environment-specific builds
- ✅ Secure secret rotation

## 🛠️ Troubleshooting

### "No secrets available" Error
- Verify all 4 secrets are added to GitHub
- Check secret names match exactly
- Ensure GitHub Actions workflow ran successfully

### "Cosmic Connection Issue"
- Confirm OpenAI API key is valid
- Check API key has sufficient credits
- Verify Firebase configuration

### Build Failures
- Check GitHub Actions logs
- Verify Xcode version compatibility
- Ensure CocoaPods are properly configured

## 📱 Development vs Production

### Development
- Use local API keys for quick testing
- Secrets stored in iOS Keychain
- Manual configuration required

### Production
- GitHub Secrets automatically injected
- Secure, no manual configuration
- Automatic deployment pipeline

## 🔒 Security Best Practices

1. **Never commit secrets** to version control
2. **Rotate secrets regularly**
3. **Use environment-specific secrets**
4. **Monitor secret usage**
5. **Limit secret access** to necessary team members

## 📞 Support

If you encounter issues:
1. Check GitHub Actions logs
2. Verify secret configuration
3. Test with the "Retrieve GitHub Secrets" button
4. Review this documentation

---

**Last Updated**: June 30, 2025
**Version**: 1.0 