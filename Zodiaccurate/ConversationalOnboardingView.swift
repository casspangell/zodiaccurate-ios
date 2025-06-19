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
    @State private var showInputField = false
    @State private var showSecondaryElements = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var headerHeight: CGFloat = 0
    var onComplete: () -> Void = {}
    
    // Calculate dynamic offsets
    private var scrollViewOffset: CGFloat {
        return headerHeight * 0.5 // Start midway behind the profile image
    }
    
    private var contentTopSpacing: CGFloat {
        return headerHeight * 1.0 // Push content below the profile image - increased for better positioning
    }
    
    private var contentTopPadding: CGFloat {
        return headerHeight * 0.67 // Overlap with profile image
    }
    
    var body: some View {
        ZStack {
            // Background layers
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header ZStack - positioned on top
                ZStack {
                    // Dark header background with gradient fade
                    VStack(spacing: 0) {
                        // Solid dark background for header content
                        Rectangle()
                            .fill(Color.deepBlue.opacity(1.0))
                            .frame(height: headerHeight - 180)
                        
                        // Enhanced gradient fade at bottom for beautiful melting effect
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.deepBlue.opacity(1.0), location: 0.0),
                                .init(color: Color.deepBlue.opacity(0.95), location: 0.1),
                                .init(color: Color.deepBlue.opacity(0.85), location: 0.25),
                                .init(color: Color.deepBlue.opacity(0.7), location: 0.4),
                                .init(color: Color.deepBlue.opacity(0.5), location: 0.55),
                                .init(color: Color.deepBlue.opacity(0.3), location: 0.7),
                                .init(color: Color.deepBlue.opacity(0.15), location: 0.85),
                                .init(color: Color.deepBlue.opacity(0.05), location: 0.95),
                                .init(color: Color.clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                    .allowsHitTesting(false)
                    
                    // Fixed Header
                    VStack(spacing: 8) {
                        // Logo with minimal glow
                        ZStack {
                            // Opaque translucent circle behind logo
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 130, height: 130)
                            
                            // Logo image
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 140, height: 140)
                        }
                        .frame(height: 150)
                        .padding(.top, 50)
                        
                        // Empty name label
                        Text("")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.clear)
                    .background(
                        GeometryReader { headerGeometry in
                            Color.clear
                                .preference(key: HeaderHeightPreferenceKey.self, value: headerGeometry.size.height)
                        }
                    )
                }
                .zIndex(2) // Ensure header stays on top
                
                // ScrollView ZStack - positioned underneath
                ZStack {
                    // Scrollable Chat Content
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                // Add spacing to push content below profile image
                                Spacer().frame(height: contentTopSpacing)
                                
                                // Chat Content
                                ChatContentView(
                                    messages: messages,
                                    currentStep: currentStep,
                                    conversationSteps: conversationSteps,
                                    showInteractivePicker: showInteractivePicker,
                                    showSecondaryElements: showSecondaryElements,
                                    selectedDate: $selectedDate,
                                    selectedTime: $selectedTime,
                                    isTyping: isTyping,
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
                                
                                // Input
                                ChatInputView(
                                    currentStep: currentStep,
                                    conversationSteps: conversationSteps,
                                    showInputField: showInputField,
                                    showSecondaryElements: showSecondaryElements,
                                    currentInput: $currentInput,
                                    onSend: { handleUserInput(input: currentInput) }
                                )
                                
                                // Complete Button
                                if (currentStep < conversationSteps.count && conversationSteps[currentStep].isFinal && messages.count > 0 && messages.last?.isUser == false) ||
                                   currentStep >= conversationSteps.count {
                                    Button(action: { onComplete() }) {
                                        HStack {
                                            Image(systemName: "sparkles")
                                            Text("Begin Your Journey")
                                            Image(systemName: "arrow.right")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.accentGold)
                                        .cornerRadius(12)
                                    }
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                }
                                
                                Spacer().frame(height: 20)
                            }
                            .padding(.horizontal)
                            .padding(.top, -contentTopPadding) // Move chat content up to overlap with profile image
                        }
                        .onChange(of: messages.count) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                        .onChange(of: showInteractivePicker) {
                            if showInteractivePicker {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: currentStep) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                        .onChange(of: isTyping) { oldValue, newValue in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("chatContent", anchor: .bottom)
                            }
                        }
                        .onChange(of: showInteractivePicker) { oldValue, newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo("chatContent", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: keyboardHeight) { oldValue, newValue in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("chatContent", anchor: .bottom)
                            }
                        }
                    }
                    .offset(y: -scrollViewOffset) // Move the entire ScrollView up to start midway behind the profile image
                }
                .zIndex(1) // ScrollView stays underneath
            }
        }
        .onAppear {
            startConversation()
        }
        .onPreferenceChange(HeaderHeightPreferenceKey.self) { headerHeight in
            // Store the header height for dynamic calculations
            self.headerHeight = headerHeight
        }
    }
    
    // Background View
    private struct BackgroundView: View {
        var body: some View {
            ZStack {
                // Cosmic background
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "1A0B2E"), location: 0.0),
                        .init(color: Color(hex: "0F051A"), location: 0.7),
                        .init(color: Color.black, location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()

                // Vignette overlay
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0.0), location: 0.6),
                        .init(color: Color.black.opacity(0.7), location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
                .blendMode(.multiply)
                .allowsHitTesting(false)

                // Celestial bodies
                GeometryReader { geo in
                    CelestialSystemBackground()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        .position(x: geo.size.width / 5, y: geo.size.height / 2)
                }

                // Orange overlay
                Color.backgroundPrimary.opacity(0.5)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func startConversation() {
        showInteractivePicker = false
        showInputField = false
        showSecondaryElements = false
        
        // Add initial message with typing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isTyping = false
                let aiMessage = ChatMessage(
                    text: conversationSteps[0].message,
                    isUser: false,
                    timestamp: Date()
                )
                withAnimation {
                    messages.append(aiMessage)
                }
                
                // Show input field or interactive picker after message appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showSecondaryElements = true
                        if conversationSteps[0].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[0].inputType == "date" || 
                                conversationSteps[0].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleUserInput(input: String) {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Hide interactive elements when user provides input
        showInteractivePicker = false
        showInputField = false
        showSecondaryElements = false
        
        // Add user message
        let userMessage = ChatMessage(
            text: input,
            isUser: true,
            timestamp: Date()
        )
        withAnimation {
            messages.append(userMessage)
        }
        
        // Store user data
        storeUserData(input: input, step: conversationSteps[currentStep])
        
        // Clear the text field after submission
        currentInput = ""
        
        // Move to next step
        currentStep += 1
        
        // Add AI response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentStep < conversationSteps.count {
                let nextMessage = conversationSteps[currentStep].message
                let personalizedMessage = personalizeMessage(nextMessage, with: userData.firstName)
                addAIMessage(personalizedMessage)
            }
        }
    }
    
    private func addAIMessage(_ text: String) {
        isTyping = true
        showInputField = false
        showInteractivePicker = false
        showSecondaryElements = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isTyping = false
            let aiMessage = ChatMessage(
                text: text,
                isUser: false,
                timestamp: Date()
            )
            withAnimation {
                messages.append(aiMessage)
            }
            
            // Show input field or interactive picker after message appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showSecondaryElements = true
                    if currentStep < conversationSteps.count {
                        if conversationSteps[currentStep].inputType == "text" {
                            showInputField = true
                        } else if conversationSteps[currentStep].inputType == "date" || 
                                conversationSteps[currentStep].inputType == "time" {
                            showInteractivePicker = true
                        }
                    }
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

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.bubbleFrost)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.purple)
                    
                    Text(message.text)
                        .padding()
                        .background(Color.bubbleSilver)
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
                    .foregroundColor(.accentGold)
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
                Image("logo")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.purple)
                Text("reading your energy...")
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
            
            if step.inputType == "date" {
                VStack(alignment: .trailing, spacing: 12) {
                    DatePicker(
                        "Birth Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
                    Button(action: {
                        onDateSelected(selectedDate)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGold)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.bubbleFrost.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
            } else if step.inputType == "time" {
                VStack(alignment: .trailing, spacing: 12) {
                    Text("Select your birth time")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: 280, alignment: .trailing)
                    
                    DatePicker(
                        "Birth Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
                    Button(action: {
                        onTimeSelected(selectedTime)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Submit")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGold)
                        .cornerRadius(12)
                    }
                    
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    
                    Button(action: {
                        onUnknownTime()
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("I don't know my birth time")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.sapphire.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
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

// Break out the chat content into a separate view
struct ChatContentView: View {
    let messages: [ChatMessage]
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInteractivePicker: Bool
    let showSecondaryElements: Bool
    let selectedDate: Binding<Date>
    let selectedTime: Binding<Date>
    let isTyping: Bool
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(messages) { message in
                ChatBubble(message: message)
                    .id(message.id)
                    .transition(.opacity)
            }
            
            if currentStep < conversationSteps.count && 
               !conversationSteps[currentStep].isFinal && 
               showInteractivePicker && showSecondaryElements {
                InteractivePickerView(
                    step: conversationSteps[currentStep],
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime
                )
            }
            
            if isTyping {
                TypingIndicator()
                    .transition(.opacity)
            }
            
            Color.clear
                .frame(height: 1)
                .id("bottom")
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: messages)
        .animation(.easeInOut(duration: 0.3), value: showSecondaryElements)
    }
}

// Break out the input section into a separate view
struct ChatInputView: View {
    let currentStep: Int
    let conversationSteps: [ConversationStep]
    let showInputField: Bool
    let showSecondaryElements: Bool
    let currentInput: Binding<String>
    let onSend: () -> Void
    
    var body: some View {
        if currentStep < conversationSteps.count && 
           !conversationSteps[currentStep].isFinal && 
           conversationSteps[currentStep].inputType == "text" &&
           showInputField && showSecondaryElements {
            InputSection(
                currentInput: currentInput,
                currentStep: conversationSteps[currentStep],
                onSend: onSend
            )
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.opacity)
        }
    }
}

#Preview {
    ConversationalOnboardingView()
}

// Preference key for header height
struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
