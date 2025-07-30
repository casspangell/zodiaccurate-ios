//
//  UserProfile.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation

// MARK: - User Profile Struct
public struct UserProfile: Codable {
    public let firstName: String
    public let birthDate: String
    public let birthTime: String
    public let zodiacSign: String
    public let responses: [(String, String, String)]
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(firstName: String = "", 
         birthDate: String = "", 
         birthTime: String = "", 
         zodiacSign: String = "", 
         responses: [(String, String, String)] = [], 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.responses = responses
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Convenience Initializers
    
    /// Initialize from UserDataModel
    public init(from userData: UserDataModel) {
        self.firstName = userData.firstName
        self.birthDate = userData.birthDate
        self.birthTime = userData.birthTime
        self.zodiacSign = userData.zodiacSign
        self.responses = userData.responseTuples.map { ($0.0, $0.1, $0.2) }
        self.createdAt = userData.createdAt
        self.updatedAt = userData.updatedAt
    }
    
    /// Initialize from UserDefaults
    public static func fromUserDefaults() -> UserProfile {
        return UserProfile(
            firstName: OnboardingDataAccess.firstName,
            birthDate: OnboardingDataAccess.birthDate,
            birthTime: OnboardingDataAccess.birthTime,
            zodiacSign: OnboardingDataAccess.zodiacSign,
            responses: OnboardingDataAccess.responses.map { ($0.0, $0.1, $0.2) }
        )
    }
    
    // MARK: - Codable Support for Tuple Arrays
    
    private enum CodingKeys: String, CodingKey {
        case firstName, birthDate, birthTime, zodiacSign, responses, createdAt, updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        birthDate = try container.decode(String.self, forKey: .birthDate)
        birthTime = try container.decode(String.self, forKey: .birthTime)
        zodiacSign = try container.decode(String.self, forKey: .zodiacSign)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Decode responses as array of dictionaries
        let responseDicts = try container.decode([[String: String]].self, forKey: .responses)
        responses = responseDicts.compactMap { dict in
            guard let question = dict["question"],
                  let key = dict["key"],
                  let answer = dict["answer"] else { return nil }
            return (question, key, answer)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(birthTime, forKey: .birthTime)
        try container.encode(zodiacSign, forKey: .zodiacSign)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode responses as array of dictionaries
        let responseDicts = responses.map { question, key, answer in
            ["question": question, "key": key, "answer": answer]
        }
        try container.encode(responseDicts, forKey: .responses)
    }
    
    // MARK: - Utility Methods
    
    /// Get a specific response
    public func getResponse(for key: String) -> (question: String, answer: String)? {
        guard let tuple = responses.first(where: { $0.1 == key }) else { return nil }
        return (question: tuple.0, answer: tuple.2)
    }
    
    /// Check if profile is complete
    public var isComplete: Bool {
        return !firstName.isEmpty && !birthDate.isEmpty && !zodiacSign.isEmpty
    }
    
    /// Get user's age based on birth date
    public var age: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        guard let birthDate = dateFormatter.date(from: birthDate) else { return nil }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
    
    /// Get formatted birth date
    public var formattedBirthDate: String {
        return birthDate
    }
    
    /// Get formatted birth time
    public var formattedBirthTime: String {
        return birthTime
    }
    
    /// Get combined birth date and time
    public var birthDateTime: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        guard let birthDate = dateFormatter.date(from: birthDate),
              let birthTime = timeFormatter.date(from: birthTime) else { return nil }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0, 
                           minute: timeComponents.minute ?? 0, 
                           second: 0, 
                           of: birthDate)
    }
}

