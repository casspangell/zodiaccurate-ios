//
//  OnboardingDataModel.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation

// MARK: - Onboarding User Data
public struct Onboarding: Codable, Equatable {
    public var name: String?
    public var birthDate: Date?
    public var birthTime: Date?
    public var zodiacSign: String?
    public var consentGiven: Bool
    
    public init(name: String? = nil,
                birthDate: Date? = nil,
                birthTime: Date? = nil,
                zodiacSign: String? = nil,
                consentGiven: Bool = false) {
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.consentGiven = consentGiven
    }
}


// MARK: - Onboarding Response Structure
public struct OnboardingResponse: Codable, Equatable {
    public let question: String
    public let key: String
    public let answer: String
    
    public init(question: String, key: String, answer: String) {
        self.question = question
        self.key = key
        self.answer = answer
    }
    
    // Convenience initializer for pipe-separated string
    public init?(from pipeSeparatedString: String) {
        let components = pipeSeparatedString.split(separator: "|", maxSplits: 2)
        guard components.count == 3 else { return nil }
        self.question = String(components[0])
        self.key = String(components[1])
        self.answer = String(components[2])
    }
    
    // Convert to pipe-separated string for backward compatibility
    public var pipeSeparatedString: String {
        return "\(question)|\(key)|\(answer)"
    }
}
