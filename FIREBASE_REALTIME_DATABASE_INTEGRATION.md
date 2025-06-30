# Firebase Realtime Database Integration

This document explains how the Zodiaccurate iOS app integrates with Firebase Realtime Database to save user data to the `trial_users` and `onboarding` tables.

## Database URL

**Firebase Realtime Database**: https://zodiaccurate-e9aaf-default-rtdb.firebaseio.com

## Database Structure

### Table: `trial_users`
Stores user registration and trial information.

**Structure:**
```
trial_users/
  ├── {userId}/
  │   ├── email: String (formatted: periods→_, @→_at_)
  │   ├── originalEmail: String (original format)
  │   ├── userId: String
  │   ├── profileUUID: String
  │   ├── createdAt: Timestamp
  │   ├── lastLogin: Timestamp
  │   ├── status: String ("active", "expired", "converted")
  │   └── trialStartDate: Timestamp
```

**Example Data:**
```json
{
  "trial_users": {
    "abc123def456": {
      "email": "test_user_at_testing_com",
      "originalEmail": "test.user@testing.com",
      "userId": "abc123def456",
      "profileUUID": "uuid-1234-5678-90ab",
      "createdAt": 1735689600000,
      "lastLogin": 1735689600000,
      "status": "active",
      "trialStartDate": 1735689600000
    }
  }
}
```

### Table: `onboarding`
Stores user onboarding data and responses.

**Structure:**
```
onboarding/
  ├── {userId}/
  │   ├── userId: String
  │   ├── profileUUID: String
  │   ├── firstName: String
  │   ├── birthDate: String
  │   ├── birthTime: String
  │   ├── zodiacSign: String
  │   ├── responses: Object
  │   │   ├── intuition: Object
  │   │   │   ├── question: String
  │   │   │   └── answer: String
  │   │   ├── energy: Object
  │   │   │   ├── question: String
  │   │   │   └── answer: String
  │   │   └── dreams: Object
  │   │       ├── question: String
  │   │       └── answer: String
  │   ├── completedAt: Timestamp
  │   └── hasCompletedOnboarding: Boolean
```

**Example Data:**
```json
{
  "onboarding": {
    "abc123def456": {
      "userId": "abc123def456",
      "profileUUID": "uuid-1234-5678-90ab",
      "firstName": "Sarah",
      "birthDate": "March 15, 1990",
      "birthTime": "2:30 PM",
      "zodiacSign": "Pisces",
      "responses": {
        "intuition": {
          "question": "How would you describe your intuition?",
          "answer": "I often have strong gut feelings about people and situations"
        },
        "energy": {
          "question": "What's your energy like?",
          "answer": "I'm usually calm and peaceful, but can be very passionate"
        },
        "dreams": {
          "question": "What do you dream about?",
          "answer": "I dream about water, nature, and helping others"
        }
      },
      "completedAt": 1735689600000,
      "hasCompletedOnboarding": true
    }
  }
}
```

### Table: `analytics` (Optional)
Tracks user engagement and horoscope generation.

**Structure:**
```
analytics/
  ├── {userId}/
  │   ├── {autoId}/
  │   │   ├── action: String
  │   │   ├── timestamp: Timestamp
  │   │   └── data: Object
```

**Example Data:**
```json
{
  "analytics": {
    "abc123def456": {
      "autoId1": {
        "action": "horoscope_generated",
        "timestamp": 1735689600000,
        "data": {
          "type": "welcome",
          "success": true
        }
      },
      "autoId2": {
        "action": "horoscope_generated",
        "timestamp": 1735689600000,
        "data": {
          "type": "daily",
          "success": true
        }
      }
    }
  }
}
```

## Email Formatting

### Format Rules
The system automatically formats email addresses for database storage:

- **Periods (.)** → **Underscores (_)**
- **@ symbol** → **"_at_"**

### Examples
| Original Email | Formatted Email |
|----------------|-----------------|
| `test.user@testing.com` | `test_user_at_testing_com` |
| `john.doe@gmail.com` | `john_doe_at_gmail_com` |
| `user.name@company.co.uk` | `user_name_at_company_co_uk` |
| `admin@test.com` | `admin_at_test_com` |

### Benefits
- **Safe for Firebase keys** - No special characters that could cause issues
- **Searchable** - Can query by formatted email
- **Reversible** - Can convert back to original format
- **Original preserved** - Keeps the original email for reference

## Implementation Details

### FirebaseDatabaseService

The `FirebaseDatabaseService` class handles all Firebase Realtime Database operations:

```swift
@MainActor
class FirebaseDatabaseService: ObservableObject {
    private let database = Database.database(url: "https://zodiaccurate-e9aaf-default-rtdb.firebaseio.com")
    private let trialUsersRef: DatabaseReference
    private let onboardingRef: DatabaseReference
    
    init() {
        self.trialUsersRef = database.reference().child("trial_users")
        self.onboardingRef = database.reference().child("onboarding")
    }
}
```

### Key Methods

#### Trial Users Management
- `saveTrialUser(email:userId:profileUUID:)` - Saves new trial user (formats email)
- `updateTrialUserLastLogin(userId:)` - Updates last login timestamp
- `getTrialUser(userId:)` - Retrieves trial user data
- `isTrialUser(userId:)` - Checks if user exists in trial_users
- `getTrialStatus(userId:)` - Gets user's trial status
- `findTrialUserByFormattedEmail(_:)` - Find user by formatted email
- `findTrialUserByOriginalEmail(_:)` - Find user by original email

#### Onboarding Data Management
- `saveOnboardingData(userId:profileUUID:userData:)` - Saves onboarding data
- `getOnboardingData(userId:)` - Retrieves onboarding data
- `updateOnboardingData(userId:updates:)` - Updates onboarding data

#### Analytics
- `trackUserEngagement(userId:action:data:)` - Tracks user actions
- `trackHoroscopeGeneration(userId:horoscopeType:success:)` - Tracks horoscope generation

## Data Flow

### 1. User Registration
```swift
// AuthenticationManager.signUp()
1. Create Firebase Auth user
2. Generate profile UUID
3. Save to trial_users table
4. Store user ID locally for tracking
```

### 2. User Sign In
```swift
// AuthenticationManager.signIn()
1. Authenticate with Firebase Auth
2. Update lastLogin in trial_users table
3. Store user ID locally for tracking
```

### 3. Onboarding Completion
```swift
// ConversationalOnboardingView.saveOnboardingData()
1. Save data locally (SwiftData + UserDefaults)
2. Save to onboarding table in Firebase
3. Track completion analytics
```

### 4. Horoscope Generation
```swift
// OnboardingAI.generateWelcomeHoroscope() / generateDailyHoroscope()
1. Generate horoscope via ChatGPT API
2. Track generation in analytics table
3. Handle success/failure tracking
```

## Security Rules

### Recommended Firebase Security Rules

```json
{
  "rules": {
    "trial_users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "onboarding": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "analytics": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

## Error Handling

The service includes comprehensive error handling:

```swift
do {
    try await firebaseDatabaseService.saveTrialUser(
        email: email,
        userId: userId,
        profileUUID: profileUUID
    )
    print("✅ Trial user saved successfully")
} catch {
    print("❌ Error saving trial user: \(error.localizedDescription)")
    // Handle error appropriately
}
```

## Usage Examples

### Saving Trial User
```swift
let firebaseService = FirebaseDatabaseService()

try await firebaseService.saveTrialUser(
    email: "test.user@testing.com", // Will be formatted to "test_user_at_testing_com"
    userId: "abc123def456",
    profileUUID: "uuid-1234-5678-90ab"
)
```

### Saving Onboarding Data
```swift
let userData = UserData(
    firstName: "Sarah",
    birthDate: "March 15, 1990",
    birthTime: "2:30 PM",
    zodiacSign: "Pisces",
    responses: [
        ("How would you describe your intuition?", "intuition", "I have strong gut feelings"),
        ("What's your energy like?", "energy", "Calm and peaceful"),
        ("What do you dream about?", "dreams", "Water and nature")
    ]
)

try await firebaseService.saveOnboardingData(
    userId: "abc123def456",
    profileUUID: "uuid-1234-5678-90ab",
    userData: userData
)
```

### Finding Users by Email
```swift
// Find user by formatted email
if let userData = try await firebaseService.findTrialUserByFormattedEmail("test_user_at_testing_com") {
    print("Found user: \(userData)")
}

// Find user by original email
if let userData = try await firebaseService.findTrialUserByOriginalEmail("test.user@testing.com") {
    print("Found user: \(userData)")
}

// Reverse format email
let originalEmail = firebaseService.reverseEmailFormat("test_user_at_testing_com")
print("Original email: \(originalEmail)") // "test.user@testing.com"
```

### Tracking Analytics
```swift
// Track horoscope generation
await firebaseService.trackHoroscopeGeneration(
    userId: "abc123def456",
    horoscopeType: "welcome",
    success: true
)

// Track custom user engagement
await firebaseService.trackUserEngagement(
    userId: "abc123def456",
    action: "app_opened",
    data: ["source": "push_notification"]
)
```

## Monitoring and Analytics

### Key Metrics to Track

1. **Trial User Conversion**
   - Number of trial users created
   - Trial to paid conversion rate
   - Trial duration analysis

2. **Onboarding Completion**
   - Onboarding completion rate
   - Drop-off points in onboarding
   - Time to complete onboarding

3. **Horoscope Engagement**
   - Welcome horoscope generation success rate
   - Daily horoscope usage
   - User engagement patterns

### Firebase Console Monitoring

1. **Realtime Database** → Monitor data structure and usage
2. **Authentication** → Track user sign-ups and sign-ins
3. **Analytics** → View user engagement metrics
4. **Crashlytics** → Monitor app stability

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check Firebase configuration
   - Verify database URL
   - Check network connectivity

2. **Permission Denied**
   - Verify Firebase security rules
   - Check user authentication status
   - Ensure proper user ID usage

3. **Data Not Saving**
   - Check error logs
   - Verify data structure
   - Ensure proper async/await usage

### Debug Information

Enable debug logging by checking console output:
- Database operations and responses
- Error details and stack traces
- User ID and data validation

## Future Enhancements

### Planned Features

1. **Real-time Sync** - Sync data across devices
2. **Offline Support** - Queue operations when offline
3. **Data Migration** - Migrate from Firestore to Realtime Database
4. **Advanced Analytics** - More detailed user behavior tracking
5. **A/B Testing** - Test different onboarding flows

### Integration Opportunities

1. **Push Notifications** - Send personalized notifications
2. **Email Marketing** - Integrate with email services
3. **Customer Support** - Link user data to support tickets
4. **Subscription Management** - Track trial and subscription status

## Support

For issues or questions:

1. **Check Firebase Console** for database status
2. **Review security rules** for permission issues
3. **Check console logs** for detailed error information
4. **Verify data structure** matches expected format
5. **Test with Firebase CLI** for debugging

## License

This integration is part of the Zodiaccurate iOS app. Please ensure compliance with:
- Firebase terms of service
- Data privacy regulations (GDPR, CCPA)
- iOS App Store guidelines 