//
//  ConversationView.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import SwiftUI

/// A reusable conversation view identical to onboarding, but driven by injected steps and save handlers
struct ConversationView: View {
    // MARK: - Configuration
    let conversationSteps: [ConversationStep]
    let profileImage: String
    @Binding var displayName: String
    let onResponse: (String, ConversationStep) -> Void
    let onStepComplete: (Int) -> Void
    let onComplete: () -> Void
    let triggerBadgeAnimation: (String) -> Void
    let backgroundColor: Color?
    let bubbleColor: ChatBubbleColor?
    let topInsetMode: ChatTopInsetMode
    let questionCategory: QuestionMenuButton?
    
    // MARK: - Internal user placeholder (required by ZodiacChatView for personalization/GPT hooks)
    @State private var placeholderUser = User()
    
    // MARK: - Progress Tracking
    @State private var currentStepIndex: Int = 0
    
    // MARK: - Computed Properties
    private var categoryDisplayText: String? {
        if let category = questionCategory {
            switch category {
            case .wellness:
                return "Wellness"
            case .relationship:
                return "Relationship"
            case .importantPeople:
                return "Important People"
            case .children:
                return "Children"
            case .employment:
                return "Employment"
            case .none:
                return "Questions"
            }
        } else {
            // Default to "Questions" for compact display mode
            return "Questions"
        }
    }
    
    private var topicString: String {
        guard let category = questionCategory else { return "" }
        return ConversationProgressManager.topicFromQuestionMenuButton(category)
    }
    
    init(
        conversationSteps: [ConversationStep],
        profileImage: String = "logo",
        displayName: Binding<String> = .constant(""),
        onResponse: @escaping (String, ConversationStep) -> Void,
        onStepComplete: @escaping (Int) -> Void = { _ in },
        onComplete: @escaping () -> Void = {},
        triggerBadgeAnimation: @escaping (String) -> Void = { _ in },
        backgroundColor: Color? = nil,
        bubbleColor: ChatBubbleColor? = nil,
        topInsetMode: ChatTopInsetMode = .large,
        questionCategory: QuestionMenuButton? = nil
    ) {
        self.conversationSteps = conversationSteps
        self.profileImage = profileImage
        self._displayName = displayName
        self.onResponse = onResponse
        self.onStepComplete = onStepComplete
        self.onComplete = onComplete
        self.triggerBadgeAnimation = triggerBadgeAnimation
        self.backgroundColor = backgroundColor
        self.bubbleColor = bubbleColor
        self.topInsetMode = topInsetMode
        self.questionCategory = questionCategory
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ZodiacChatView(
                conversationSteps: conversationSteps,
                profileImage: profileImage,
                userName: $displayName,
                userData: placeholderUser,
                onUserDataUpdate: { input, step in
                    onResponse(input, step)
                },
                onStepComplete: { idx in
                    currentStepIndex = idx
                    onStepComplete(idx)
                    
                    // Save progress after each step completion
                    if !topicString.isEmpty {
                        ConversationProgressManager.saveProgress(step: idx, for: topicString)
                    }
                },
                onConversationComplete: {
                    // Save final progress before completing
                    if !topicString.isEmpty {
                        ConversationProgressManager.saveProgress(step: conversationSteps.count - 1, for: topicString)
                    }
                    onComplete()
                },
                personalizeMessage: { message, name in
                    personalizeMessage(message, with: name)
                },
                determineZodiacSign: { dateString in
                    determineZodiacSign(from: dateString)
                },
                triggerBadgeAnimation: triggerBadgeAnimation,
                backgroundColor: backgroundColor,
                bubbleColor: bubbleColor,
                topInsetMode: topInsetMode,
                currentStepIndex: $currentStepIndex
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ZodiacHeader(
                profileImage: profileImage,
                displayMode: .compact,
                centeredLabel: categoryDisplayText
            )
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Fresh placeholder user to scope this conversation session (not persisted)
            placeholderUser = User(createdAt: Date(), updatedAt: Date())
            
            // Debug logging for questionCategory and topicString
            let categoryString = questionCategory.map { category in
                switch category {
                case .wellness: return "wellness"
                case .relationship: return "relationship"
                case .importantPeople: return "importantPeople"
                case .children: return "children"
                case .employment: return "employment"
                case .none: return "none"
                }
            } ?? "nil"
            print("🔍 ConversationView: questionCategory = \(categoryString)")
            print("🔍 ConversationView: topicString = '\(topicString)'")
            
            // Check the current step on load
            if !topicString.isEmpty {
                // Load existing progress for this topic
                currentStepIndex = ConversationProgressManager.getProgress(for: topicString)
                
                // Default to step 1 if no progress found
                if currentStepIndex == 0 {
                    currentStepIndex = 0 // This represents step 1 (0-based index)
                    print("📱 ConversationView: Starting at default step 1 for \(topicString)")
                } else {
                    print("📱 ConversationView: Resuming \(topicString) at step \(currentStepIndex + 1)/\(conversationSteps.count)")
                }
            } else {
                // No topic specified, start at step 1
                currentStepIndex = 0
                print("📱 ConversationView: No topic specified, starting at step 1/\(conversationSteps.count)")
            }
            
            // Always log the current step the user is on
            print("📍 User is currently on step \(currentStepIndex + 1) of \(conversationSteps.count)")
        }
        .onDisappear {
            // Save current progress when view disappears (including manual dismissal)
            if !topicString.isEmpty {
                ConversationProgressManager.saveProgress(step: currentStepIndex, for: topicString)
                print("💾 ConversationView: Saved progress for \(topicString) - Step \(currentStepIndex + 1)/\(conversationSteps.count)")
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20) {
        ConversationView(
            conversationSteps: exampleConversationSteps,
            displayName: .constant("Cass"),
            onResponse: { _, _ in },
            questionCategory: .wellness
        )
        
        ConversationView(
            conversationSteps: exampleConversationSteps,
            displayName: .constant("Cass"),
            onResponse: { _, _ in }
            // No questionCategory - should default to "Questions"
        )
    }
}
#endif

