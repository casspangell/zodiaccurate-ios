//
//  OnboardingDataModel.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation

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

// MARK: - Onboarding Step Keys
public enum OnboardingStepKey: String, CaseIterable {
    case name = "name"
    case birthDate = "birthDate"
    case birthTime = "birthTime"
    case zodiacSign = "zodiacSign"
    case consent = "consent"
    
    public var displayName: String {
        switch self {
        case .name:
            return "Name"
        case .birthDate:
            return "Birth Date"
        case .birthTime:
            return "Birth Time"
        case .zodiacSign:
            return "Zodiac Sign"
        case .consent:
            return "Consent"
        }
    }
}

// MARK: - Onboarding Progress
public struct OnboardingProgress {
    public let completedSteps: Set<OnboardingStepKey>
    public let totalSteps: Int
    
    public var progressPercentage: Double {
        return Double(completedSteps.count) / Double(totalSteps)
    }
    
    public var isComplete: Bool {
        return completedSteps.count == totalSteps
    }
    
    public init(completedSteps: Set<OnboardingStepKey> = [], totalSteps: Int = OnboardingStepKey.allCases.count) {
        self.completedSteps = completedSteps
        self.totalSteps = totalSteps
    }
}

// MARK: - Onboarding User Data
public struct OnboardingUserData: Codable, Equatable {
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
    
    // MARK: - Convenience Methods
    
    /// Returns the user's age based on birth date
    public var age: Int? {
        guard let birthDate = birthDate else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year
    }
    
    /// Returns formatted birth date string
    public var formattedBirthDate: String? {
        guard let birthDate = birthDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
    
    /// Returns formatted birth time string
    public var formattedBirthTime: String? {
        guard let birthTime = birthTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: birthTime)
    }
    
    /// Returns combined birth date and time
    public var birthDateTime: Date? {
        guard let birthDate = birthDate, let birthTime = birthTime else { return nil }
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0, 
                           minute: timeComponents.minute ?? 0, 
                           second: 0, 
                           of: birthDate)
    }
    
    /// Returns the onboarding progress for this user data
    public var progress: OnboardingProgress {
        var completedSteps: Set<OnboardingStepKey> = []
        
        if name != nil && !name!.isEmpty {
            completedSteps.insert(.name)
        }
        if birthDate != nil {
            completedSteps.insert(.birthDate)
        }
        if birthTime != nil {
            completedSteps.insert(.birthTime)
        }
        if zodiacSign != nil && !zodiacSign!.isEmpty {
            completedSteps.insert(.zodiacSign)
        }
        if consentGiven {
            completedSteps.insert(.consent)
        }
        
        return OnboardingProgress(completedSteps: completedSteps)
    }
    
    /// Returns true if all required fields are completed
    public var isComplete: Bool {
        return progress.isComplete
    }
    
    /// Returns the number of completed steps
    public var completedStepCount: Int {
        return progress.completedSteps.count
    }
}

// MARK: - User Data (Temporary struct for onboarding)
public struct UserData {
    public var firstName: String
    public var birthDate: String
    public var birthTime: String
    public var zodiacSign: String
    public var responses: [(String, String, String)] // (question, key, answer)
    
    public init(firstName: String = "", 
                birthDate: String = "", 
                birthTime: String = "", 
                zodiacSign: String = "", 
                responses: [(String, String, String)] = []) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.responses = responses
    }
    
    /// Convert UserData to OnboardingUserData
    public func toOnboardingUserData() -> OnboardingUserData {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        let birthDate = dateFormatter.date(from: birthDate)
        let birthTime = timeFormatter.date(from: birthTime)
        
        return OnboardingUserData(
            name: firstName.isEmpty ? nil : firstName,
            birthDate: birthDate,
            birthTime: birthTime,
            zodiacSign: zodiacSign.isEmpty ? nil : zodiacSign,
            consentGiven: false // Default to false, will be set during onboarding
        )
    }
} 