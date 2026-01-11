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
        message: "What do you do for work?",
        inputType: "multiLine",
        placeholder: "(e.g., technology, healthcare, education, finance, etc.)",
        dataKey: "careerField",
        aiStep: true
    ),
    
    // 4. Work environment
    ConversationStep(
        message: "Describe your work environment.",
        inputType: "multiLine",
        placeholder: "(e.g., collaborative, competitive, supportive, stressful, etc.)",
        dataKey: "workEnvironment",
        aiStep: true
    ),
    
    // 5. Career goals
    ConversationStep(
        message: "What are your career goals?",
        inputType: "multiLine",
        placeholder: "(e.g., promotion, career change, skill development, etc.)",
        dataKey: "careerGoals",
        aiStep: true
    ),
    
    // 6. Work-life balance
    ConversationStep(
        message: "How is your work-life balance?",
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
        message: "What are your biggest work challenges?",
        inputType: "multiLine",
        placeholder: "(e.g., skill gaps, workplace politics, advancement, etc.)",
        dataKey: "professionalChallenges",
        aiStep: true
    ),
    
    // 8. Skills and strengths
    ConversationStep(
        message: "What are your work strengths?",
        inputType: "multiLine",
        placeholder: "(e.g., leadership, technical skills, communication, etc.)",
        dataKey: "professionalStrengths",
        aiStep: true
    ),
    
    // 9. Professional development
    ConversationStep(
        message: "How do you improve your skills?",
        inputType: "multiLine",
        placeholder: "(e.g., training, certifications, networking, etc.)",
        dataKey: "professionalDevelopment",
        aiStep: true
    ),
    
    // 10. Future career vision
    ConversationStep(
        message: "What do you want for your career?",
        inputType: "multiLine",
        placeholder: "(e.g., dream job, business ownership, retirement plans, etc.)",
        dataKey: "futureCareerVision",
        aiStep: true
    )
]
