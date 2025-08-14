//
//  MultipleChoice.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import SwiftUI

// MARK: - Radio (Single-Select) Picker
struct RadioButtonPicker: View {
    let title: String?
    let options: [String]
    @Binding var selected: String?
    let onSelect: ((String?) -> Void)?
    var showSubmitButton: Bool = false
    var submitTitle: String = "Submit"
    var onSubmit: (() -> Void)? = nil

    init(
        title: String? = nil,
        options: [String],
        selected: Binding<String?>,
        onSelect: ((String?) -> Void)? = nil,
        showSubmitButton: Bool = false,
        submitTitle: String = "Submit",
        onSubmit: (() -> Void)? = nil
    ) {
        self.title = title
        self.options = options
        self._selected = selected
        self.onSelect = onSelect
        self.showSubmitButton = showSubmitButton
        self.submitTitle = submitTitle
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.dmSansMedium(size: 16))
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
            }

            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: { handleTap(option) }) {
                        HStack(spacing: 12) {
                            RadioIcon(isSelected: selected == option)
                            Text(option)
                                .font(.dmSansMedium(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                    .background(Color.clear)

                    if option != options.last { Divider().background(Color.white.opacity(0.08)) }
                }
            }
            .padding(4)
            .background(ChatBubbleColor.active.color)
            .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))

            if showSubmitButton {
                HStack {
                    Spacer()
                    Button(action: { onSubmit?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(submitTitle)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGold)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .frame(maxWidth: 280, alignment: .leading)
    }

    private func handleTap(_ option: String) {
        if selected == option {
            selected = nil
        } else {
            selected = option
        }
        onSelect?(selected)
    }
}

// MARK: - Checkbox (Multi-Select) Picker
struct CheckboxMultiPicker: View {
    let title: String?
    let options: [String]
    @Binding var selections: Set<String>
    let maxSelections: Int?
    let onChange: ((Set<String>) -> Void)?
    var showSubmitButton: Bool = false
    var submitTitle: String = "Submit"
    var onSubmit: (() -> Void)? = nil

    init(
        title: String? = nil,
        options: [String],
        selections: Binding<Set<String>>,
        maxSelections: Int? = nil,
        onChange: ((Set<String>) -> Void)? = nil,
        showSubmitButton: Bool = false,
        submitTitle: String = "Submit",
        onSubmit: (() -> Void)? = nil
    ) {
        self.title = title
        self.options = options
        self._selections = selections
        self.maxSelections = maxSelections
        self.onChange = onChange
        self.showSubmitButton = showSubmitButton
        self.submitTitle = submitTitle
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.dmSansMedium(size: 16))
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
            }

            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button(action: { toggle(option) }) {
                        HStack(spacing: 12) {
                            CheckboxIcon(isSelected: selections.contains(option))
                            Text(option)
                                .font(.dmSansMedium(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                    .background(Color.clear)

                    if option != options.last { Divider().background(Color.white.opacity(0.08)) }
                }
            }
            .padding(4)
            .background(ChatBubbleColor.active.color)
            .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))

            if showSubmitButton {
                HStack {
                    Spacer()
                    Button(action: { onSubmit?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text(submitTitle)
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGold)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .frame(maxWidth: 280, alignment: .leading)
    }

    private func toggle(_ option: String) {
        var updated = selections
        if updated.contains(option) {
            updated.remove(option)
        } else {
            if let max = maxSelections, updated.count >= max { return }
            updated.insert(option)
        }
        selections = updated
        onChange?(updated)
    }
}

// MARK: - Icons
private struct RadioIcon: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .fill(Color.accentGold)
                    .frame(width: 12, height: 12)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

private struct CheckboxIcon: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                    .frame(width: 22, height: 22)
                    .background(Color.accentGold)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: 24) {
        RadioButtonPicker(
            title: "How are you feeling today?",
            options: ["Excellent", "Pretty Good", "Poor"],
            selected: .constant(nil),
            onSelect: { _ in },
            showSubmitButton: true,
            onSubmit: {}
        )

        CheckboxMultiPicker(
            title: "Pick up to 2 areas to focus on:",
            options: ["Sleep", "Energy", "Focus", "Mood"],
            selections: .constant(["Sleep"]),
            maxSelections: 2,
            onChange: { _ in },
            showSubmitButton: true,
            onSubmit: {}
        )
    }
    .padding()
    .background(Color.black)
}
