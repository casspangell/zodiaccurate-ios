import SwiftUI

struct UpdateCard: View {
    @State private var cardHeight: CGFloat = 0.25
    @State private var dragOffset: CGFloat = 0
    @State private var isExpanded = false
    
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
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 40, height: 4)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                        
                        // Card content
                        UpdateCardText()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * cardHeight)
                    .background(Color.black)
                    .cornerRadius(4)
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
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
                            
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                                if shouldExpand && !isExpanded {
                                    cardHeight = 0.5
                                    isExpanded = true
                                } else if shouldCollapse && isExpanded {
                                    cardHeight = 0.25
                                    isExpanded = false
                                }
                                dragOffset = 0
                            }
                        }
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0), value: cardHeight)
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
