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

// MARK: - Chat Bubble Component
struct ChatBubble: View {
    let message: ChatMessage
    let onSizeChange: ((CGSize) -> Void)?
    
    init(message: ChatMessage, onSizeChange: ((CGSize) -> Void)? = nil) {
        self.message = message
        self.onSizeChange = onSizeChange
    }
    
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
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: BubbleSizePreferenceKey.self, value: geometry.size)
                                .onPreferenceChange(BubbleSizePreferenceKey.self) { size in
                                    onSizeChange?(size)
                                }
                        }
                    )
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
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 280, alignment: .leading)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: BubbleSizePreferenceKey.self, value: geometry.size)
                            .onPreferenceChange(BubbleSizePreferenceKey.self) { size in
                                onSizeChange?(size)
                            }
                    }
                )
                Spacer()
            }
        }
    }
}

// MARK: - Preference Key for Bubble Size
struct BubbleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

