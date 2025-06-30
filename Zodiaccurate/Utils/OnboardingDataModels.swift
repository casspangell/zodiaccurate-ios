//
//  OnboardingDataModels.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/30/25.
//

import Foundation

// MARK: - Onboarding Data Models

/// Simple struct for onboarding data passed to Firebase
public struct UserData {
    public var firstName: String
    public var birthDate: String
    public var birthTime: String
    public var zodiacSign: String
    public var responses: [(String, String, String)] // (question, key, answer)
    
    public init(firstName: String, birthDate: String, birthTime: String, zodiacSign: String, responses: [(String, String, String)]) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.responses = responses
    }
} 