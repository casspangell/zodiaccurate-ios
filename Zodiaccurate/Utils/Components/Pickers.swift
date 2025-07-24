import SwiftUI

// MARK: - Date Picker Component
struct DatePickerView: View {
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void
    
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
    
    var body: some View {
        Group {
            switch step.inputType {
            case "date":
                DatePickerView(
                    selectedDate: $selectedDate,
                    onDateSelected: onDateSelected
                )
            case "time":
                TimePickerView(
                    selectedTime: $selectedTime,
                    onTimeSelected: onTimeSelected,
                    onUnknownTime: onUnknownTime
                )
            default:
                EmptyView()
            }
        }
        .background(Color.clear)
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
