import SwiftUI

enum QuestionMenuButton {
    case none
    case wellness
    case relationship
    case importantPeople
    case children
    case employment
}

struct QuestionMenu: View {
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
    
    // MARK: - Computed Properties for Unfinished State
    
    /// Determines if a topic is unfinished based on conversation progress
    /// Returns true only if there's some progress but not complete
    private var isWellnessUnfinished: Bool {
        let progress = ConversationProgressManager.getProgress(for: "wellness")
        let totalSteps = getTotalStepsForTopic("wellness")
        return progress > 0 && progress < totalSteps
    }
    
    private var isRelationshipUnfinished: Bool {
        let progress = ConversationProgressManager.getProgress(for: "relationship")
        let totalSteps = getTotalStepsForTopic("relationship")
        return progress > 0 && progress < totalSteps
    }
    
    private var isImportantPeopleUnfinished: Bool {
        let progress = ConversationProgressManager.getProgress(for: "importantPeople")
        let totalSteps = getTotalStepsForTopic("importantPeople")
        return progress > 0 && progress < totalSteps
    }
    
    private var isChildrenUnfinished: Bool {
        let progress = ConversationProgressManager.getProgress(for: "children")
        let totalSteps = getTotalStepsForTopic("children")
        return progress > 0 && progress < totalSteps
    }
    
    private var isEmploymentUnfinished: Bool {
        let progress = ConversationProgressManager.getProgress(for: "employment")
        let totalSteps = getTotalStepsForTopic("employment")
        return progress > 0 && progress < totalSteps
    }
    
    // MARK: - Helper Methods
    
    /// Get the total number of steps for a specific topic
    /// This should match the actual conversation steps defined in your app
    private func getTotalStepsForTopic(_ topic: String) -> Int {
        switch topic.lowercased() {
        case "wellness":
            return 5 // Adjust based on your actual wellness conversation steps
        case "relationship":
            return 5 // Adjust based on your actual relationship conversation steps
        case "importantpeople":
            return 5 // Adjust based on your actual important people conversation steps
        case "children":
            return 5 // Adjust based on your actual children conversation steps
        case "employment":
            return 5 // Adjust based on your actual employment conversation steps
        default:
            return 5 // Default fallback
        }
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
        highlightedButton: QuestionMenuButton = .none
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
                isEnabled: isWellnessEnabled,
                isFiery: isWellnessUnfinished ? false : isWellnessFieryState,
                isHighlighted: highlightedButton == .wellness,
                isUnfinished: isWellnessUnfinished,
                action: {
                    print("🔘 QuestionMenu: Wellness button tapped")
                    if isWellnessEnabled { isWellnessFieryState = false }
                    onWellness()
                }
            )
            Spacer()
            // Relationships
            CircleIconButton(
                systemName: "person.2.fill",
                accessibilityLabel: "Relationship Questions",
                isEnabled: isRelationshipEnabled,
                isFiery: isRelationshipUnfinished ? false : isRelationshipFieryState,
                isHighlighted: highlightedButton == .relationship,
                isUnfinished: isRelationshipUnfinished,
                action: {
                    print("🔘 QuestionMenu: Relationship button tapped")
                    if isRelationshipEnabled { isRelationshipFieryState = false }
                    onRelationship()
                }
            )
            Spacer()
            // Important People
            CircleIconButton(
                systemName: "star.fill",
                accessibilityLabel: "Important People Questions",
                isEnabled: isImportantPeopleEnabled,
                isFiery: isImportantPeopleUnfinished ? false : isImportantPeopleFieryState,
                isHighlighted: highlightedButton == .importantPeople,
                isUnfinished: isImportantPeopleUnfinished,
                action: {
                    print("🔘 QuestionMenu: Important People button tapped")
                    print("🔍 QuestionMenu: isImportantPeopleEnabled = \(isImportantPeopleEnabled)")
                    print("🔍 QuestionMenu: isImportantPeopleFieryState = \(isImportantPeopleFieryState)")
                    if isImportantPeopleEnabled { isImportantPeopleFieryState = false }
                    onImportantPeople()
                }
            )
            Spacer()
            // Children
            CircleIconButton(
                systemName: "gamecontroller.fill",
                accessibilityLabel: "Children Questions",
                isEnabled: isChildrenEnabled,
                isFiery: isChildrenUnfinished ? false : isChildrenFieryState,
                isHighlighted: highlightedButton == .children,
                isUnfinished: isChildrenUnfinished,
                action: {
                    print("🔘 QuestionMenu: Children button tapped")
                    if isChildrenEnabled { isChildrenFieryState = false }
                    onChildren()
                }
            )
            Spacer()
            // Employment
            CircleIconButton(
                systemName: "briefcase.fill",
                accessibilityLabel: "Employment Questions",
                isEnabled: isEmploymentEnabled,
                isFiery: isEmploymentUnfinished ? false : isEmploymentFieryState,
                isHighlighted: highlightedButton == .employment,
                isUnfinished: isEmploymentUnfinished,
                action: {
                    print("🔘 QuestionMenu: Employment button tapped")
                    if isEmploymentEnabled { isEmploymentFieryState = false }
                    onEmployment()
                }
            )
        }
        .padding(.horizontal, 8)
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

