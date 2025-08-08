//
//  Zodiac.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/7/25.
//

import Foundation
import SwiftData

// MARK: - Horoscope Model
public struct Horoscope {
    public let topic: String
    public let content: String
    
    public init(topic: String, content: String) {
        self.topic = topic
        self.content = content
    }
}

// MARK: - Zodiac Model
@Model
public class Zodiac {
    public var horoscopes: [Horoscope]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(horoscopes: [Horoscope] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.horoscopes = horoscopes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Add a new horoscope to the collection
    public func addHoroscope(_ horoscope: Horoscope) {
        horoscopes.append(horoscope)
        updatedAt = Date()
    }
    
    /// Remove a horoscope at the specified index
    public func removeHoroscope(at index: Int) {
        guard index >= 0 && index < horoscopes.count else { return }
        horoscopes.remove(at: index)
        updatedAt = Date()
    }
    
    /// Get horoscope by topic
    public func getHoroscope(by topic: String) -> Horoscope? {
        return horoscopes.first { $0.topic.lowercased() == topic.lowercased() }
    }
    
    /// Get all topics
    public var topics: [String] {
        return horoscopes.map { $0.topic }
    }
}

