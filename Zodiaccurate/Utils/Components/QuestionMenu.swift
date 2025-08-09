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
        isEmploymentEnabled: Bool = true
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
    }

    var body: some View {
        HStack(spacing: 0) {
            // Wellness
            CircleIconButton(
                systemName: "heart.fill",
                accessibilityLabel: "Wellness Questions",
                isEnabled: isWellnessEnabled,
                action: onWellness
            )
            Spacer()
            // Relationships
            CircleIconButton(
                systemName: "person.2.fill",
                accessibilityLabel: "Relationship Questions",
                isEnabled: isRelationshipEnabled,
                action: onRelationship
            )
            Spacer()
            // Partner
            CircleIconButton(
                systemName: "link.circle.fill",
                accessibilityLabel: "Partner Questions",
                isEnabled: isPartnerEnabled,
                action: onPartner
            )
            Spacer()
            // Important People
            CircleIconButton(
                systemName: "star.fill",
                accessibilityLabel: "Important People Questions",
                isEnabled: isImportantPeopleEnabled,
                action: onImportantPeople
            )
            Spacer()
            // Children
            CircleIconButton(
                systemName: "gamecontroller.fill",
                accessibilityLabel: "Children Questions",
                isEnabled: isChildrenEnabled,
                action: onChildren
            )
            Spacer()
            // Employment
            CircleIconButton(
                systemName: "briefcase.fill",
                accessibilityLabel: "Employment Questions",
                isEnabled: isEmploymentEnabled,
                action: onEmployment
            )
        }
        .padding(.horizontal, 8)
    }
}

struct QuestionMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            QuestionMenu(
                onWellness: {},
                onRelationship: {},
                onImportantPeople: {},
                onChildren: {},
                onEmployment: {},
                isWellnessEnabled: true,
                isRelationshipEnabled: true,
                isImportantPeopleEnabled: true,
                isChildrenEnabled: false,
                isEmploymentEnabled: true
            )
        }
        .padding(20)
        .background(Color.backgroundPrimary)
        .previewLayout(.sizeThatFits)
    }
}

