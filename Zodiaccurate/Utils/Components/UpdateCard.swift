import SwiftUI

struct UpdateCard: View {
    @State private var cardHeight: CGFloat = 0.25
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    @State private var isDragging = false
    @State private var currentInput = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var highlightInputField = false
    
    // Sample conversation step for the update card
    private var updateConversationStep: ConversationStep {
        let timestamp = getTimestampString()
        
        return ConversationStep(
            message: "How are you feeling today? Share your thoughts and let me know what's on your mind...",
            inputType: "multiLine",
            placeholder: "",
            dataKey: "dailyUpdate-\(timestamp)"
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black rectangle covering safe area at bottom (static)
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.black)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .ignoresSafeArea(.container, edges: .bottom)
                }
                .ignoresSafeArea(.container, edges: .bottom)
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Draggable indicator
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.white.opacity(0.6))
//                            .frame(width: 40, height: 4)
//                            .padding(.top, 24)
//                            .padding(.bottom, 8)
                        
                        // Card content
                        VStack(spacing: 16) {
                            // Label text
                            UpdateCardText()
                                .padding(.horizontal, 20)
                                .padding(.top, 40)
                            
                            // Chat bubble (only when expanded)
                            if isExpanded {
                                UpdateBubble(
                                    currentInput: $currentInput,
                                    onSend: {
                                        // Handle send action
                                        print("Update sent: \(currentInput)")
                                        currentInput = ""
                                    },
                                    onFrameChange: { _ in },
                                    highlightInputField: .constant(false)
                                )
                                .padding(.horizontal, 20)
                                .opacity(isExpanded ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }
                        }
                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * cardHeight)
                    .background(Color.black)
                    .cornerRadius(24)
                }
                .offset(y: dragOffset)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let translation = value.translation.height
                        let screenHeight = geometry.size.height
                        
                        // Calculate new height based on drag
                        let newHeight = isExpanded ? 0.5 : 0.25
                        let heightDifference = (0.5 - 0.25) * screenHeight
                        
                        // Limit drag to reasonable bounds
                        let maxDrag = heightDifference * 0.3
                        dragOffset = max(-maxDrag, min(translation, maxDrag))
                    }
                    .onEnded { value in
                        let translation = value.translation.height
                        let velocity = value.velocity.height
                        let screenHeight = geometry.size.height
                        
                        // Determine if we should expand or collapse based on drag and velocity
                        let shouldExpand = translation < -50 || velocity < -500
                        let shouldCollapse = translation > 50 || velocity > 500
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                            if shouldExpand && !isExpanded {
                                cardHeight = 0.5
                                isExpanded = true
                            } else if shouldCollapse && isExpanded {
                                cardHeight = 0.25
                                isExpanded = false
                            }
                            dragOffset = 0
                        }
                        
                        isDragging = false
                    }
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                    if isExpanded {
                        cardHeight = 0.25
                        isExpanded = false
                    } else {
                        cardHeight = 0.5
                        isExpanded = true
                    }
                    dragOffset = 0
                }
            }
        }
    }
}

#Preview {
    ZStack {
        // Background for preview
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        UpdateCard()
    }
} 
