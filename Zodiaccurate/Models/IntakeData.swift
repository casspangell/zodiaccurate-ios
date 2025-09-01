//
//  IntakeData.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/14/25.
//

import Foundation
import SwiftData

@Model
final class IntakeData {
    var id: UUID
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    
    // Topic maps to a dictionary of "dataKey":"answer"
    var wellnessData: [String: String]
    var relationshipData: [String: String]
    var importantPeopleData: [String: String]
    var childrenData: [String: String]
    var employmentData: [String: String]
    
    init(
        id: UUID = UUID(),
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        wellnessData: [String: String] = [:],
        relationshipData: [String: String] = [:],
        importantPeopleData: [String: String] = [:],
        childrenData: [String: String] = [:],
        employmentData: [String: String] = [:]
    ) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.wellnessData = wellnessData
        self.relationshipData = relationshipData
        self.importantPeopleData = importantPeopleData
        self.childrenData = childrenData
        self.employmentData = employmentData
    }
    
    // MARK: - Convenience Methods
    
    /// Get data for a specific topic
    func getData(for topic: String) -> [String: String] {
        switch topic.lowercased() {
        case "wellness":
            return wellnessData
        case "relationship":
            return relationshipData
        case "importantpeople":
            return importantPeopleData
        case "children":
            return childrenData
        case "employment":
            return employmentData
        default:
            return [:]
        }
    }
    
    /// Set data for a specific topic
    func setData(_ data: [String: String], for topic: String) {
        switch topic.lowercased() {
        case "wellness":
            wellnessData = data
        case "relationship":
            relationshipData = data
        case "importantpeople":
            importantPeopleData = data
        case "children":
            childrenData = data
        case "employment":
            employmentData = data
        default:
            break
        }
        updatedAt = Date()
    }
    
    /// Add or update a single answer for a topic and dataKey
    func setAnswer(_ answer: String, for dataKey: String, in topic: String) {
        switch topic.lowercased() {
        case "wellness":
            wellnessData[dataKey] = answer
        case "relationship":
            relationshipData[dataKey] = answer
        case "importantpeople":
            importantPeopleData[dataKey] = answer
        case "children":
            childrenData[dataKey] = answer
        case "employment":
            employmentData[dataKey] = answer
        default:
            break
        }
        updatedAt = Date()
    }
    
    /// Get a specific answer for a topic and dataKey
    func getAnswer(for dataKey: String, in topic: String) -> String? {
        switch topic.lowercased() {
        case "wellness":
            return wellnessData[dataKey]
        case "relationship":
            return relationshipData[dataKey]
        case "importantpeople":
            return importantPeopleData[dataKey]
        case "children":
            return childrenData[dataKey]
        case "employment":
            return employmentData[dataKey]
        default:
            return nil
        }
    }
    
    /// Check if a topic has any data
    func hasData(for topic: String) -> Bool {
        return !getData(for: topic).isEmpty
    }
    
    /// Get all topics that have data
    var topicsWithData: [String] {
        var topics: [String] = []
        if !wellnessData.isEmpty { topics.append("wellness") }
        if !relationshipData.isEmpty { topics.append("relationship") }
        if !importantPeopleData.isEmpty { topics.append("importantPeople") }
        if !childrenData.isEmpty { topics.append("children") }
        if !employmentData.isEmpty { topics.append("employment") }
        return topics
    }
    
    /// Get total number of answers across all topics
    var totalAnswers: Int {
        return wellnessData.count + relationshipData.count + importantPeopleData.count + childrenData.count + employmentData.count
    }
}


