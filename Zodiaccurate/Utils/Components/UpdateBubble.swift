//
//  UpdateBubble.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/6/25.
//

import SwiftUI

struct UpdateBubble: View {
    let onSend: () -> Void
    @Binding var currentInput: String
    @FocusState var isTextFieldFocused: Bool
    let onFrameChange: (CGRect) -> Void
    @Binding var highlightInputField: Bool
    let onHeightChange: ((CGFloat) -> Void)?
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    
    init(currentInput: Binding<String>, onSend: @escaping () -> Void, onFrameChange: @escaping (CGRect) -> Void, highlightInputField: Binding<Bool>, onHeightChange: ((CGFloat) -> Void)? = nil, backgroundColor: Color? = nil, bubbleColor: ChatBubbleColor? = nil) {
        self._currentInput = currentInput
        self.onSend = onSend
        self.onFrameChange = onFrameChange
        self._highlightInputField = highlightInputField
        self.onHeightChange = onHeightChange
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
    }

    var body: some View {
        HStack(spacing: 0) {
            MultiLineTextField(
                text: $currentInput, placeholder: "",
                isFocused: $isTextFieldFocused,
                onSubmit: onSend,
                highlightInputField: $highlightInputField,
                onHeightChange: onHeightChange,
                backgroundColor: Color.white,
                textColor: .black
            )
            .onTapGesture {
                isTextFieldFocused = true
            }

            Spacer()
            SendButton(
                onSend: onSend,
                isEnabled: !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .clipShape(AnyShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio)))
        .onChange(of: currentInput) { _, newValue in
            print("Text changed: '\(newValue)'")
            if !newValue.isEmpty && currentInput.isEmpty {
                print("typing")
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        UpdateBubble(
            currentInput: .constant(""),
            onSend: {},
            onFrameChange: { _ in },
            highlightInputField: .constant(false),
            onHeightChange: nil,
            backgroundColor: Color.bubbleFrost,
            bubbleColor: .test
        )
        .padding()
        .background(Color.black)
    }
}

