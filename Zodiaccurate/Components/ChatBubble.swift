//
//  ChatBubble.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/18/25.
//

import SwiftUI

// MARK: - Chat Bubble Color Enum
enum ChatBubbleColor {
    case submitted
    case active
    case test
    case clear
    
    var color: Color {
        switch self {
        case .submitted:
            return Color.bubbleWarm
        case .active:
            return Color.bubbleCool
        case .test:
            return Color.yellow
        case .clear:
            return Color.clear
        }
    }
}

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

// MARK: - Chat Bubble Height Tracker
class ChatBubbleHeightTracker: ObservableObject {
    @Published var lastResponseBubbleHeight: CGFloat = 0
    
    static let shared = ChatBubbleHeightTracker()
    
    private init() {}
    
    func updateLastResponseBubbleHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            self.lastResponseBubbleHeight = height
        }
    }
    
    func getLastResponseBubbleHeight() -> CGFloat {
        return lastResponseBubbleHeight
    }
    
    // MARK: - Convenience Methods
    /// Returns the height of the last response chat bubble that was added
    /// - Returns: The height in points, or 0 if no response bubble has been added yet
    static func getLastResponseBubbleHeight() -> CGFloat {
        return shared.lastResponseBubbleHeight
    }
    
    /// Resets the last response bubble height to 0
    static func resetLastResponseBubbleHeight() {
        shared.updateLastResponseBubbleHeight(0)
    }
}

// MARK: - Question Chat Bubble Component
struct QuestionChatBubble: View {
    let message: ChatMessage
    let onSizeChange: ((CGSize) -> Void)?
    let onFrameChange: ((CGRect) -> Void)?
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    var textColor: Color?
    var bubbleOpacity: Double = 1
    var logoOpacity: Double = 1
    
    init(message: ChatMessage, onSizeChange: ((CGSize) -> Void)? = nil, onFrameChange: ((CGRect) -> Void)? = nil, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil, textColor: Color? = nil, bubbleOpacity: Double = 1, logoOpacity: Double = 1) {
        self.message = message
        self.onSizeChange = onSizeChange
        self.onFrameChange = onFrameChange
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
        self.textColor = textColor
        self.bubbleOpacity = bubbleOpacity
        self.logoOpacity = logoOpacity
    }
    
    private var finalBackgroundColor: Color {
        if let backgroundColor = backgroundColor {
            return backgroundColor
        } else if let bubbleColor = bubbleColor {
            return bubbleColor.color
        } else {
            return Color.bubblePearl
        }
    }

    private var finalTextColor: Color {
        if bubbleColor == ChatBubbleColor.submitted {
            return Color.white.opacity(0.5)
        } else {
            return Color.white
        }
    }

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(finalBackgroundColor)
                    .foregroundColor(finalTextColor)
                    .cornerRadius(bubbleCornerRadius)
                    .frame(maxWidth: 280, alignment: .trailing)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.purple)
                        .opacity(logoOpacity)
                    
                    Text(message.text)
                        .padding()
                        .background(finalBackgroundColor)
                        .foregroundColor(finalTextColor)
                        .cornerRadius(bubbleCornerRadius)
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
        .opacity(bubbleOpacity)
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
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    @State private var singleChoiceSelection: String? = nil
    @State private var multiChoiceSelections: Set<String> = []
    
    init(currentStep: ConversationStep, currentInput: Binding<String>, selectedDate: Binding<Date>, selectedTime: Binding<Date>, onSend: @escaping () -> Void, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, onFrameChange: @escaping (CGRect) -> Void, highlightInputField: Binding<Bool>, onHeightChange: ((CGFloat) -> Void)? = nil, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil) {
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
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
    }
    
    private var finalBackgroundColor: Color {
        if let backgroundColor = backgroundColor {
            return backgroundColor
        } else if let bubbleColor = bubbleColor {
            return bubbleColor.color
        } else {
            return Color.bubbleFrost
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                // Conditional input based on step type
                if currentStep.inputType == "text" || currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine" {
                    // Text input - choose appropriate component
                    if currentStep.inputType == "singleLine" {
                        SingleLineTextField(
                            text: $currentInput,
                            placeholder: currentStep.placeholder,
                            isFocused: $isTextFieldFocused,
                            onSubmit: onSend,
                            highlightInputField: $highlightInputField,
                            onHeightChange: onHeightChange
                        )
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
                    } else { //if currentStep.inputType == "multiLine"
                        MultiLineTextField(
                            text: $currentInput,
                            placeholder: currentStep.placeholder,
                            isFocused: $isTextFieldFocused,
                            onSubmit: onSend,
                            highlightInputField: $highlightInputField,
                            onHeightChange: onHeightChange
                        )
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
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
                } else if currentStep.inputType == "singlechoice" {
                    // Single choice radio button picker
                    RadioButtonPicker(
                        title: nil,
                        options: currentStep.options ?? [],
                        selected: $singleChoiceSelection,
                        onSelect: { newValue in
                            currentInput = newValue ?? ""
                        },
                        showSubmitButton: true,
                        submitTitle: "Submit",
                        onSubmit: {
                            onSend()
                        }
                    )
                    .onAppear {
                        if !currentInput.isEmpty {
                            singleChoiceSelection = currentInput
                        }
                    }
                } else if currentStep.inputType == "multichoice" {
                    // Multi choice checkbox picker
                    CheckboxMultiPicker(
                        title: nil,
                        options: currentStep.options ?? [],
                        selections: $multiChoiceSelections,
                        maxSelections: nil,
                        onChange: { newSelections in
                            currentInput = Array(newSelections).sorted().joined(separator: ", ")
                        },
                        showSubmitButton: true,
                        submitTitle: "Submit",
                        onSubmit: {
                            onSend()
                        }
                    )
                    .onAppear {
                        if !currentInput.isEmpty {
                            let parts = currentInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            multiChoiceSelections = Set(parts)
                        }
                    }
                }
                
                // Send button (only show for text input types)
                if currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine" {
                    Spacer()
                    SendButton(
                        onSend: onSend,
                        isEnabled: !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
            .padding(.horizontal, (currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine" || currentStep.inputType == "date" || currentStep.inputType == "time" || currentStep.inputType == "singlechoice" || currentStep.inputType == "multichoice") ? 16 : 0)
            .padding(.vertical, (currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine") ? 12 : 0)
            .background((currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine" || currentStep.inputType == "date" || currentStep.inputType == "time" || currentStep.inputType == "singlechoice" || currentStep.inputType == "multichoice") ? finalBackgroundColor : Color.clear)
            .clipShape(
                (currentStep.inputType == "singleLine" || currentStep.inputType == "multiLine" || currentStep.inputType == "date" || currentStep.inputType == "time" || currentStep.inputType == "singlechoice" || currentStep.inputType == "multichoice")
                    ? AnyShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))
                    : AnyShape(Rectangle())
            )
        }
    }
}

// MARK: - Answered Chat Bubble Component
struct AnsweredChatBubble: View {
    let message: ChatMessage
    let onSizeChange: ((CGSize) -> Void)?
    let onFrameChange: ((CGRect) -> Void)?
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    var bubbleOpacity: Double = 1
    @StateObject private var heightTracker = ChatBubbleHeightTracker.shared
    
    init(message: ChatMessage, onSizeChange: ((CGSize) -> Void)? = nil, onFrameChange: ((CGRect) -> Void)? = nil, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil, bubbleOpacity: Double = 1) {
        self.message = message
        self.onSizeChange = onSizeChange
        self.onFrameChange = onFrameChange
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
        self.bubbleOpacity = bubbleOpacity
    }
    
    private var finalBackgroundColor: Color {
        if let backgroundColor = backgroundColor {
            return backgroundColor
        } else if let bubbleColor = bubbleColor {
            return bubbleColor.color
        } else {
            return Color.bubbleWarm
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .padding()
                .background(finalBackgroundColor)
                .foregroundColor(Color.white.opacity(0.5))
                .clipShape(AnyShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)))
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
                        // Track the height of this response bubble
                        heightTracker.updateLastResponseBubbleHeight(size.height)
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
        .opacity(bubbleOpacity)
    }
}

// MARK: - Preference Key for Bubble Size
struct BubbleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Custom Bubble Shape for Asymmetric Corner Radii
struct CustomBubbleShape: Shape {
    var radius: CGFloat = 20
    var topRightRatio: CGFloat = 1.0
    var topLeftRatio: CGFloat = 1.0

    func path(in rect: CGRect) -> Path {
        let tr = radius * topRightRatio
        let tl = radius * topLeftRatio
        let bl = radius
        let br = radius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        return path
    }
}

#if DEBUG
import SwiftUI

#Preview {
    VStack(spacing: 24) {
        // QuestionChatBubble (user and system)
        QuestionChatBubble(
            message: ChatMessage(text: "What's your name?", isUser: true, timestamp: Date()),
            onSizeChange: nil,
            onFrameChange: nil,
            backgroundColor: .blue,
            bubbleColor: .active
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Question (User)")

        QuestionChatBubble(
            message: ChatMessage(text: "What brings you here today?", isUser: false, timestamp: Date()),
            onSizeChange: nil,
            onFrameChange: nil,
            backgroundColor: .purple,
            bubbleColor: .submitted
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Question (System)")

        // AnsweredChatBubble
        AnsweredChatBubble(
            message: ChatMessage(text: "My name is Cass!", isUser: true, timestamp: Date()),
            onSizeChange: nil,
            onFrameChange: nil,
            backgroundColor: .green,
            bubbleColor: .test
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Answered")

        // ResponseChatBubble (singleLine input)
        ResponseChatBubble(
            currentStep: exampleConversationSteps[0],
            currentInput: .constant(""),
            selectedDate: .constant(Date()),
            selectedTime: .constant(Date()),
            onSend: {},
            onDateSelected: { _ in },
            onTimeSelected: { _ in },
            onUnknownTime: {},
            onFrameChange: { _ in },
            highlightInputField: .constant(false),
            onHeightChange: nil,
            backgroundColor: Color.bubbleFrost,
            bubbleColor: .active
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Response (SingleLine)")

        // ResponseChatBubble (multiLine input)
        ResponseChatBubble(
            currentStep: exampleConversationSteps[1],
            currentInput: .constant(""),
            selectedDate: .constant(Date()),
            selectedTime: .constant(Date()),
            onSend: {},
            onDateSelected: { _ in },
            onTimeSelected: { _ in },
            onUnknownTime: {},
            onFrameChange: { _ in },
            highlightInputField: .constant(false),
            onHeightChange: nil,
            backgroundColor: Color.bubbleFrost,
            bubbleColor: .active
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Response (MultiLine)")

        // ResponseChatBubble (date input)
        ResponseChatBubble(
            currentStep: exampleConversationSteps[2],
            currentInput: .constant(""),
            selectedDate: .constant(Date()),
            selectedTime: .constant(Date()),
            onSend: {},
            onDateSelected: { _ in },
            onTimeSelected: { _ in },
            onUnknownTime: {},
            onFrameChange: { _ in },
            highlightInputField: .constant(false),
            onHeightChange: nil,
            backgroundColor: Color.bubbleFrost,
            bubbleColor: .active
        )
        .padding()
        .background(Color.black)
        .previewDisplayName("Response (Date)")
    }
    .padding()
    .background(Color.black)
}
#endif

