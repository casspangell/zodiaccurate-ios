import SwiftUI
import SwiftData

enum QuestionMenuButton {
    case none
    case wellness
    case relationship
    case importantPeople
    case children
    case employment
}

struct QuestionMenu: View {
    @Environment(\.modelContext) private var modelContext
    
    let onWellness: () -> Void
    let onRelationship: () -> Void
    let onImportantPeople: () -> Void
    let onChildren: () -> Void
    let onEmployment: () -> Void
    
    let isWellnessEnabled: Bool
    let isRelationshipEnabled: Bool
    let isImportantPeopleEnabled: Bool
    let isChildrenEnabled: Bool
    let isEmploymentEnabled: Bool

    // Optional fiery state per button
    let isWellnessFiery: Bool
    let isRelationshipFiery: Bool
    let isImportantPeopleFiery: Bool
    let isChildrenFiery: Bool
    let isEmploymentFiery: Bool
    
    // Highlighted button state
    let highlightedButton: QuestionMenuButton
    
    // User ID for checking IntakeData (optional, defaults to "default")
    let userId: String?
    
    // MARK: - State Properties for Unfinished State
    
    /// Determines if a topic is unfinished based on conversation progress
    /// Returns true only if there's some progress but not complete
    @State private var isWellnessUnfinished: Bool = false
    @State private var isRelationshipUnfinished: Bool = false
    @State private var isImportantPeopleUnfinished: Bool = false
    @State private var isChildrenUnfinished: Bool = false
    @State private var isEmploymentUnfinished: Bool = false
    
    /// Determines if a topic is completed based on conversation progress
    /// Returns true if the topic has reached the final step
    @State private var isWellnessCompleted: Bool = false
    @State private var isRelationshipCompleted: Bool = false
    @State private var isImportantPeopleCompleted: Bool = false
    @State private var isChildrenCompleted: Bool = false
    @State private var isEmploymentCompleted: Bool = false
    
    // MARK: - Helper Methods
    
    /// Update all unfinished states based on current progress
    func updateUnfinishedStates() {
        let wellnessProgress = ConversationProgressManager.getProgress(for: "wellness")
        let relationshipProgress = ConversationProgressManager.getProgress(for: "relationship")
        let importantPeopleProgress = ConversationProgressManager.getProgress(for: "importantPeople")
        let childrenProgress = ConversationProgressManager.getProgress(for: "children")
        let employmentProgress = ConversationProgressManager.getProgress(for: "employment")
        
        isWellnessUnfinished = wellnessProgress > 0 && wellnessProgress < ConversationProgressManager.getTotalStepsForTopic("wellness")
        isRelationshipUnfinished = relationshipProgress > 0 && relationshipProgress < ConversationProgressManager.getTotalStepsForTopic("relationship")
        isImportantPeopleUnfinished = importantPeopleProgress > 0 && importantPeopleProgress < ConversationProgressManager.getTotalStepsForTopic("importantPeople")
        isChildrenUnfinished = childrenProgress > 0 && childrenProgress < ConversationProgressManager.getTotalStepsForTopic("children")
        isEmploymentUnfinished = employmentProgress > 0 && employmentProgress < ConversationProgressManager.getTotalStepsForTopic("employment")
        
        // Update completion states - check both ConversationProgressManager and SwiftData (IntakeData)
        let effectiveUserId = userId ?? "default"
        isWellnessCompleted = checkTopicCompletion(topic: "wellness", userId: effectiveUserId)
        isRelationshipCompleted = checkTopicCompletion(topic: "relationship", userId: effectiveUserId)
        isImportantPeopleCompleted = checkTopicCompletion(topic: "importantPeople", userId: effectiveUserId)
        isChildrenCompleted = checkTopicCompletion(topic: "children", userId: effectiveUserId)
        isEmploymentCompleted = checkTopicCompletion(topic: "employment", userId: effectiveUserId)
        
        print("🔄 QuestionMenu: Updated unfinished states - Wellness: \(isWellnessUnfinished), Relationship: \(isRelationshipUnfinished), Important People: \(isImportantPeopleUnfinished), Children: \(isChildrenUnfinished), Employment: \(isEmploymentUnfinished)")
        print("🔄 QuestionMenu: Updated completion states - Wellness: \(isWellnessCompleted), Relationship: \(isRelationshipCompleted), Important People: \(isImportantPeopleCompleted), Children: \(isChildrenCompleted), Employment: \(isEmploymentCompleted)")
        
        // Reset fiery state for completed topics
        if isWellnessCompleted { isWellnessFieryState = false }
        if isRelationshipCompleted { isRelationshipFieryState = false }
        if isImportantPeopleCompleted { isImportantPeopleFieryState = false }
        if isChildrenCompleted { isChildrenFieryState = false }
        if isEmploymentCompleted { isEmploymentFieryState = false }
    }
    
    /// Check if a topic is completed by checking both ConversationProgressManager and IntakeData (SwiftData)
    private func checkTopicCompletion(topic: String, userId: String) -> Bool {
        // First check ConversationProgressManager (UserDefaults - tracks step progress)
        let progressCompleted = ConversationProgressManager.isTopicCompleted(for: topic)
        
        if progressCompleted {
            return true
        }
        
        // Fallback: Also check IntakeData (SwiftData - tracks actual data saved)
        do {
            let intakeDataManager = IntakeDataManager(modelContext: modelContext)
            let hasData = intakeDataManager.hasTopicData(userId: userId, topic: topic)
            if hasData {
                let topicData = intakeDataManager.getTopicData(userId: userId, topic: topic)
                let totalSteps = ConversationProgressManager.getTotalStepsForTopic(topic)
                // If we have data for most steps (80% or more), consider it completed
                if topicData.count >= Int(Double(totalSteps) * 0.8) {
                    print("✅ QuestionMenu: Topic '\(topic)' considered completed based on IntakeData (has \(topicData.count)/\(totalSteps) answers)")
                    return true
                }
            }
        } catch {
            print("⚠️ QuestionMenu: Error checking IntakeData for topic '\(topic)': \(error)")
        }
        
        return false
    }

    // Local interactive state that starts from the passed fiery flags, then turns off after tap
    @State private var isWellnessFieryState: Bool = false
    @State private var isRelationshipFieryState: Bool = false
    @State private var isImportantPeopleFieryState: Bool = false
    @State private var isChildrenFieryState: Bool = false
    @State private var isEmploymentFieryState: Bool = false

    init(
        onWellness: @escaping () -> Void = {},
        onRelationship: @escaping () -> Void = {},
        onImportantPeople: @escaping () -> Void = {},
        onChildren: @escaping () -> Void = {},
        onEmployment: @escaping () -> Void = {},
        isWellnessEnabled: Bool = true,
        isRelationshipEnabled: Bool = true,
        isImportantPeopleEnabled: Bool = true,
        isChildrenEnabled: Bool = true,
        isEmploymentEnabled: Bool = true,
        isWellnessFiery: Bool = true,
        isRelationshipFiery: Bool = true,
        isImportantPeopleFiery: Bool = true,
        isChildrenFiery: Bool = true,
        isEmploymentFiery: Bool = true,
        highlightedButton: QuestionMenuButton = .none,
        userId: String? = nil
    ) {
        self.onWellness = onWellness
        self.onRelationship = onRelationship
        self.onImportantPeople = onImportantPeople
        self.onChildren = onChildren
        self.onEmployment = onEmployment
        self.isWellnessEnabled = isWellnessEnabled
        self.isRelationshipEnabled = isRelationshipEnabled
        self.isImportantPeopleEnabled = isImportantPeopleEnabled
        self.isChildrenEnabled = isChildrenEnabled
        self.isEmploymentEnabled = isEmploymentEnabled
        self.isWellnessFiery = isWellnessFiery
        self.isRelationshipFiery = isRelationshipFiery
        self.isImportantPeopleFiery = isImportantPeopleFiery
        self.isChildrenFiery = isChildrenFiery
        self.isEmploymentFiery = isEmploymentFiery
        self.highlightedButton = highlightedButton
        self.userId = userId

        // Initialize local state from provided initial flags, but only if enabled
        self._isWellnessFieryState = State(initialValue: isWellnessEnabled && isWellnessFiery)
        self._isRelationshipFieryState = State(initialValue: isRelationshipEnabled && isRelationshipFiery)
        self._isImportantPeopleFieryState = State(initialValue: isImportantPeopleEnabled && isImportantPeopleFiery)
        self._isChildrenFieryState = State(initialValue: isChildrenEnabled && isChildrenFiery)
        self._isEmploymentFieryState = State(initialValue: isEmploymentEnabled && isEmploymentFiery)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Wellness
            CircleIconButton(
                systemName: "heart.fill",
                accessibilityLabel: "Wellness Questions",
                isEnabled: isWellnessEnabled && !isWellnessCompleted,
                isFiery: isWellnessCompleted ? false : (isWellnessUnfinished ? false : isWellnessFieryState),
                isHighlighted: highlightedButton == .wellness,
                isUnfinished: isWellnessUnfinished,
                action: {
                    print("🔘 QuestionMenu: Wellness button tapped")
                    if isWellnessEnabled && !isWellnessCompleted { isWellnessFieryState = false }
                    if !isWellnessCompleted { onWellness() }
                }
            )
            Spacer()
            // Relationships
            CircleIconButton(
                systemName: "person.2.fill",
                accessibilityLabel: "Relationship Questions",
                isEnabled: isRelationshipEnabled && !isRelationshipCompleted,
                isFiery: isRelationshipCompleted ? false : (isRelationshipUnfinished ? false : isRelationshipFieryState),
                isHighlighted: highlightedButton == .relationship,
                isUnfinished: isRelationshipUnfinished,
                action: {
                    print("🔘 QuestionMenu: Relationship button tapped")
                    if isRelationshipEnabled && !isRelationshipCompleted { isRelationshipFieryState = false }
                    if !isRelationshipCompleted { onRelationship() }
                }
            )
            Spacer()
            // Important People
            CircleIconButton(
                systemName: "star.fill",
                accessibilityLabel: "Important People Questions",
                isEnabled: isImportantPeopleEnabled && !isImportantPeopleCompleted,
                isFiery: isImportantPeopleCompleted ? false : (isImportantPeopleUnfinished ? false : isImportantPeopleFieryState),
                isHighlighted: highlightedButton == .importantPeople,
                isUnfinished: isImportantPeopleUnfinished,
                action: {
                    print("🔘 QuestionMenu: Important People button tapped")
                    print("🔍 QuestionMenu: isImportantPeopleEnabled = \(isImportantPeopleEnabled)")
                    print("🔍 QuestionMenu: isImportantPeopleFieryState = \(isImportantPeopleFieryState)")
                    if isImportantPeopleEnabled && !isImportantPeopleCompleted { isImportantPeopleFieryState = false }
                    if !isImportantPeopleCompleted { onImportantPeople() }
                }
            )
            Spacer()
            // Children
            CircleIconButton(
                systemName: "gamecontroller.fill",
                accessibilityLabel: "Children Questions",
                isEnabled: isChildrenEnabled && !isChildrenCompleted,
                isFiery: isChildrenCompleted ? false : (isChildrenUnfinished ? false : isChildrenFieryState),
                isHighlighted: highlightedButton == .children,
                isUnfinished: isChildrenUnfinished,
                action: {
                    print("🔘 QuestionMenu: Children button tapped")
                    if isChildrenEnabled && !isChildrenCompleted { isChildrenFieryState = false }
                    if !isChildrenCompleted { onChildren() }
                }
            )
            Spacer()
            // Employment
            CircleIconButton(
                systemName: "briefcase.fill",
                accessibilityLabel: "Employment Questions",
                isEnabled: isEmploymentEnabled && !isEmploymentCompleted,
                isFiery: isEmploymentCompleted ? false : (isEmploymentUnfinished ? false : isEmploymentFieryState),
                isHighlighted: highlightedButton == .employment,
                isUnfinished: isEmploymentUnfinished,
                action: {
                    print("🔘 QuestionMenu: Employment button tapped")
                    if isEmploymentEnabled && !isEmploymentCompleted { isEmploymentFieryState = false }
                    if !isEmploymentCompleted { onEmployment() }
                }
            )
        }
        .padding(.horizontal, 8)
        .onAppear {
            updateUnfinishedStates()
        }
        .onReceive(NotificationCenter.default.publisher(for: .conversationProgressUpdated)) { _ in
            print("🔄 QuestionMenu: Received conversationProgressUpdated notification, updating states")
            updateUnfinishedStates()
        }
    }
}

#Preview {
    VStack(spacing: 28) {
        Text("QuestionMenu with Pulsating Pink Backgrounds")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.bottom, 10)
        
        // Default
        Text("Default State")
            .font(.caption)
            .foregroundColor(.gray)
        
        QuestionMenu(
            isWellnessEnabled: true,
            isRelationshipEnabled: true,
            isImportantPeopleEnabled: true,
            isChildrenEnabled: true,
            isEmploymentEnabled: true
        )

        // Fiery states demo with pulsating pink backgrounds
        Text("Fiery States with Pulsating Pink Backgrounds")
            .font(.caption)
            .foregroundColor(.gray)
        
        QuestionMenu(
            isWellnessEnabled: true,
            isRelationshipEnabled: true,
            isImportantPeopleEnabled: true,
            isChildrenEnabled: true,
            isEmploymentEnabled: true,
            isWellnessFiery: true,
            isRelationshipFiery: false,
            isImportantPeopleFiery: false,
            isChildrenFiery: true,
            isEmploymentFiery: false
        )
        
        // Highlighted state demo
        Text("Highlighted State")
            .font(.caption)
            .foregroundColor(.gray)
        
        QuestionMenu(
            isWellnessEnabled: true,
            isRelationshipEnabled: true,
            isImportantPeopleEnabled: true,
            isChildrenEnabled: true,
            isEmploymentEnabled: true,
            highlightedButton: .wellness
        )
        
        // All fiery demo
        Text("All Buttons with Pulsating Pink Backgrounds")
            .font(.caption)
            .foregroundColor(.gray)
        
        QuestionMenu(
            isWellnessEnabled: true,
            isRelationshipEnabled: true,
            isImportantPeopleEnabled: true,
            isChildrenEnabled: true,
            isEmploymentEnabled: true,
            isWellnessFiery: true,
            isRelationshipFiery: true,
            isImportantPeopleFiery: true,
            isChildrenFiery: true,
            isEmploymentFiery: true
        )
        
        // Unfinished states demo (now automatically determined)
        Text("Unfinished States (Automatically Determined)")
            .font(.caption)
            .foregroundColor(.gray)
        
        QuestionMenu(
            isWellnessEnabled: true,
            isRelationshipEnabled: true,
            isImportantPeopleEnabled: true,
            isChildrenEnabled: true,
            isEmploymentEnabled: true
        )
        
        // Note about automatic unfinished detection
        Text("Note: Unfinished state is now automatically determined based on conversation progress")
            .font(.caption2)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    .padding(24)
    .background(Color.backgroundPrimary)
    .previewLayout(.sizeThatFits)
}

