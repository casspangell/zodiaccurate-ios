//
//  DailyUpdate.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/6/25.
//

import Foundation
import SwiftData

@Model
final class DailyUpdate {
    // MARK: - Properties
    var id: String
    var content: String
    var timestamp: Date
    var mood: String?
    var tags: [String]
    var isCompleted: Bool
    
    // MARK: - Initializer
    init(content: String, mood: String? = nil, tags: [String] = [], isCompleted: Bool = false) {
        let now = Date()
        self.id = "dailyUpdate-\(getTimestampString(date: now))-\(UUID().uuidString.prefix(8))"
        self.content = content
        self.timestamp = now
        self.mood = mood
        self.tags = tags
        self.isCompleted = isCompleted
    }
    
    // MARK: - Computed Properties
    var formattedDate: String {
        return getFormattedDate(date: timestamp)
    }
    
    var formattedTime: String {
        return getFormattedTime(date: timestamp)
    }
    
    var dayOfWeek: String {
        return getDayOfWeek(date: timestamp)
    }
    
    // MARK: - Helper Methods
    func addTag(_ tag: String) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }
    
    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    func markAsCompleted() {
        isCompleted = true
    }
    
    func markAsIncomplete() {
        isCompleted = false
    }
}
