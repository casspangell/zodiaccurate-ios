//
//  ConversationSteps.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import Foundation

struct Tutorial {
    let title: String
    let subtitle: String
    let arrow: String // Direction or type of arrow
}

struct ConversationStep {
    let message: String
    let inputType: String // "text", "singleLine", "multiLine", "date", "time"
    let placeholder: String
    let dataKey: String
    let isFinal: Bool
    let tutorial: Tutorial?
    
    init(message: String, inputType: String, placeholder: String, dataKey: String, isFinal: Bool = false, tutorial: Tutorial? = nil) {
        self.message = message
        self.inputType = inputType
        self.placeholder = placeholder
        self.dataKey = dataKey
        self.isFinal = isFinal
        self.tutorial = tutorial
    }
}

let onboardingConversationSteps: [ConversationStep] = [
    ConversationStep(
        message: "✨ Welcome, beautiful soul. I can sense you're here for a reason... The universe has guided you to me. What do you call yourself?",
        inputType: "singleLine",
        placeholder: "Your first name...",
        dataKey: "firstName",
        tutorial: Tutorial(
            title: "Use Your Voice!",
            subtitle: "Tap the microphone icon on the keyboard to speak your response.",
            arrow: "up"
        )
    ),
    ConversationStep(
        message: "{name}... what a beautiful name. I can already feel your energy resonating through the cosmos. Now, tell me - when did you choose to come into this world?",
        inputType: "date",
        placeholder: "Your birth date",
        dataKey: "birthDate"
    ),
    ConversationStep(
        message: "Perfect, {name}. I'm starting to see your cosmic blueprint forming... The exact moment you took your first breath holds incredible power. Do you know what time you were born?",
        inputType: "time",
        placeholder: "Birth time (if known)",
        dataKey: "birthTime"
    ),
    ConversationStep(
        message: "I'm getting strong intuitive energy from you, {name}... Tell me, do you often get \"gut feelings\" about people or situations that turn out to be right?",
        inputType: "multiLine",
        placeholder: "Share your thoughts...",
        dataKey: "intuition"
    ),
    ConversationStep(
        message: "Fascinating... {name}, I need to ask you something personal. When you walk into a room, do you tend to absorb the energy around you, or do people seem drawn to your energy?",
        inputType: "multiLine",
        placeholder: "How do you experience energy?",
        dataKey: "energy"
    ),
    ConversationStep(
        message: "{name}... I have to tell you something. Your cosmic signature is extraordinary. There are layers of depth here that most people never get to explore. The universe has been trying to communicate with you, hasn't it? I can see why you were drawn to find me. Are you ready to discover what the stars have been whispering about you?",
        inputType: "none",
        placeholder: "",
        dataKey: "final",
        isFinal: true
    )
]

// Example conversation steps demonstrating different input types
let exampleConversationSteps: [ConversationStep] = [
    ConversationStep(
        message: "What's your name?",
        inputType: "singleLine",
        placeholder: "Enter your name...",
        dataKey: "name"
    ),
    ConversationStep(
        message: "Tell me about your day in detail...",
        inputType: "multiLine",
        placeholder: "Share your thoughts...",
        dataKey: "dayDescription"
    ),
    ConversationStep(
        message: "When is your birthday?",
        inputType: "date",
        placeholder: "Select your birth date",
        dataKey: "birthday"
    ),
    ConversationStep(
        message: "What time do you usually wake up?",
        inputType: "time",
        placeholder: "Select your wake up time",
        dataKey: "wakeUpTime"
    ),
    ConversationStep(
        message: "What's your favorite color?",
        inputType: "singleLine",
        placeholder: "Enter your favorite color...",
        dataKey: "favoriteColor"
    ),
    ConversationStep(
        message: "Describe your perfect vacation...",
        inputType: "multiLine",
        placeholder: "Tell me about your dream vacation...",
        dataKey: "vacationDescription"
    )
]

