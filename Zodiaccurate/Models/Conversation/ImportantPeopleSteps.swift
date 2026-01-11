//
//  ImportantPeopleSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation

// IMPORTANT PEOPLE conversation flow
let importantPeopleConversationSteps: [ConversationStep] = [
    // 1. Family relationships
    ConversationStep(
        message: "How do you get along with your family?",
        inputType: "multiLine",
        placeholder: "(e.g., close, distant, supportive, challenging, etc.)",
        dataKey: "familyRelationships",
        aiStep: true
    ),
    
    // 2. Closest friends
    ConversationStep(
        message: "Who are the most important people in your life?",
        inputType: "multiLine",
        placeholder: "(e.g., best friends, mentors, colleagues, etc.)",
        dataKey: "closestFriends",
        aiStep: true
    ),
    
    // 3. Support system
    ConversationStep(
        message: "Who do you go to for help?",
        inputType: "multiLine",
        placeholder: "(e.g., specific people, types of relationships, etc.)",
        dataKey: "supportSystem",
        aiStep: true
    ),
    
    // 4. Mentors and role models
    ConversationStep(
        message: "Who do you look up to?",
        inputType: "multiLine",
        placeholder: "(e.g., teachers, bosses, family members, public figures, etc.)",
        dataKey: "mentorsAndRoleModels",
        aiStep: true
    ),
    
    // 5. Social circle
    ConversationStep(
        message: "Describe your friend group.",
        inputType: "multiLine",
        placeholder: "(e.g., large, small, diverse, close-knit, etc.)",
        dataKey: "socialCircle",
        aiStep: true
    ),
    
    // 6. People who inspire you
    ConversationStep(
        message: "Who inspires you?",
        inputType: "multiLine",
        placeholder: "(e.g., people you know personally or admire from afar)",
        dataKey: "peopleWhoInspire",
        aiStep: true
    ),
    
    // 7. Relationship dynamics
    ConversationStep(
        message: "How do your important relationships work?",
        inputType: "multiLine",
        placeholder: "(e.g., give and take, leadership, support, etc.)",
        dataKey: "relationshipDynamics",
        aiStep: true
    ),
    
    // 8. People you want to connect with
    ConversationStep(
        message: "Are there people you want to connect with?",
        inputType: "multiLine",
        placeholder: "(e.g., estranged family, old friends, new connections, etc.)",
        dataKey: "peopleToConnectWith",
        aiStep: true
    ),
    
    // 9. Impact on others
    ConversationStep(
        message: "How do you affect the important people in your life?",
        inputType: "multiLine",
        placeholder: "(e.g., supportive, challenging, inspiring, etc.)",
        dataKey: "impactOnOthers",
        aiStep: true
    ),
    
    // 10. Future relationships
    ConversationStep(
        message: "What relationships do you want in the future?",
        inputType: "multiLine",
        placeholder: "(e.g., deeper friendships, professional connections, community involvement, etc.)",
        dataKey: "futureRelationships",
        aiStep: true
    )
]
