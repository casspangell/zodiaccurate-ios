//
//  UserProfile.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData

// MARK: - User Model
@Model
public class User {
    public var firstName: String
    public var birthDate: String
    public var birthTime: String
    public var zodiacSign: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(firstName: String = "",
         birthDate: String = "",
         birthTime: String = "",
         zodiacSign: String = "",
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.firstName = firstName
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.zodiacSign = zodiacSign
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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

