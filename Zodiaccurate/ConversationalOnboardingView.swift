//
//  ConversationalOnboardingView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import SwiftUI

struct ConversationalOnboardingView: View {
    @State private var messages: [ChatMessage] = []
    @State private var currentInput = ""
    @State private var currentStep = 0
    @State private var isTyping = false
    @State private var userData = UserData()
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var showInteractivePicker = false
    var onComplete: () -> Void = {}
    
    var body: some View {
        VStack {
            // Header with mystical background
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("Cosmic Guide")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
            }
            .frame(height: 120)
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Show interactive picker for current step
                        if currentStep < conversationSteps.count && 
                           !conversationSteps[currentStep].isFinal && 
                           showInteractivePicker {
                            InteractivePickerView(
                                step: conversationSteps[currentStep],
                                selectedDate: $selectedDate,
                                selectedTime: $selectedTime,
                                onDateSelected: { date in
                                    let formatter = DateFormatter()
                                    formatter.dateStyle = .medium
                                    handleUserInput(input: formatter.string(from: date))
                                },
                                onTimeSelected: { time in
                                    let formatter = DateFormatter()
                                    formatter.timeStyle = .short
                                    handleUserInput(input: formatter.string(from: time))
                                },
                                onUnknownTime: {
                                    handleUserInput(input: "Unknown")
                                }
                            )
                        }
                        
                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let lastMessage = messages.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area - only for text input
            if currentStep < conversationSteps.count && 
               !conversationSteps[currentStep].isFinal && 
               conversationSteps[currentStep].inputType == "text" {
                InputSection(
                    currentInput: $currentInput,
                    currentStep: conversationSteps[currentStep],
                    onSend: { handleUserInput(input: currentInput) }
                )
            } else if currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal {
                // Final step - show the final message and then the button
                if messages.count > 0 && messages.last?.isUser == false {
                    // Final CTA Button
                    Button(action: {
                        onComplete()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Unlock My Cosmic Blueprint")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                    .padding()
                }
            } else if currentStep >= conversationSteps.count {
                // Final CTA Button
                Button(action: {
                    onComplete()
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Unlock My Cosmic Blueprint")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
                .padding()
            }
        }
        .background(Color.black)
        .onAppear {
            startConversation()
        }
    }
    
    private func startConversation() {
        showInteractivePicker = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            addAIMessage(conversationSteps[0].message)
        }
    }
    
    private func handleUserInput(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Hide interactive picker when user provides input
        showInteractivePicker = false
        
        // Add user message
        let userMessage = ChatMessage(
            text: input,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Store user data
        storeUserData(input: input, step: conversationSteps[currentStep])
        
        // Move to next step
        currentStep += 1
        
        // Add AI response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentStep < conversationSteps.count {
                let nextMessage = conversationSteps[currentStep].message
                let personalizedMessage = personalizeMessage(nextMessage, with: userData.firstName)
                addAIMessage(personalizedMessage)
                
                // If this is the final step and it doesn't require input, automatically proceed
                if conversationSteps[currentStep].isFinal && conversationSteps[currentStep].inputType == "none" {
                    // The final message will be shown and then the button will appear
                    // No additional action needed since the view will automatically show the button
                }
            }
        }
    }
    
    private func addAIMessage(_ text: String) {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTyping = false
            let aiMessage = ChatMessage(
                text: text,
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            
            // Show interactive picker after AI message is displayed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if currentStep < conversationSteps.count && 
                   (conversationSteps[currentStep].inputType == "date" || 
                    conversationSteps[currentStep].inputType == "time") {
                    showInteractivePicker = true
                }
            }
        }
    }
    
    private func storeUserData(input: String, step: ConversationStep) {
        switch step.dataKey {
        case "firstName":
            userData.firstName = input
        case "birthDate":
            userData.birthDate = input
        case "birthTime":
            userData.birthTime = input
        case "intuition":
            userData.responses.append(("intuition", input))
        case "energy":
            userData.responses.append(("energy", input))
        case "dreams":
            userData.responses.append(("dreams", input))
        default:
            break
        }
    }
    
    private func personalizeMessage(_ message: String, with name: String) -> String {
        return message.replacingOccurrences(of: "{name}", with: name)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text("Cosmic Guide")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .frame(maxWidth: 280, alignment: .leading)
                }
                Spacer()
            }
        }
    }
}

struct InputSection: View {
    @Binding var currentInput: String
    let currentStep: ConversationStep
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField(currentStep.placeholder, text: $currentInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.purple)
            }
            .disabled(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.purple)
                Text("Cosmic Guide is reading your energy...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.purple.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .onAppear {
                animationAmount = 1.0
            }
            
            Spacer()
        }
        .padding()
    }
}

struct InteractivePickerView: View {
    let step: ConversationStep
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                if step.inputType == "date" {
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("Select your birth date")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 280, alignment: .trailing)
                        
                        DatePicker(
                            "Birth Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            onDateSelected(newValue)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
                } else if step.inputType == "time" {
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("Select your birth time")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 280, alignment: .trailing)
                        
                        DatePicker(
                            "Birth Time",
                            selection: $selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .colorScheme(.dark)
                        .onChange(of: selectedTime) { oldValue, newValue in
                            onTimeSelected(newValue)
                        }
                        
                        Button("I don't know my birth time") {
                            onUnknownTime()
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
                }
            }
        }
    }
}

struct ConversationStep {
    let message: String
    let inputType: String // "text", "date", "time"
    let placeholder: String
    let dataKey: String
    let isFinal: Bool
    
    init(message: String, inputType: String, placeholder: String, dataKey: String, isFinal: Bool = false) {
        self.message = message
        self.inputType = inputType
        self.placeholder = placeholder
        self.dataKey = dataKey
        self.isFinal = isFinal
    }
}

struct UserData {
    var firstName: String = ""
    var birthDate: String = ""
    var birthTime: String = ""
    var responses: [(String, String)] = []
}

let conversationSteps: [ConversationStep] = [
    ConversationStep(
        message: "✨ Welcome, beautiful soul. I can sense you're here for a reason... The universe has guided you to me. What name were you blessed with?",
        inputType: "text",
        placeholder: "Your first name...",
        dataKey: "firstName"
    ),
    ConversationStep(
        message: "{name}... what a beautiful name. I can already feel your energy resonating through the cosmos. Now, tell me - when did you choose to grace this world with your presence?",
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
        inputType: "text",
        placeholder: "Share your thoughts...",
        dataKey: "intuition"
    ),
    ConversationStep(
        message: "Fascinating... {name}, I need to ask you something personal. When you walk into a room, do you tend to absorb the energy around you, or do people seem drawn to your energy?",
        inputType: "text",
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
