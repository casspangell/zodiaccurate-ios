import SwiftUI

// If ConversationStep is not available here, import or define it as needed.
// import ...

struct InteractivePickerView: View {
    let step: ConversationStep
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onDateSelected: (Date) -> Void
    let onTimeSelected: (Date) -> Void
    let onUnknownTime: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            if step.inputType == "date" {
                VStack(alignment: .trailing, spacing: 12) {
                    DatePicker(
                        "Birth Date",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
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
                .background(Color.bubbleFrost.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
            } else if step.inputType == "time" {
                VStack(alignment: .trailing, spacing: 12) {
                    DatePicker(
                        "Birth Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .colorScheme(.dark)
                    
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
                .background(Color.bubbleFrost.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(20)
                .frame(maxWidth: 280, alignment: .trailing)
            }
        }
    }
} 