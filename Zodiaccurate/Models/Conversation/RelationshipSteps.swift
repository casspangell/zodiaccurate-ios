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
        dataKey: "relationshipGoals",
        aiStep: true
    ),
    
    // 3. Communication style
    ConversationStep(
        message: "How do you communicate in relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., direct, emotional, reserved, expressive, etc.)",
        dataKey: "communicationStyle",
        aiStep: true
    ),
    
    // 4. Love language
    ConversationStep(
        message: "What's your love language?",
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
        dataKey: "relationshipChallenges",
        aiStep: true
    ),
    
    // 6. Past relationship experiences
    ConversationStep(
        message: "What have you learned from past relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., red flags to watch for, what you need, etc.)",
        dataKey: "pastRelationshipLessons",
        aiStep: true
    ),
    
    // 7. Partner qualities
    ConversationStep(
        message: "What do you look for in a partner?",
        inputType: "multiLine",
        placeholder: "(e.g., honesty, kindness, ambition, sense of humor, etc.)",
        dataKey: "importantPartnerQualities",
        aiStep: true
    ),
    
    // 8. Relationship values
    ConversationStep(
        message: "What values matter most in your relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., honesty, loyalty, growth, independence, etc.)",
        dataKey: "relationshipValues",
        aiStep: true
    ),
    
    // 9. Intimacy preferences
    ConversationStep(
        message: "How do you build closeness in relationships?",
        inputType: "multiLine",
        placeholder: "(e.g., deep conversations, shared activities, physical closeness, etc.)",
        dataKey: "intimacyPreferences",
        aiStep: true
    ),
    
    // 10. Future relationship vision
    ConversationStep(
        message: "What do you want in a relationship?",
        inputType: "multiLine",
        placeholder: "(e.g., partnership dynamics, shared goals, lifestyle, etc.)",
        dataKey: "futureRelationshipVision",
        aiStep: true
    )
]
