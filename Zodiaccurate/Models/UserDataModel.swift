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
    var responses: String // JSON-encoded array of "question|key|answer" strings
    var userId: String?
    var createdAt: Date
    var updatedAt: Date
    var welcomeHoroscope: String?
    
    init(firstName: String = "", 
         birthDate: String = "", 
         birthTime: String = "", 
         zodiacSign: String = "", 
         responses: [String] = [], 
         userId: String? = nil,
         welcomeHoroscope: String? = nil) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        // Encode array to JSON string
        self.responses = (try? JSONEncoder().encode(responses)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.welcomeHoroscope = welcomeHoroscope
    }
    
    // Computed property for array access
    var responseArray: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(responses.utf8))) ?? []
        }
        set {
            responses = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        }
    }
    
    // Helper method to convert responses back to tuples
    var responseTuples: [(String, String, String)] {
        return responseArray.compactMap { responseString in
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
        var arr = responseArray
        arr.removeAll { $0.contains("|\(key)|") }
        arr.append("\(question)|\(key)|\(answer)")
        responseArray = arr
        updatedAt = Date()
    }
    
    // MARK: - Mock Data
    static func createMockUserData() -> UserDataModel {
        return UserDataModel(
            firstName: "Erika",
            birthDate: "July 25, 1970",
            birthTime: "10:31 PM",
            zodiacSign: "Leo",
            responses: ["What's your name?|name|Erika", "When were you born?|birthDate|July 25, 1970"],
            welcomeHoroscope: """
            Dearest Erika, born under the fiery heart of Leo with the night's twilight as your celestial cloak, the cosmos has whispered your name. Born at 10:31 PM on July 25, 2025, your birth was graced with the shimmering secrets of the evening, and it's those same secrets that have come to symbolize your deep-seated passion and regal spirit, typical of a true Leo.
            
            Your intuitive greeting, filled with multiple hellos, speaks to your innate ability to connect energetically with those around you, a vibrant 'hi' that echoes through the universe. Remember, dear Erika, your dreams may be silent now, but in that silence, there is a boundless potential, a universe of possibilities waiting for you. Embrace this journey, for it's in the quiet moments that your true strength emerges.
            
            The stars have aligned to reveal that your path is one of leadership and creativity. Your natural charisma draws others to you like moths to a flame, and your generous spirit makes you a beacon of warmth in the lives of those around you. Trust in your intuition, for it is sharper than you know.
            
            As you navigate through this cosmic journey, remember that every challenge is an opportunity for growth. Your Leo heart beats with the rhythm of the universe, and your courage will guide you through any storm. The future holds great promise for you, dear Erika.
            """
        )
    }
} 