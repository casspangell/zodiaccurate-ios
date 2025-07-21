# Chat Bubble Color Customization

The chat bubble components now support custom background colors through two methods:
1. Direct `Color` values
2. Predefined `ChatBubbleColor` enum states

## ChatBubbleColor Enum

The `ChatBubbleColor` enum provides semantic color states:

```swift
enum ChatBubbleColor {
    case ready      // Color.bubblePearl - Pearl cream, very subtle
    case submitted  // Color.bubbleWarm - Warm peach, translucent  
    case active     // Color.bubbleCool - Cool blue, translucent
}
```

## Automatic Semantic Coloring in ZodiacChatView

When using `ZodiacChatView`, the component automatically applies appropriate colors to different bubble types:

- **AI Questions** → `.ready` (Color.bubblePearl) - Pearl cream, very subtle
- **User Responses** → `.submitted` (Color.bubbleWarm) - Warm peach, translucent
- **Input Fields** → `.active` (Color.bubbleCool) - Cool blue, translucent

If you provide a specific `bubbleColor`, it will override these defaults for all bubble types.

## Available Colors

The app includes several predefined bubble colors in `Colors.swift`:

- `Color.bubbleLight` - Light sky blue, very translucent
- `Color.bubbleMedium` - Light lavender, medium translucent  
- `Color.bubbleWarm` - Warm peach, translucent
- `Color.bubbleCool` - Cool blue, translucent
- `Color.bubblePearl` - Pearl cream, very subtle (default)
- `Color.bubbleMist` - Mist pink, very light
- `Color.bubbleFrost` - Frost blue, minimal opacity
- `Color.bubbleSilver` - Silver lavender, slightly more opaque

## Usage Examples

### 1. Using ZodiacChatView with Automatic Semantic Colors (Recommended)

```swift
// Uses automatic semantic coloring
ZodiacChatView(
    conversationSteps: conversationSteps,
    profileImage: "logo",
    userName: $userName,
    onUserDataUpdate: { input, step in
        // Handle user data updates
    },
    onStepComplete: { step in
        // Handle step completion
    },
    onConversationComplete: {
        // Handle conversation completion
    },
    personalizeMessage: { message, name in
        return message.replacingOccurrences(of: "{name}", with: name)
    },
    determineZodiacSign: { dateString in
        return determineZodiacSign(from: dateString)
    },
    triggerBadgeAnimation: { assetName in
        // Handle badge animation
    },
    badgeAnimationManager: badgeAnimationManager
    // No bubbleColor specified - uses automatic semantic colors
)
```

### 2. Using ZodiacChatView with Custom Enum Color

```swift
// Overrides all bubble types with the specified color
ZodiacChatView(
    // ... other parameters ...
    bubbleColor: .active // All bubbles will use .active color
)
```

### 3. Using ConversationalOnboardingView with Enum

```swift
ConversationalOnboardingView(
    onComplete: {
        // Handle completion
    },
    bubbleColor: .submitted // Using enum
)
```

### 4. Using Individual Chat Bubble Components with Enum

```swift
// Question bubble with enum
QuestionChatBubble(
    message: chatMessage,
    bubbleColor: .ready
)

// Response bubble with enum
ResponseChatBubble(
    currentStep: conversationStep,
    currentInput: $input,
    selectedDate: $date,
    selectedTime: $time,
    onSend: { /* handle send */ },
    onDateSelected: { date in /* handle date */ },
    onTimeSelected: { time in /* handle time */ },
    onUnknownTime: { /* handle unknown time */ },
    onFrameChange: { frame in /* handle frame change */ },
    highlightInputField: $highlightField,
    bubbleColor: .active // Using enum
)

// Answered bubble with enum
AnsweredChatBubble(
    message: chatMessage,
    bubbleColor: .submitted
)
```

### 5. Using Direct Color Values (Legacy)

```swift
// Using predefined colors
backgroundColor: Color.bubbleCool

// Using system colors
backgroundColor: Color.blue.opacity(0.2)

// Using hex colors
backgroundColor: Color(hex: "#FF6B6B").opacity(0.15)

// Using custom colors
backgroundColor: Color.purple.opacity(0.1)
```

### 6. Priority System

When both `backgroundColor` and `bubbleColor` are provided, `backgroundColor` takes precedence:

```swift
QuestionChatBubble(
    message: chatMessage,
    backgroundColor: Color.red.opacity(0.2), // This will be used
    bubbleColor: .ready // This will be ignored
)
```

## Default Behavior

### ZodiacChatView Automatic Colors
- **AI Questions**: `Color.bubblePearl` (ready state)
- **User Responses**: `Color.bubbleWarm` (submitted state)
- **Input Fields**: `Color.bubbleCool` (active state)

### Individual Components (when no colors specified)
- `QuestionChatBubble`: `Color.bubblePearl`
- `ResponseChatBubble`: `Color.bubbleFrost`  
- `AnsweredChatBubble`: `Color.bubbleWarm`

## Semantic Usage

The `ChatBubbleColor` enum provides semantic meaning:

- **`.ready`** - For questions or prompts waiting for user input
- **`.submitted`** - For user responses that have been sent
- **`.active`** - For active input fields or current interactions

## Notes

- The `backgroundColor` and `bubbleColor` parameters are both optional
- When both are `nil`, the default colors are used
- `backgroundColor` takes precedence over `bubbleColor` when both are provided
- ZodiacChatView automatically applies semantic colors when no `bubbleColor` is specified
- All bubble colors are designed to be translucent for a subtle effect
- The text color remains white for good contrast against the bubble backgrounds 