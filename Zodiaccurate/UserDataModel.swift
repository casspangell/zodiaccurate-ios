//
//  UserDataModel.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData

@Model
final class UserDataModel {
    var firstName: String
    var birthDate: String
    var birthTime: String
    var zodiacSign: String
    var responses: [String] // Stored as "question|key|answer" strings
    var userId: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(firstName: String = "", 
         birthDate: String = "", 
         birthTime: String = "", 
         zodiacSign: String = "", 
         responses: [String] = [], 
         userId: String? = nil) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.responses = responses
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Helper method to convert responses back to tuples
    var responseTuples: [(String, String, String)] {
        return responses.compactMap { responseString in
            let components = responseString.split(separator: "|", maxSplits: 2)
            guard components.count == 3 else { return nil }
            return (String(components[0]), String(components[1]), String(components[2]))
        }
    }
    
    // Helper method to get a specific response
    func getResponse(for key: String) -> (question: String, answer: String)? {
        let response = responseTuples.first { $0.1 == key }
        guard let response = response else { return nil }
        return (question: response.0, answer: response.2)
    }
    
    // Helper method to update a response
    func updateResponse(for key: String, question: String, answer: String) {
        // Remove existing response for this key
        responses.removeAll { $0.contains("|\(key)|") }
        // Add new response
        responses.append("\(question)|\(key)|\(answer)")
        updatedAt = Date()
    }
} 