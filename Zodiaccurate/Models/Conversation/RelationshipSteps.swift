//
//  RelationshipSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation

// RELATIONSHIP conversation flow
let relationshipConversationSteps: [ConversationStep] = [
    // 1. Current relationship status
    ConversationStep(
        message: "What's your current relationship status?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "relationshipStatus",
        options: [
            "Single",
            "In a Relationship",
            "Married",
            "Divorced",
            "Widowed",
            "It's Complicated"
        ]
    ),
    
    // 2. Relationship goals
    ConversationStep(
        message: "What are your relationship goals?",
        inputType: "multiLine",
        placeholder: "(e.g., find true love, improve communication, build trust, etc.)",
        dataKey: "relationshipGoals"
    ),
    
    // 3. Communication style
    ConversationStep(
        message: "How would you describe your communication style in relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., direct, emotional, reserved, expressive, etc.)",
        dataKey: "communicationStyle"
    ),
    
    // 4. Love language
    ConversationStep(
        message: "What's your primary love language?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "loveLanguage",
        options: [
            "Words of Affirmation",
            "Acts of Service",
            "Receiving Gifts",
            "Quality Time",
            "Physical Touch"
        ]
    ),
    
    // 5. Relationship challenges
    ConversationStep(
        message: "What are your biggest relationship challenges?",
        inputType: "multiLine",
        placeholder: "(e.g., trust issues, communication problems, time management, etc.)",
        dataKey: "relationshipChallenges"
    ),
    
    // 6. Past relationship experiences
    ConversationStep(
        message: "What have you learned from past relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., red flags to watch for, what you need, etc.)",
        dataKey: "pastRelationshipLessons"
    ),
    
    // 7. Partner qualities
    ConversationStep(
        message: "What qualities are most important to you in a partner?",
        inputType: "multiLine",
        placeholder: "(e.g., honesty, kindness, ambition, sense of humor, etc.)",
        dataKey: "importantPartnerQualities"
    ),
    
    // 8. Relationship values
    ConversationStep(
        message: "What values are most important in your relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., honesty, loyalty, growth, independence, etc.)",
        dataKey: "relationshipValues"
    ),
    
    // 9. Intimacy preferences
    ConversationStep(
        message: "How do you prefer to build intimacy in relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., deep conversations, shared activities, physical closeness, etc.)",
        dataKey: "intimacyPreferences"
    ),
    
    // 10. Future relationship vision
    ConversationStep(
        message: "What's your vision for your ideal relationship?",
        inputType: "multiLine",
        placeholder: "(e.g., partnership dynamics, shared goals, lifestyle, etc.)",
        dataKey: "futureRelationshipVision"
    )
]
