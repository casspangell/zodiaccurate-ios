# Onboarding Data Persistence System

This document explains how the onboarding data is saved and accessed in the Zodiaccurate app.

## Overview

The onboarding data persistence system uses a dual approach:
1. **SwiftData** for robust local database storage
2. **UserDefaults** for quick access to frequently used data

## Data Model

### UserDataModel (SwiftData)
- `firstName`: String
- `birthDate`: String  
- `birthTime`: String
- `zodiacSign`: String
- `responses`: [String] (stored as "key:value" strings)
- `userId`: String? (for future user authentication)
- `createdAt`: Date
- `updatedAt`: Date

### UserData (Temporary)
Used during onboarding to collect data before saving to persistent storage.

## How It Works

### 1. During Onboarding
- User data is collected in the `ConversationalOnboardingView`
- Data is stored temporarily in a `UserData` struct
- When onboarding completes, data is saved to both SwiftData and UserDefaults

### 2. Data Saving
```swift
private func saveOnboardingData() {
    // Save to SwiftData via UserDataManager
    userDataManager.saveUserData(userData)
    
    // Save to UserDefaults for quick access
    UserDefaults.standard.set(userData.firstName, forKey: "userFirstName")
    UserDefaults.standard.set(userData.birthDate, forKey: "userBirthDate")
    // ... etc
}
```

### 3. Data Access
There are multiple ways to access the saved data:

#### Quick Access (UserDefaults)
```swift
let name = OnboardingDataAccess.firstName
let zodiacSign = OnboardingDataAccess.zodiacSign
let responses = OnboardingDataAccess.responses
```

#### SwiftData Access
```swift
@Environment(\.modelContext) private var modelContext
@StateObject private var userDataManager = UserDataManager(modelContext: modelContext)

// Load user data
let userData = userDataManager.loadUserData()
```

#### UserProfileManager (Recommended)
```swift
@StateObject private var profileManager = UserProfileManager(modelContext: modelContext)

// Access profile data
let name = profileManager.firstName
let zodiacSign = profileManager.zodiacSign
let response = profileManager.getResponse(for: "intuition")
```

## Usage Examples

### In a View
```swift
struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var profileManager: UserProfileManager
    
    init() {
        self._profileManager = StateObject(wrappedValue: UserProfileManager(modelContext: ModelContext(try! ModelContainer(for: UserDataModel.self))))
    }
    
    var body: some View {
        VStack {
            Text("Hello, \(profileManager.firstName)!")
            Text("Your zodiac sign: \(profileManager.zodiacSign)")
            
            if let intuition = profileManager.getResponse(for: "intuition") {
                Text("Your intuition response: \(intuition)")
            }
        }
        .onAppear {
            profileManager.updateModelContext(modelContext)
        }
    }
}
```

### Quick Access (No SwiftData needed)
```swift
struct SimpleView: View {
    var body: some View {
        VStack {
            Text("Welcome, \(OnboardingDataAccess.firstName)!")
            Text("Zodiac: \(OnboardingDataAccess.zodiacSign)")
        }
    }
}
```

## Data Flow

1. **Onboarding** → Collects data in `UserData`
2. **Completion** → Saves to SwiftData + UserDefaults
3. **App Usage** → Access via UserProfileManager or OnboardingDataAccess
4. **Sign Out** → Clears all data

## Key Files

- `UserDataModel.swift` - SwiftData model definition
- `UserDataManager.swift` - SwiftData operations
- `OnboardingDataAccess.swift` - Quick access utilities
- `UserProfileManager.swift` - High-level profile management
- `ConversationalOnboardingView.swift` - Data collection and saving

## Benefits

1. **Dual Storage**: SwiftData for reliability, UserDefaults for speed
2. **Easy Access**: Multiple ways to access data based on needs
3. **Type Safety**: Strongly typed data structures
4. **Persistence**: Data survives app restarts
5. **Flexibility**: Can be extended for user authentication

## Future Enhancements

- User authentication integration
- Cloud sync capabilities
- Data export/import
- Profile editing functionality 