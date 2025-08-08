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
        message: "How would you rate your overall health?\n- Excellent\n- Very Good\n- Pretty Good\n- Needs Some Improvement\n- Needs A Lot of Improvement\n- Poor",
        inputType: "singleLine",
        placeholder: "Type one option (e.g., Excellent, Pretty Good, Poor)",
        dataKey: "overallHealth"
    ),
    
    // 2. Physical health description
    ConversationStep(
        message: "Describe your current physical health (e.g., arthritis, low energy, pain, digestive issues, etc.).",
        inputType: "multiLine",
        placeholder: "Share details about your physical health...",
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
        message: "List any mental health challenges (e.g., negative thinking, trauma, serious conditions).",
        inputType: "multiLine",
        placeholder: "List your mental health challenges...",
        dataKey: "mentalHealthChallenges"
    ),
    
    // 5. Wellness goals
    ConversationStep(
        message: "What are your wellness goals (e.g., lose weight, gain strength, be more flexible)?",
        inputType: "multiLine",
        placeholder: "Describe your wellness goals...",
        dataKey: "wellnessGoals"
    ),
    
    // 6. Short or long-term goals or dreams
    ConversationStep(
        message: "List 3–5 short or long-term goals or dreams.",
        inputType: "multiLine",
        placeholder: "List 3–5 goals or dreams...",
        dataKey: "goalsAndDreams"
    ),
    
    // 7. Areas to improve
    ConversationStep(
        message: "List 3–5 areas of your life you want to improve.",
        inputType: "multiLine",
        placeholder: "List 3–5 areas to improve...",
        dataKey: "areasToImprove"
    ),
    
    // 8. Sources of stress
    ConversationStep(
        message: "What are your top 3–5 sources of stress?",
        inputType: "multiLine",
        placeholder: "List your top stressors...",
        dataKey: "stressSources"
    ),
    
    // 9. Joy and satisfaction
    ConversationStep(
        message: "What brings you joy and satisfaction?",
        inputType: "multiLine",
        placeholder: "Share what brings you joy...",
        dataKey: "joyAndSatisfaction"
    ),
    
    // 10. Family values or principles
    ConversationStep(
        message: "What family values or principles matter most to you?",
        inputType: "multiLine",
        placeholder: "Describe the values or principles that matter most...",
        dataKey: "familyValues"
    ),
    
    // 11. Sexual orientation (single selection)
    ConversationStep(
        message: "What is your sexual orientation?\n- Not Interested\n- Prefer Male\n- Prefer Female\n- Bisexual\n- Asexual\n- Pansexual\n- Other",
        inputType: "singleLine",
        placeholder: "Type one option (e.g., Prefer Female, Asexual)",
        dataKey: "sexualOrientation"
    ),
    
    // 12. Belief system (single selection)
    ConversationStep(
        message: "What is your belief system? (If your beliefs influence your decisions, sharing them can help personalize your guidance.)\n- Christian\n- Mormon\n- Buddhist\n- Islam\n- Jewish\n- Hindu\n- Spiritual\n- Atheist\n- Agnostic\n- Pagan\n- Other",
        inputType: "singleLine",
        placeholder: "Type one option (e.g., Spiritual, Agnostic)",
        dataKey: "beliefSystem"
    )
]

