//
//  ChatBubble.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import SwiftUI

// MARK: - Chat Message Model
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

// MARK: - Question Chat Bubble Component
struct QuestionChatBubble: View {
    let message: ChatMessage
    let onSizeChange: ((CGSize) -> Void)?
    let onFrameChange: ((CGRect) -> Void)?
    
    init(message: ChatMessage, onSizeChange: ((CGSize) -> Void)? = nil, onFrameChange: ((CGRect) -> Void)? = nil) {
        self.message = message
        self.onSizeChange = onSizeChange
        self.onFrameChange = onFrameChange
    }
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .frame(maxWidth: 280, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.purple)
                    
                    Text(message.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: BubbleSizePreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(BubbleSizePreferenceKey.self) { size in
                        onSizeChange?(size)
                    }
                    .onAppear {
                        let frame = geometry.frame(in: .global)
                        onFrameChange?(frame)
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldFrame, newFrame in
                        // Only update if the frame has changed significantly (more than 1 point)
                        if abs(newFrame.minX - oldFrame.minX) > 1 || 
                           abs(newFrame.minY - oldFrame.minY) > 1 ||
                           abs(newFrame.width - oldFrame.width) > 1 ||
                           abs(newFrame.height - oldFrame.height) > 1 {
                            onFrameChange?(newFrame)
                        }
                    }
            }
        )
    }
}

// MARK: - Response Chat Bubble Component
struct ResponseChatBubble: View {
    let currentStep: ConversationStep
    @Binding var currentInput: String
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onSend: () -> Void
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    @FocusState var isTextFieldFocused: Bool
    let onFrameChange: (CGRect) -> Void
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
    
    init(currentStep: ConversationStep, currentInput: Binding<String>, selectedDate: Binding<Date>, selectedTime: Binding<Date>, onSend: @escaping () -> Void, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, onFrameChange: @escaping (CGRect) -> Void, highlightInputField: Binding<Bool>, onHeightChange: ((CGFloat) -> Void)? = nil) {
        self.currentStep = currentStep
        self._currentInput = currentInput
        self._selectedDate = selectedDate
        self._selectedTime = selectedTime
        self.onSend = onSend
        self.onDateSelected = onDateSelected
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.onFrameChange = onFrameChange
        self._highlightInputField = highlightInputField
        self.onHeightChange = onHeightChange
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Conditional input based on step type
            if currentStep.inputType == "text" {
                // Text input
                InputTextField(
                    text: $currentInput,
                    placeholder: currentStep.placeholder,
                    isFocused: $isTextFieldFocused,
                    onSubmit: onSend,
                    onTap: { isTextFieldFocused = true },
                    highlightInputField: $highlightInputField,
                    onHeightChange: onHeightChange
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                onFrameChange(geometry.frame(in: .global))
                            }
                    }
                )
                .onTapGesture {
                    isTextFieldFocused = true
                }
            } else if currentStep.inputType == "date" || currentStep.inputType == "time" {
                // Interactive picker
                InteractivePickerView(
                    step: currentStep,
                    selectedDate: $selectedDate,
                    selectedTime: $selectedTime,
                    onDateSelected: onDateSelected,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                onFrameChange(geometry.frame(in: .global))
                            }
                    }
                )
            }
            
            // Send button (only show for text input)
            if currentStep.inputType == "text" {
                Button(action: onSend) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accentGold)
                        .opacity(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .opacity(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 0.6)
                        )
                        .scaleEffect(currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, currentStep.inputType == "text" ? 16 : 0)
        .padding(.vertical, currentStep.inputType == "text" ? 12 : 0)
        .background(currentStep.inputType == "text" ? Color.purple : Color.clear)
        .cornerRadius(currentStep.inputType == "text" ? 20 : 0)
    }
}

// MARK: - Answered Chat Bubble Component
struct AnsweredChatBubble: View {
    let message: ChatMessage
    let onSizeChange: ((CGSize) -> Void)?
    let onFrameChange: ((CGRect) -> Void)?
    
    init(message: ChatMessage, onSizeChange: ((CGSize) -> Void)? = nil, onFrameChange: ((CGRect) -> Void)? = nil) {
        self.message = message
        self.onSizeChange = onSizeChange
        self.onFrameChange = onFrameChange
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 8)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: BubbleSizePreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(BubbleSizePreferenceKey.self) { size in
                        onSizeChange?(size)
                    }
                    .onAppear {
                        let frame = geometry.frame(in: .global)
                        onFrameChange?(frame)
                    }
                    .onChange(of: geometry.frame(in: .global)) { oldFrame, newFrame in
                        // Only update if the frame has changed significantly (more than 1 point)
                        if abs(newFrame.minX - oldFrame.minX) > 1 || 
                           abs(newFrame.minY - oldFrame.minY) > 1 ||
                           abs(newFrame.width - oldFrame.width) > 1 ||
                           abs(newFrame.height - oldFrame.height) > 1 {
                            onFrameChange?(newFrame)
                        }
                    }
            }
        )
    }
}

// MARK: - Preference Key for Bubble Size
struct BubbleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

