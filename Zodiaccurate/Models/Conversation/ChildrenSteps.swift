//
//  ChildrenSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation

// CHILDREN conversation flow
let childrenConversationSteps: [ConversationStep] = [
    // 1. Current children status
    ConversationStep(
        message: "Do you have children?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "childrenStatus",
        options: [
            "Yes, I have children",
            "No, I don't have children",
            "I'm expecting",
            "I'm trying to conceive",
            "I'm not sure if I want children",
            "I can't have children"
        ]
    ),
    
    // 2. Parenting experience
    ConversationStep(
        message: "How would you describe your parenting experience?",
        inputType: "multiLine",
        placeholder: "(e.g., rewarding, challenging, learning, etc.)",
        dataKey: "parentingExperience",
        aiStep: true
    ),
    
    // 3. Parenting style
    ConversationStep(
        message: "What's your parenting style?",
        inputType: "multiLine",
        placeholder: "(e.g., authoritative, permissive, attachment, etc.)",
        dataKey: "parentingStyle",
        aiStep: true
    ),
    
    // 4. Parenting challenges
    ConversationStep(
        message: "What are your biggest parenting challenges?",
        inputType: "multiLine",
        placeholder: "(e.g., discipline, communication, time management, etc.)",
        dataKey: "parentingChallenges",
        aiStep: true
    ),
    
    // 5. Parenting goals
    ConversationStep(
        message: "What are your goals as a parent?",
        inputType: "multiLine",
        placeholder: "(e.g., raise confident kids, teach values, etc.)",
        dataKey: "parentingGoals",
        aiStep: true
    ),
    
    // 6. Family dynamics
    ConversationStep(
        message: "How would you describe your family dynamics?",
        inputType: "multiLine",
        placeholder: "(e.g., close, busy, structured, etc.)",
        dataKey: "familyDynamics",
        aiStep: true
    ),
    
    // 7. Work-life balance
    ConversationStep(
        message: "How do you balance work and family life?",
        inputType: "multiLine",
        placeholder: "(e.g., flexible schedule, childcare, support system, etc.)",
        dataKey: "workLifeBalance",
        aiStep: true
    ),
    
    // 8. Values you want to pass on
    ConversationStep(
        message: "What values do you want to pass on to your children?",
        inputType: "multiLine",
        placeholder: "(e.g., kindness, hard work, curiosity, etc.)",
        dataKey: "valuesToPassOn",
        aiStep: true
    ),
    
    // 9. Support system
    ConversationStep(
        message: "Who supports you in your parenting journey?",
        inputType: "multiLine",
        placeholder: "(e.g., partner, family, friends, community, etc.)",
        dataKey: "parentingSupport",
        aiStep: true
    ),
    
    // 10. Future family vision
    ConversationStep(
        message: "What's your vision for your family's future?",
        inputType: "multiLine",
        placeholder: "(e.g., family traditions, goals, relationships, etc.)",
        dataKey: "futureFamilyVision",
        aiStep: true
    )
]
