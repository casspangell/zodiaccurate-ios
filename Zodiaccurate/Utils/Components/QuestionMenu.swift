import SwiftUI

struct QuestionMenu: View {
    let onWellness: () -> Void
    let onRelationship: () -> Void
    let onPartner: () -> Void
    let onImportantPeople: () -> Void
    let onChildren: () -> Void
    let onEmployment: () -> Void
    
    let isWellnessEnabled: Bool
    let isRelationshipEnabled: Bool
    let isPartnerEnabled: Bool
    let isImportantPeopleEnabled: Bool
    let isChildrenEnabled: Bool
    let isEmploymentEnabled: Bool

    // Optional fiery state per button
    let isWellnessFiery: Bool
    let isRelationshipFiery: Bool
    let isPartnerFiery: Bool
    let isImportantPeopleFiery: Bool
    let isChildrenFiery: Bool
    let isEmploymentFiery: Bool

    // Local interactive state that starts from the passed fiery flags, then turns off after tap
    @State private var isWellnessFieryState: Bool = false
    @State private var isRelationshipFieryState: Bool = false
    @State private var isPartnerFieryState: Bool = false
    @State private var isImportantPeopleFieryState: Bool = false
    @State private var isChildrenFieryState: Bool = false
    @State private var isEmploymentFieryState: Bool = false

    init(
        onWellness: @escaping () -> Void = {},
        onRelationship: @escaping () -> Void = {},
        onPartner: @escaping () -> Void = {},
        onImportantPeople: @escaping () -> Void = {},
        onChildren: @escaping () -> Void = {},
        onEmployment: @escaping () -> Void = {},
        isWellnessEnabled: Bool = true,
        isRelationshipEnabled: Bool = true,
        isPartnerEnabled: Bool = true,
        isImportantPeopleEnabled: Bool = true,
        isChildrenEnabled: Bool = true,
        isEmploymentEnabled: Bool = true,
        isWellnessFiery: Bool = true,
        isRelationshipFiery: Bool = true,
        isPartnerFiery: Bool = true,
        isImportantPeopleFiery: Bool = true,
        isChildrenFiery: Bool = true,
        isEmploymentFiery: Bool = true
    ) {
        self.onWellness = onWellness
        self.onRelationship = onRelationship
        self.onPartner = onPartner
        self.onImportantPeople = onImportantPeople
        self.onChildren = onChildren
        self.onEmployment = onEmployment
        self.isWellnessEnabled = isWellnessEnabled
        self.isRelationshipEnabled = isRelationshipEnabled
        self.isPartnerEnabled = isPartnerEnabled
        self.isImportantPeopleEnabled = isImportantPeopleEnabled
        self.isChildrenEnabled = isChildrenEnabled
        self.isEmploymentEnabled = isEmploymentEnabled
        self.isWellnessFiery = isWellnessFiery
        self.isRelationshipFiery = isRelationshipFiery
        self.isPartnerFiery = isPartnerFiery
        self.isImportantPeopleFiery = isImportantPeopleFiery
        self.isChildrenFiery = isChildrenFiery
        self.isEmploymentFiery = isEmploymentFiery

        // Initialize local state from provided initial flags, but only if enabled
        self._isWellnessFieryState = State(initialValue: isWellnessEnabled && isWellnessFiery)
        self._isRelationshipFieryState = State(initialValue: isRelationshipEnabled && isRelationshipFiery)
        self._isPartnerFieryState = State(initialValue: isPartnerEnabled && isPartnerFiery)
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
                isFiery: isWellnessFieryState,
                action: {
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
                isFiery: isRelationshipFieryState,
                action: {
                    if isRelationshipEnabled { isRelationshipFieryState = false }
                    onRelationship()
                }
            )
            Spacer()
            // Partner
            CircleIconButton(
                systemName: "link.circle.fill",
                accessibilityLabel: "Partner Questions",
                isEnabled: isPartnerEnabled,
                isFiery: isPartnerFieryState,
                action: {
                    if isPartnerEnabled { isPartnerFieryState = false }
                    onPartner()
                }
            )
            Spacer()
            // Important People
            CircleIconButton(
                systemName: "star.fill",
                accessibilityLabel: "Important People Questions",
                isEnabled: isImportantPeopleEnabled,
                isFiery: isImportantPeopleFieryState,
                action: {
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
                isFiery: isChildrenFieryState,
                action: {
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
                isFiery: isEmploymentFieryState,
                action: {
                    if isEmploymentEnabled { isEmploymentFieryState = false }
                    onEmployment()
                }
            )
        }
        .padding(.horizontal, 8)
    }
}

struct QuestionMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 28) {
            // Default
            QuestionMenu(
                isWellnessEnabled: true,
                isRelationshipEnabled: true,
                isPartnerEnabled: true,
                isImportantPeopleEnabled: true,
                isChildrenEnabled: true,
                isEmploymentEnabled: true
            )

            // Fiery states demo
            QuestionMenu(
                isWellnessEnabled: true,
                isRelationshipEnabled: true,
                isPartnerEnabled: true,
                isImportantPeopleEnabled: true,
                isChildrenEnabled: true,
                isEmploymentEnabled: true,
                isWellnessFiery: true,
                isRelationshipFiery: false,
                isPartnerFiery: true,
                isImportantPeopleFiery: false,
                isChildrenFiery: true,
                isEmploymentFiery: false
            )
        }
        .padding(24)
        .background(Color.backgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}

