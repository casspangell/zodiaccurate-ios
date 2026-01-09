import SwiftUI

// MARK: - Date Picker Component
struct DatePickerView: View {
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    let showSubmitButton: Bool
    
    init(selectedDate: Binding<Date>, onDateSelected: @escaping (Date) -> Void, showSubmitButton: Bool = true) {
        self._selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        self.showSubmitButton = showSubmitButton
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                DatePicker(
                    "Birth Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))
                
                if showSubmitButton {
                    HStack {
                        Spacer()
                        Button(action: {
                            onDateSelected(selectedDate)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Submit")
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
            .padding()
            .background(ChatBubbleColor.active.color)
            .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))
            .foregroundColor(.white)
            .frame(maxWidth: 280, alignment: .trailing)
        }
    }
}

// MARK: - Time Picker Component
struct TimePickerView: View {
    @Binding var selectedTime: Date
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let showSubmitButton: Bool
    
    init(selectedTime: Binding<Date>, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, showSubmitButton: Bool = true) {
        self._selectedTime = selectedTime
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.showSubmitButton = showSubmitButton
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                DatePicker(
                    "Birth Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .colorScheme(.dark)
                .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))
                
                if showSubmitButton {
                    HStack(spacing: 12) {
                        Button(action: {
                            onUnknownTime()
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                Text("I don't know")
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.lightSaphire.opacity(0.8))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            onTimeSelected(selectedTime)
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Submit")
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
            .padding()
            .background(ChatBubbleColor.active.color)
            .clipShape(CustomBubbleShape(radius: bubbleCornerRadius, topRightRatio: bubbleTopRightRatio))
            .foregroundColor(.white)
            .frame(maxWidth: 280, alignment: .trailing)
        }
    }
}

// MARK: - Main Interactive Picker View
struct InteractivePickerView: View {
    let step: ConversationStep
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    let showSubmitButton: Bool
    
    init(step: ConversationStep, selectedDate: Binding<Date>, selectedTime: Binding<Date>, onDateSelected: @escaping (Date) -> Void, onTimeSelected: @escaping (Date) -> Void, onUnknownTime: @escaping () -> Void, showSubmitButton: Bool = true) {
        self.step = step
        self._selectedDate = selectedDate
        self._selectedTime = selectedTime
        self.onDateSelected = onDateSelected
        self.onTimeSelected = onTimeSelected
        self.onUnknownTime = onUnknownTime
        self.showSubmitButton = showSubmitButton
    }
    
    var body: some View {
        Group {
            switch step.inputType {
            case "date":
                DatePickerView(
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected,
                    showSubmitButton: showSubmitButton
                )
            case "time":
                TimePickerView(
                    selectedTime: $selectedTime,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime,
                    showSubmitButton: showSubmitButton
                )
            default:
                EmptyView()
            }
        }
        .background(Color.clear)
    }
}

// MARK: - Timezone Picker Component
struct TimezonePickerView: View {
    @Binding var selectedTimezone: String
    
    private let timezones: [(identifier: String, displayName: String)] = {
        let identifiers = TimeZone.knownTimeZoneIdentifiers.sorted()
        return identifiers.map { identifier in
            let timezone = TimeZone(identifier: identifier)!
            let abbreviation = timezone.abbreviation() ?? ""
            let offset = timezone.secondsFromGMT()
            let hours = offset / 3600
            let minutes = abs(offset % 3600) / 60
            let offsetString = String(format: "%+.2d:%.2d", hours, minutes)
            
            // Extract city name from identifier (e.g., "America/New_York" -> "New York")
            let cityName = identifier.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier
            
            let displayName = "\(cityName) (\(abbreviation)) GMT\(offsetString)"
            return (identifier: identifier, displayName: displayName)
        }
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timezone")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Menu {
                Picker("Select Timezone", selection: $selectedTimezone) {
                    ForEach(timezones, id: \.identifier) { timezone in
                        Text(timezone.displayName)
                            .tag(timezone.identifier)
                    }
                }
            } label: {
                HStack {
                    Text(selectedTimezone.isEmpty ? "Select your timezone" : timezoneDisplayName(for: selectedTimezone))
                        .foregroundColor(selectedTimezone.isEmpty ? Color.white.opacity(0.5) : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .onAppear {
            // Set default to device timezone if not already set
            if selectedTimezone.isEmpty {
                selectedTimezone = TimeZone.current.identifier
            }
        }
    }
    
    private func timezoneDisplayName(for identifier: String) -> String {
        return timezones.first(where: { $0.identifier == identifier })?.displayName ?? identifier
    }
}

#Preview {
    VStack(spacing: 20) {
        // Date picker preview
        InteractivePickerView(
            step: ConversationStep(
                message: "What's your birth date?",
                inputType: "date",
                placeholder: "Your birth date",
                dataKey: "birthDate"
            ),
            selectedDate: .constant(Date()),
            selectedTime: .constant(Date()),
            onDateSelected: { date in
                print("Date selected: \(date)")
            },
            onTimeSelected: { time in
                print("Time selected: \(time)")
            },
            onUnknownTime: {
                print("Unknown time selected")
            }
        )
        
        // Time picker preview
        InteractivePickerView(
            step: ConversationStep(
                message: "What's your birth time?",
                inputType: "time",
                placeholder: "Birth time (if known)",
                dataKey: "birthTime"
            ),
            selectedDate: .constant(Date()),
            selectedTime: .constant(Date()),
            onDateSelected: { date in
                print("Date selected: \(date)")
            },
            onTimeSelected: { time in
                print("Time selected: \(time)")
            },
            onUnknownTime: {
                print("Unknown time selected")
            }
        )
    }
    .padding()
    .background(Color.black)
} 
