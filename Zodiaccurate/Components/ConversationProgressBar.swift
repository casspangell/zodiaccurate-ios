//
//  ConversationProgressBar.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import SwiftUI

/// A progress bar component that displays overall completion progress across all 5 conversation forms
struct ConversationProgressBar: View {
    @State private var overallProgress: Double = 0.0
    @State private var completedCount: Int = 0
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.electricBlue.opacity(0.9),
                                    Color.magenta.opacity(0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * CGFloat(overallProgress), 8), height: 6)
                        .animation(.easeInOut(duration: 0.5), value: overallProgress)
                        .shadow(color: Color.electricBlue.opacity(0.5), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 6)
            
            // Progress text
            HStack {
                Text("Intake Completion for Zodiaccurate")
                    .font(.dmSansMedium(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(overallProgress * 100))%")
                    .font(.dmSansSemibold(size: 12))
                    .foregroundColor(Color.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deepBlue.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.electricBlue.opacity(0.3),
                                    Color.magenta.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            updateProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .conversationProgressUpdated)) { _ in
            updateProgress()
        }
    }
    
    private func updateProgress() {
        overallProgress = ConversationProgressManager.getOverallProgress()
        completedCount = ConversationProgressManager.getCompletedFormCount()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            ConversationProgressBar()
                .padding()
        }
    }
}
