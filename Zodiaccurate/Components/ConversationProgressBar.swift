//
//  ConversationProgressBar.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import SwiftUI
import Foundation

// #region agent log
func debugLog(_ message: String = "", data: [String: Any] = [:], hypothesisId: String = "") {
    let logPath = "/Users/casspangell/Documents/Tao Academy/PAUL/zodiaccurate-ios/.cursor/debug.log"
    var logEntry: [String: Any] = [
        "timestamp": Int(Date().timeIntervalSince1970 * 1000),
        "sessionId": "debug-session"
    ]
    
    // If data contains location, use it; otherwise use message parameter
    if let location = data["location"] as? String {
        logEntry["location"] = location
    } else if !message.isEmpty {
        logEntry["location"] = "ConversationProgressBar.swift"
        logEntry["message"] = message
    }
    
    // Merge all data into logEntry
    for (key, value) in data {
        logEntry[key] = value
    }
    
    // Add hypothesisId if provided
    if !hypothesisId.isEmpty {
        logEntry["hypothesisId"] = hypothesisId
    }
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: logEntry),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write((jsonString + "\n").data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try? jsonString.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
}
// #endregion

/// A progress bar component that displays overall completion progress across all 5 conversation forms
struct ConversationProgressBar: View {
    @State private var overallProgress: Double = 0.0
    @State private var completedCount: Int = 0
    @State private var isCompleted: Bool = false
    @State private var showCompletionAnimation: Bool = false
    @State private var glowIntensity: Double = 0.0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var previousProgress: Double = 0.0
    @State private var showPlaceholder: Bool = false
    @State private var progressBarOpacity: Double = 1.0
    @State private var shouldShowAnimation: Bool = false
    @State private var hasCheckedOnStartup: Bool = false
    @State private var hasResetProgress: Bool = false
    @State private var isTestAnimation: Bool = false
    
    var body: some View {
        ZStack {
            if showPlaceholder {
                // Placeholder text
                Text("Running your first Zodiaccurate")
                    .font(.dmSansMedium(size: 14))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
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
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
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
                                        gradient: Gradient(colors: isCompleted ? [
                                            Color.yellow.opacity(0.95),
                                            Color.orange.opacity(0.9),
                                            Color.pink.opacity(0.85)
                                        ] : [
                                            Color.electricBlue.opacity(0.9),
                                            Color.magenta.opacity(0.8)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(geometry.size.width * CGFloat(overallProgress), 8), height: 6)
                                .animation(.easeInOut(duration: 0.5), value: overallProgress)
                                .shadow(color: isCompleted ? Color.yellow.opacity(0.8) : Color.electricBlue.opacity(0.5), radius: isCompleted ? 8 : 4, x: 0, y: 0)
                                .scaleEffect(scale)
                        }
                    }
                    .frame(height: 6)
                    
                    // Progress text
                    HStack {
                        Text("Intake Completion for Zodiaccurate")
                            .font(.dmSansMedium(size: 12))
                            .foregroundColor(isCompleted ? Color.yellow.opacity(0.9) : Color.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(Int(overallProgress * 100))%")
                            .font(.dmSansSemibold(size: 12))
                            .foregroundColor(isCompleted ? Color.yellow : Color.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        // Base background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.deepBlue.opacity(0.3))
                        
                        // Glow effect when completed
                        if isCompleted {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.yellow.opacity(0.3 * glowIntensity),
                                            Color.orange.opacity(0.2 * glowIntensity),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 200
                                    )
                                )
                                .opacity(glowIntensity)
                        }
                        
                        // Border
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCompleted ? 
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.8),
                                        Color.orange.opacity(0.6),
                                        Color.pink.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.electricBlue.opacity(0.3),
                                        Color.magenta.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isCompleted ? 2 : 1
                            )
                    }
                )
                .scaleEffect(scale)
                .opacity(progressBarOpacity)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            // #region agent log
            debugLog("onAppear called", data: ["hasCheckedOnStartup": hasCheckedOnStartup, "hasResetProgress": hasResetProgress], hypothesisId: "A")
            // #endregion
            
            // Reset all progress except wellness for testing (only once per app launch)
            if !hasResetProgress {
                hasResetProgress = true
                let topics = ["relationship", "importantPeople", "children", "employment"]
                for topic in topics {
                    ConversationProgressManager.clearProgress(for: topic)
                }
                // Ensure wellness is completed
                let wellnessTotalSteps = ConversationProgressManager.getTotalStepsForTopic("wellness")
                ConversationProgressManager.saveProgress(step: wellnessTotalSteps, for: "wellness")
                
                // #region agent log
                debugLog("Reset progress - only wellness completed", data: [
                    "wellnessSteps": wellnessTotalSteps
                ], hypothesisId: "A")
                // #endregion
            }
            
            // On first appearance, just update progress without triggering animation
            // Animation should only trigger on actual progress changes, not on initial load
            if !hasCheckedOnStartup {
                hasCheckedOnStartup = true
                let newProgress = ConversationProgressManager.getOverallProgress()
                let newCount = ConversationProgressManager.getCompletedFormCount()
                overallProgress = newProgress
                completedCount = newCount
                // #region agent log
                debugLog("First startup - updating progress without animation", data: [
                    "progress": newProgress,
                    "completedCount": newCount
                ], hypothesisId: "A")
                // #endregion
            } else {
                updateProgress()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .conversationProgressUpdated)) { _ in
            updateProgress()
        }
        .onChange(of: overallProgress) { oldValue, newValue in
            // Skip onChange handler if this is a test animation (handled by notification)
            if isTestAnimation {
                return
            }
            
            if newValue >= 1.0 && oldValue < 1.0 {
                // Only show animation if all forms are actually completed
                if areAllFormsCompleted() || shouldShowAnimation {
                    triggerCompletionAnimation()
                    shouldShowAnimation = false // Reset flag
                }
            } else if newValue < 1.0 {
                isCompleted = false
                showCompletionAnimation = false
                showPlaceholder = false
                progressBarOpacity = 1.0
                shouldShowAnimation = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .progressBarShowCompletionAnimation)) { _ in
            // #region agent log
            debugLog("progressBarShowCompletionAnimation notification received", data: [
                "currentProgress": overallProgress
            ], hypothesisId: "C,E")
            // #endregion
            
            // Test button: Trigger animation by temporarily setting progress to 1.0
            // Save current progress
            let savedProgress = overallProgress
            let savedCount = completedCount
            
            // Set flag to prevent onChange handler from interfering
            isTestAnimation = true
            
            // Temporarily set to 100% for visual effect
            overallProgress = 1.0
            completedCount = 5
            
            // #region agent log
            debugLog("Test button: Setting temp progress to 1.0 for animation", data: [
                "savedProgress": savedProgress,
                "tempProgress": 1.0,
                "savedCount": savedCount,
                "tempCount": 5
            ], hypothesisId: "C")
            // #endregion
            
            // Trigger animation immediately
            triggerCompletionAnimation()
            
            // Restore actual progress after animation completes (4+ seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                isTestAnimation = false
                overallProgress = savedProgress
                completedCount = savedCount
                isCompleted = false
                showCompletionAnimation = false
                showPlaceholder = false
                progressBarOpacity = 1.0
                glowIntensity = 0.0
                scale = 1.0
                
                // #region agent log
                debugLog("Test button: Restored actual progress after animation", data: [
                    "restoredProgress": savedProgress,
                    "restoredCount": savedCount
                ], hypothesisId: "C")
                // #endregion
            }
        }
    }
    
    private func updateProgress() {
        let newProgress = ConversationProgressManager.getOverallProgress()
        let newCount = ConversationProgressManager.getCompletedFormCount()
        
        // #region agent log
        debugLog("updateProgress entry", data: [
            "oldProgress": overallProgress,
            "newProgress": newProgress,
            "completedCount": newCount,
            "isCompleted": isCompleted,
            "shouldShowAnimation": shouldShowAnimation
        ], hypothesisId: "A,D")
        // #endregion
        
        previousProgress = overallProgress
        overallProgress = newProgress
        completedCount = newCount
        
        if overallProgress >= 1.0 && !isCompleted {
            let allCompleted = areAllFormsCompleted()
            // #region agent log
            debugLog("Progress >= 1.0 check", data: [
                "allCompleted": allCompleted,
                "shouldShowAnimation": shouldShowAnimation,
                "willTrigger": allCompleted || shouldShowAnimation
            ], hypothesisId: "A,B")
            // #endregion
            
            // Only show animation if all forms are actually completed
            if allCompleted || shouldShowAnimation {
                // #region agent log
                debugLog("Triggering animation from updateProgress", hypothesisId: "A,B,D")
                // #endregion
                triggerCompletionAnimation()
                shouldShowAnimation = false
            }
        }
    }
    
    private func areAllFormsCompleted() -> Bool {
        let topics = ["wellness", "relationship", "importantPeople", "children", "employment"]
        let results = topics.map { topic in
            (topic, ConversationProgressManager.isTopicCompleted(for: topic))
        }
        let allCompleted = results.allSatisfy { $0.1 }
        // #region agent log
        debugLog("areAllFormsCompleted check", data: [
            "results": Dictionary(uniqueKeysWithValues: results.map { ($0.0, $0.1) }),
            "allCompleted": allCompleted
        ], hypothesisId: "B")
        // #endregion
        return allCompleted
    }
    
    private func triggerCompletionAnimation() {
        // #region agent log
        debugLog("triggerCompletionAnimation called", data: [
            "isCompleted": isCompleted,
            "showCompletionAnimation": showCompletionAnimation
        ], hypothesisId: "ALL")
        // #endregion
        isCompleted = true
        showCompletionAnimation = true
        
        // Pulse scale animation
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.05
            glowIntensity = 1.0
        }
        
        
        // Pulse effect
        withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
            scale = 1.08
            glowIntensity = 1.2
        }
        
        // Return to normal scale but keep glow
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                glowIntensity = 0.6
            }
        }
        
        
        // After 4 seconds, fade out progress bar and show placeholder
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                progressBarOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.4)) {
                    showPlaceholder = true
                }
            }
        }
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
