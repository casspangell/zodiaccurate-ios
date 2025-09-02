//
//  ConversationProgressManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation

/// Manages conversation progress persistence in UserDefaults
class ConversationProgressManager {
    private static let userDefaults = UserDefaults.standard
    
    // MARK: - UserDefaults Keys
    private struct Keys {
        static let wellnessProgress = "conversation_wellness_progress"
        static let relationshipProgress = "conversation_relationship_progress"
        static let importantPeopleProgress = "conversation_importantPeople_progress"
        static let childrenProgress = "conversation_children_progress"
        static let employmentProgress = "conversation_employment_progress"
        static let lastActiveTopic = "conversation_last_active_topic"
        static let lastActiveStep = "conversation_last_active_step"
    }
    
    // MARK: - Progress Management
    
    /// Save conversation progress for a specific topic
    /// - Parameters:
    ///   - step: Current step index (0-based)
    ///   - topic: The conversation topic
    static func saveProgress(step: Int, for topic: String) {
        let key = progressKey(for: topic)
        userDefaults.set(step, forKey: key)
        
        // Also save the last active topic and step for resuming
        userDefaults.set(topic, forKey: Keys.lastActiveTopic)
        userDefaults.set(step, forKey: Keys.lastActiveStep)
        
        // Post notification to update UI
        NotificationCenter.default.post(name: .conversationProgressUpdated, object: nil)
        
        print("💾 Saved conversation progress - Topic: \(topic), Step: \(step)")
    }
    
    /// Get conversation progress for a specific topic
    /// - Parameter topic: The conversation topic
    /// - Returns: The last completed step index (0-based), or 0 if no progress
    static func getProgress(for topic: String) -> Int {
        let key = progressKey(for: topic)
        return userDefaults.integer(forKey: key)
    }
    
    /// Get the last active topic
    /// - Returns: The last active topic string, or nil if none
    static func getLastActiveTopic() -> String? {
        return userDefaults.string(forKey: Keys.lastActiveTopic)
    }
    
    /// Get the last active step for the last active topic
    /// - Returns: The last active step index, or 0 if none
    static func getLastActiveStep() -> Int {
        return userDefaults.integer(forKey: Keys.lastActiveStep)
    }
    
    /// Clear progress for a specific topic
    /// - Parameter topic: The conversation topic
    static func clearProgress(for topic: String) {
        let key = progressKey(for: topic)
        userDefaults.removeObject(forKey: key)
        print("🗑️ Cleared conversation progress for topic: \(topic)")
    }
    
    /// Clear all conversation progress
    static func clearAllProgress() {
        let topics = ["wellness", "relationship", "importantPeople", "children", "employment"]
        for topic in topics {
            clearProgress(for: topic)
        }
        
        userDefaults.removeObject(forKey: Keys.lastActiveTopic)
        userDefaults.removeObject(forKey: Keys.lastActiveStep)
        print("🗑️ Cleared all conversation progress")
    }
    
    /// Check if a topic has any progress
    /// - Parameter topic: The conversation topic
    /// - Returns: True if there's progress, false otherwise
    static func hasProgress(for topic: String) -> Bool {
        return getProgress(for: topic) > 0
    }
    
    /// Get all topics with progress
    /// - Returns: Array of topics that have progress
    static func getTopicsWithProgress() -> [String] {
        let topics = ["wellness", "relationship", "importantPeople", "children", "employment"]
        return topics.filter { hasProgress(for: $0) }
    }
    
    // MARK: - Helper Methods
    
    /// Get the UserDefaults key for a specific topic
    /// - Parameter topic: The conversation topic
    /// - Returns: The UserDefaults key string
    private static func progressKey(for topic: String) -> String {
        switch topic.lowercased() {
        case "wellness":
            return Keys.wellnessProgress
        case "relationship":
            return Keys.relationshipProgress
        case "importantpeople", "important people":
            return Keys.importantPeopleProgress
        case "children":
            return Keys.childrenProgress
        case "employment":
            return Keys.employmentProgress
        default:
            return "conversation_\(topic.lowercased())_progress"
        }
    }
    
    /// Convert QuestionMenuButton to topic string for consistency
    /// - Parameter button: The QuestionMenuButton
    /// - Returns: The normalized topic string
    static func topicFromQuestionMenuButton(_ button: QuestionMenuButton) -> String {
        switch button {
        case .wellness:
            return "wellness"
        case .relationship:
            return "relationship"
        case .importantPeople:
            return "importantPeople"
        case .children:
            return "children"
        case .employment:
            return "employment"
        case .none:
            return ""
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let conversationProgressUpdated = Notification.Name("conversationProgressUpdated")
}
