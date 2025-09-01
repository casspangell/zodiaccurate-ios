//
//  IntakeDataManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation
import SwiftData

@MainActor
class IntakeDataManager: ObservableObject {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Operations
    
    /// Get or create IntakeData for a user
    func getOrCreateIntakeData(for userId: String) -> IntakeData {
        let descriptor = FetchDescriptor<IntakeData>(
            predicate: #Predicate<IntakeData> { intakeData in
                intakeData.userId == userId
            }
        )
        
        do {
            let existingData = try modelContext.fetch(descriptor)
            if let first = existingData.first {
                return first
            } else {
                // Create new IntakeData
                let newIntakeData = IntakeData(userId: userId)
                modelContext.insert(newIntakeData)
                try modelContext.save()
                print("📝 Created new IntakeData for user: \(userId)")
                return newIntakeData
            }
        } catch {
            print("❌ Error fetching IntakeData: \(error)")
            // Create new IntakeData as fallback
            let newIntakeData = IntakeData(userId: userId)
            modelContext.insert(newIntakeData)
            do {
                try modelContext.save()
                print("📝 Created new IntakeData (fallback) for user: \(userId)")
            } catch {
                print("❌ Error saving new IntakeData: \(error)")
            }
            return newIntakeData
        }
    }
    
    /// Update IntakeData with a new answer
    func updateIntakeData(userId: String, topic: String, dataKey: String, answer: String) {
        let intakeData = getOrCreateIntakeData(for: userId)
        
        // Convert topic to the format expected by IntakeData
        let normalizedTopic = normalizeTopic(topic)
        
        // Update the answer
        intakeData.setAnswer(answer, for: dataKey, in: normalizedTopic)
        
        // Save to SwiftData
        do {
            try modelContext.save()
            print("📝 Updated IntakeData - User: \(userId), Topic: \(normalizedTopic), Key: \(dataKey), Answer: \(answer)")
        } catch {
            print("❌ Error saving IntakeData update: \(error)")
        }
    }
    
    /// Get all IntakeData for a user
    func getIntakeData(for userId: String) -> IntakeData? {
        let descriptor = FetchDescriptor<IntakeData>(
            predicate: #Predicate<IntakeData> { intakeData in
                intakeData.userId == userId
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            print("❌ Error fetching IntakeData: \(error)")
            return nil
        }
    }
    
    /// Get data for a specific topic
    func getTopicData(userId: String, topic: String) -> [String: String] {
        guard let intakeData = getIntakeData(for: userId) else {
            return [:]
        }
        
        let normalizedTopic = normalizeTopic(topic)
        return intakeData.getData(for: normalizedTopic)
    }
    
    /// Check if a user has data for a specific topic
    func hasTopicData(userId: String, topic: String) -> Bool {
        guard let intakeData = getIntakeData(for: userId) else {
            return false
        }
        
        let normalizedTopic = normalizeTopic(topic)
        return intakeData.hasData(for: normalizedTopic)
    }
    
    /// Get all topics that have data for a user
    func getTopicsWithData(userId: String) -> [String] {
        guard let intakeData = getIntakeData(for: userId) else {
            return []
        }
        
        return intakeData.topicsWithData
    }
    
    /// Delete IntakeData for a user
    func deleteIntakeData(for userId: String) {
        let descriptor = FetchDescriptor<IntakeData>(
            predicate: #Predicate<IntakeData> { intakeData in
                intakeData.userId == userId
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            for intakeData in results {
                modelContext.delete(intakeData)
            }
            try modelContext.save()
            print("🗑️ Deleted IntakeData for user: \(userId)")
        } catch {
            print("❌ Error deleting IntakeData: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Normalize topic string to match IntakeData property names
    private func normalizeTopic(_ topic: String) -> String {
        switch topic.lowercased() {
        case "wellness":
            return "wellness"
        case "relationship":
            return "relationship"
        case "importantpeople", "important people":
            return "importantPeople"
        case "children":
            return "children"
        case "employment":
            return "employment"
        default:
            return topic.lowercased()
        }
    }
    
    /// Convert QuestionMenuButton to topic string
    func topicFromQuestionMenuButton(_ button: QuestionMenuButton) -> String {
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
