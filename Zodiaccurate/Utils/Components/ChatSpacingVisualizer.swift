import SwiftUI

/// Visual representation of all padding and spacing in the ZodiacChatView
struct ChatSpacingVisualizer: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Main Chat Content
                chatContentSection
                
                // Input Section
                inputSection
                
                // Bottom Elements
                bottomElementsSection
            }
        }
        .background(Color.black)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Header Background
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Text("HEADER")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            // Header Top Padding (60px)
            Rectangle()
                .fill(Color.red.opacity(0.7))
                .frame(height: 60)
                .overlay(
                    Text("Header .padding(.top, 60)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            // Header Bottom Padding (8px)
            Rectangle()
                .fill(Color.orange.opacity(0.7))
                .frame(height: 8)
                .overlay(
                    Text("Header .padding(.bottom, 8)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
        }
    }
    
    // MARK: - Chat Content Section
    private var chatContentSection: some View {
        VStack(spacing: 0) {
            // Top Spacer (contentTopSpacing)
            Rectangle()
                .fill(Color.purple.opacity(0.7))
                .frame(height: 80)
                .overlay(
                    Text("Spacer().frame(height: contentTopSpacing)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            // Chat Content Container
            VStack(spacing: 0) {
                // Chat Content Horizontal Padding
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 20)
                        .overlay(
                            Text("Chat Content\n.padding(.horizontal)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(-90))
                        )
                    
                    // Chat Messages Area
                    VStack(spacing: 0) {
                        // Question Bubble
                        questionBubble
                        
                        // Spacing between bubbles (currently 0)
                        Rectangle()
                            .fill(Color.yellow.opacity(0.5))
                            .frame(height: 0)
                            .overlay(
                                Text("VStack(spacing: 0)\nBetween bubbles")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            )
                        
                        // Answered Bubble
                        answeredBubble
                        
                        // Typing Indicator
                        Rectangle()
                            .fill(Color.cyan.opacity(0.7))
                            .frame(height: 30)
                            .overlay(
                                Text("TypingIndicator")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                        
                        // Bottom Anchor
                        Rectangle()
                            .fill(Color.gray.opacity(0.7))
                            .frame(height: 1)
                            .overlay(
                                Text("Color.clear.frame(height: 1)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                    }
                    .background(Color.white.opacity(0.1))
                    
                    Rectangle()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 20)
                        .overlay(
                            Text("Chat Content\n.padding(.horizontal)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                        )
                }
                
                // Chat Content Bottom Padding (20px)
                Rectangle()
                    .fill(Color.green.opacity(0.7))
                    .frame(height: 20)
                    .overlay(
                        Text("Chat Content .padding(.bottom, 20)")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Question Bubble
    private var questionBubble: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // Question Bubble Content
                VStack(alignment: .leading, spacing: 8) {
                    // Avatar
                    Rectangle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("Avatar")
                                .font(.caption2)
                                .foregroundColor(.white)
                        )
                    
                    // Question Text with Padding
                    Rectangle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(height: 60)
                        .overlay(
                            VStack {
                                Text("QuestionChatBubble")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text(".padding() around text")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        )
                }
                .frame(maxWidth: 280, alignment: .leading)
                
                // Spacer pushing to left
                Rectangle()
                    .fill(Color.pink.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Text("Spacer()\n(pushes to left)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Answered Bubble
    private var answeredBubble: some View {
        VStack(spacing: 0) {
            // Top Padding (8px)
            Rectangle()
                .fill(Color.orange.opacity(0.7))
                .frame(height: 8)
                .overlay(
                    Text("AnsweredChatBubble\n.padding(.top, 8)")
                        .font(.caption2)
                        .foregroundColor(.white)
                )
            
            HStack(spacing: 0) {
                // Spacer pushing to right
                Rectangle()
                    .fill(Color.pink.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Text("Spacer()\n(pushes to right)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    )
                
                // Answered Bubble Content
                Rectangle()
                    .fill(Color.green.opacity(0.6))
                    .frame(width: 200, height: 60)
                    .overlay(
                        VStack {
                            Text("AnsweredChatBubble")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(".padding() around text")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(spacing: 0) {
            // Input Container
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Input Field with Padding
                    VStack(spacing: 0) {
                        // Vertical Padding (12px)
                        Rectangle()
                            .fill(Color.purple.opacity(0.7))
                            .frame(height: 12)
                            .overlay(
                                Text("ResponseChatBubble\n.padding(.vertical, 12)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                        
                        HStack(spacing: 0) {
                            // Horizontal Padding (16px)
                            Rectangle()
                                .fill(Color.purple.opacity(0.7))
                                .frame(width: 16)
                                .overlay(
                                    Text("ResponseChatBubble\n.padding(.horizontal, 16)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(-90))
                                )
                            
                            // Input Field Content
                            Rectangle()
                                .fill(Color.purple.opacity(0.6))
                                .frame(height: 44)
                                .overlay(
                                    Text("InputTextField")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                            
                            // Spacing between input and button (16px)
                            Rectangle()
                                .fill(Color.yellow.opacity(0.7))
                                .frame(width: 16)
                                .overlay(
                                    Text("HStack(spacing: 16)\nInput to Button")
                                        .font(.caption2)
                                        .foregroundColor(.black)
                                        .rotationEffect(.degrees(-90))
                                )
                            
                            // Send Button
                            Rectangle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text("Send Button")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                )
                            
                            // Horizontal Padding (16px)
                            Rectangle()
                                .fill(Color.purple.opacity(0.7))
                                .frame(width: 16)
                                .overlay(
                                    Text("ResponseChatBubble\n.padding(.horizontal, 16)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .rotationEffect(.degrees(90))
                                )
                        }
                        
                        // Vertical Padding (12px)
                        Rectangle()
                            .fill(Color.purple.opacity(0.7))
                            .frame(height: 12)
                            .overlay(
                                Text("ResponseChatBubble\n.padding(.vertical, 12)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .background(Color.purple.opacity(0.3))
        }
    }
    
    // MARK: - Bottom Elements Section
    private var bottomElementsSection: some View {
        VStack(spacing: 0) {
            // Complete Button
            VStack(spacing: 0) {
                // Complete Button Content Padding
                Rectangle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 50)
                    .overlay(
                        Text("Complete Button\n.padding() around content")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                
                // Complete Button Horizontal Padding
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20)
                        .overlay(
                            Text("Complete Button\n.padding(.horizontal)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(-90))
                        )
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20)
                        .overlay(
                            Text("Complete Button\n.padding(.horizontal)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(90))
                        )
                }
                
                // Complete Button Bottom Padding (50px)
                Rectangle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 50)
                    .overlay(
                        Text("Complete Button\n.padding(.bottom, 50)")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
            
            // Bottom Anchor
            Rectangle()
                .fill(Color.gray.opacity(0.7))
                .frame(height: 20)
                .overlay(
                    Text("Bottom Anchor\n.padding(.bottom, 20)")
                        .font(.caption)
                        .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    ChatSpacingVisualizer()
} 
