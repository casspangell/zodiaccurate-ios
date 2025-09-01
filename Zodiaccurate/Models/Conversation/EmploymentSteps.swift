//
//  EmploymentSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation

// EMPLOYMENT conversation flow
let employmentConversationSteps: [ConversationStep] = [
    // 1. Current employment status
    ConversationStep(
        message: "What's your current employment status?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "employmentStatus",
        options: [
            "Full-time employed",
            "Part-time employed",
            "Self-employed",
            "Freelancer/Contractor",
            "Unemployed",
            "Student",
            "Retired",
            "Stay-at-home parent"
        ]
    ),
    
    // 2. Current job satisfaction
    ConversationStep(
        message: "How satisfied are you with your current job?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "jobSatisfaction",
        options: [
            "Very Satisfied",
            "Satisfied",
            "Neutral",
            "Dissatisfied",
            "Very Dissatisfied"
        ]
    ),
    
    // 3. Career field
    ConversationStep(
        message: "What field or industry do you work in?",
        inputType: "multiLine",
        placeholder: "(e.g., technology, healthcare, education, finance, etc.)",
        dataKey: "careerField"
    ),
    
    // 4. Work environment
    ConversationStep(
        message: "How would you describe your work environment?",
        inputType: "multiLine",
        placeholder: "(e.g., collaborative, competitive, supportive, stressful, etc.)",
        dataKey: "workEnvironment"
    ),
    
    // 5. Career goals
    ConversationStep(
        message: "What are your career goals?",
        inputType: "multiLine",
        placeholder: "(e.g., promotion, career change, skill development, etc.)",
        dataKey: "careerGoals"
    ),
    
    // 6. Work-life balance
    ConversationStep(
        message: "How would you rate your work-life balance?",
        inputType: "singlechoice",
        placeholder: "Select one option",
        dataKey: "workLifeBalance",
        options: [
            "Excellent",
            "Good",
            "Fair",
            "Poor",
            "Very Poor"
        ]
    ),
    
    // 7. Professional challenges
    ConversationStep(
        message: "What are your biggest professional challenges?",
        inputType: "multiLine",
        placeholder: "(e.g., skill gaps, workplace politics, advancement, etc.)",
        dataKey: "professionalChallenges"
    ),
    
    // 8. Skills and strengths
    ConversationStep(
        message: "What are your professional strengths and skills?",
        inputType: "multiLine",
        placeholder: "(e.g., leadership, technical skills, communication, etc.)",
        dataKey: "professionalStrengths"
    ),
    
    // 9. Professional development
    ConversationStep(
        message: "How do you pursue professional development?",
        inputType: "multiLine",
        placeholder: "(e.g., training, certifications, networking, etc.)",
        dataKey: "professionalDevelopment"
    ),
    
    // 10. Future career vision
    ConversationStep(
        message: "What's your vision for your professional future?",
        inputType: "multiLine",
        placeholder: "(e.g., dream job, business ownership, retirement plans, etc.)",
        dataKey: "futureCareerVision"
    )
]
