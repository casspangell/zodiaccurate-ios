//
//  WellnessSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import Foundation

// PERSONAL WELLNESS conversation flow
let wellnessConversationSteps: [ConversationStep] = [
    // 1. Overall health rating (single selection)
    ConversationStep(
        message: "How would you rate your overall health?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "overallHealth",
        options: [
            "Excellent",
            "Very Good",
            "Pretty Good",
            "Needs Some Improvement",
            "Needs A Lot of Improvement",
            "Poor"
        ]
    ),
    
    // 2. Physical health description
    ConversationStep(
        message: "Describe your current physical health.",
        inputType: "multiLine",
        placeholder: "(e.g., arthritis, low energy, pain, digestive issues, etc.)",
        dataKey: "physicalHealthDescription"
    ),
    
    // 3. Emotional imbalances
    ConversationStep(
        message: "Describe any emotional imbalances.",
        inputType: "multiLine",
        placeholder: "Describe your emotional landscape...",
        dataKey: "emotionalImbalances"
    ),
    
    // 4. Mental health challenges
    ConversationStep(
        message: "List any mental health challenges .",
        inputType: "multiLine",
        placeholder: "(e.g., negative thinking, trauma, serious conditions)",
        dataKey: "mentalHealthChallenges"
    ),
    
    // 5. Wellness goals
    ConversationStep(
        message: "What are your wellness goals?",
        inputType: "multiLine",
        placeholder: "(e.g., lose weight, gain strength, be more flexible)",
        dataKey: "wellnessGoals"
    ),
    
    // 6. Short or long-term goals or dreams
    ConversationStep(
        message: "List 3–5 short or long-term goals or dreams.",
        inputType: "multiLine",
        placeholder: "(e.g., start a business, travel to Japan, write a book, buy a home)",
        dataKey: "goalsAndDreams"
    ),
    
    // 7. Areas to improve
    ConversationStep(
        message: "List 3–5 areas of your life you want to improve.",
        inputType: "multiLine",
        placeholder: "(e.g., communication, career, finances, relationships, self-discipline)",
        dataKey: "areasToImprove"
    ),
    
    // 8. Sources of stress
    ConversationStep(
        message: "What are your top 3–5 sources of stress?",
        inputType: "multiLine",
        placeholder: "(e.g., work deadlines, finances, family conflict, health worries)",
        dataKey: "stressSources"
    ),
    
    // 9. Joy and satisfaction
    ConversationStep(
        message: "What brings you joy and satisfaction?",
        inputType: "multiLine",
        placeholder: "(e.g., time in nature, music, creating art, helping others)",
        dataKey: "joyAndSatisfaction"
    ),
    
    // 10. Family values or principles
    ConversationStep(
        message: "What family values or principles matter most to you?",
        inputType: "multiLine",
        placeholder: "(e.g., honesty, loyalty, compassion, faith, hard work)",
        dataKey: "familyValues"
    ),
    
    // 11. Sexual orientation (single selection)
    ConversationStep(
        message: "What is your sexual orientation?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "sexualOrientation",
        options: [
            "Not Interested",
            "Prefer Male",
            "Prefer Female",
            "Bisexual",
            "Asexual",
            "Pansexual",
            "Other"
        ]
    ),
    
    // 12. Belief system (single selection)
    ConversationStep(
        message: "What is your belief system? (If your beliefs influence your decisions, sharing them can help personalize your guidance.)",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "beliefSystem",
        isFinal: true,
        options: [
            "Christian",
            "Mormon",
            "Buddhist",
            "Islam",
            "Jewish",
            "Hindu",
            "Spiritual",
            "Atheist",
            "Agnostic",
            "Pagan",
            "Other"
        ],
    ),
    // 13. Final
    ConversationStep(
        message: "✨ The stars have witnessed your journey through wellness. Your Wellness profile is now complete, and the universe holds the wisdom to guide you toward your highest potential. The celestial energies are aligning in your favor. ✨",
        inputType: "none",
        placeholder: "none",
        dataKey: "final",
        isFinal: true
    )
]

