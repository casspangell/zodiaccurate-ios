//
//  Zodiac.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import UIKit

/// Represents the 12 zodiac signs with their associated properties
enum ZodiacSign: String, CaseIterable {
    case aries = "Aries"
    case taurus = "Taurus"
    case gemini = "Gemini"
    case cancer = "Cancer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn = "Capricorn"
    case aquarius = "Aquarius"
    case pisces = "Pisces"
    
    /// Asset name for the zodiac sign image
    var assetName: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Saggitarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }
    
    /// Returns the UIImage for the zodiac sign from Assets
    var image: UIImage? {
        return UIImage(named: assetName)
    }
    
    /// Unicode symbol for each zodiac sign (kept for backwards compatibility)
    var symbol: String {
        switch self {
        case .aries: return "♈︎"
        case .taurus: return "♉︎"
        case .gemini: return "♊︎"
        case .cancer: return "♋︎"
        case .leo: return "♌︎"
        case .virgo: return "♍︎"
        case .libra: return "♎︎"
        case .scorpio: return "♏︎"
        case .sagittarius: return "♐︎"
        case .capricorn: return "♑︎"
        case .aquarius: return "♒︎"
        case .pisces: return "♓︎"
        }
    }
    
    /// Date range description for each zodiac sign
    var dateRange: String {
        switch self {
        case .aries: return "March 21 - April 19"
        case .taurus: return "April 20 - May 20"
        case .gemini: return "May 21 - June 20"
        case .cancer: return "June 21 - July 22"
        case .leo: return "July 23 - August 22"
        case .virgo: return "August 23 - September 22"
        case .libra: return "September 23 - October 22"
        case .scorpio: return "October 23 - November 21"
        case .sagittarius: return "November 22 - December 21"
        case .capricorn: return "December 22 - January 19"
        case .aquarius: return "January 20 - February 18"
        case .pisces: return "February 19 - March 20"
        }
    }
    
    /// Display name with symbol
    var displayName: String {
        return "\(symbol) \(rawValue)"
    }
}

/// Custom error types for zodiac-related operations
enum ZodiacError: Error, LocalizedError {
    case invalidMonth
    case invalidDay
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .invalidMonth:
            return "Month must be between 1 and 12"
        case .invalidDay:
            return "Day must be between 1 and 31"
        case .invalidDate:
            return "Invalid date provided"
        }
    }
}

/// Utility class for zodiac sign operations
struct ZodiacUtility {
    
    /// Determines the zodiac sign based on month and day
    /// - Parameters:
    ///   - month: Month as integer (1-12)
    ///   - day: Day as integer (1-31)
    /// - Returns: The corresponding ZodiacSign
    /// - Throws: ZodiacError for invalid inputs
    static func getZodiacSign(month: Int, day: Int) throws -> ZodiacSign {
        // Validate input ranges
        guard month >= 1 && month <= 12 else {
            throw ZodiacError.invalidMonth
        }
        
        guard day >= 1 && day <= 31 else {
            throw ZodiacError.invalidDay
        }
        
        // Validate specific date combinations
        let daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] // Including leap year Feb
        guard day <= daysInMonth[month - 1] else {
            throw ZodiacError.invalidDate
        }
        
        // Determine zodiac sign based on date ranges
        switch (month, day) {
        case (3, 21...31), (4, 1...19):
            return .aries
        case (4, 20...30), (5, 1...20):
            return .taurus
        case (5, 21...31), (6, 1...20):
            return .gemini
        case (6, 21...30), (7, 1...22):
            return .cancer
        case (7, 23...31), (8, 1...22):
            return .leo
        case (8, 23...31), (9, 1...22):
            return .virgo
        case (9, 23...30), (10, 1...22):
            return .libra
        case (10, 23...31), (11, 1...21):
            return .scorpio
        case (11, 22...30), (12, 1...21):
            return .sagittarius
        case (12, 22...31), (1, 1...19):
            return .capricorn
        case (1, 20...31), (2, 1...18):
            return .aquarius
        case (2, 19...29), (3, 1...20):
            return .pisces
        default:
            throw ZodiacError.invalidDate
        }
    }
    
    /// Convenience method to get zodiac sign from a Date object
    /// - Parameter date: Date object
    /// - Returns: The corresponding ZodiacSign
    /// - Throws: ZodiacError for invalid dates
    static func getZodiacSign(from date: Date) throws -> ZodiacSign {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return try getZodiacSign(month: month, day: day)
    }
    
    /// Get all zodiac signs with their images and date ranges
    /// - Returns: Array of tuples containing sign info
    static func getAllZodiacSigns() -> [(sign: ZodiacSign, image: UIImage?, dateRange: String)] {
        return ZodiacSign.allCases.map { sign in
            (sign: sign, image: sign.image, dateRange: sign.dateRange)
        }
    }
    
    /// Get all zodiac signs with their symbols and date ranges (backwards compatibility)
    /// - Returns: Array of tuples containing sign info with Unicode symbols
    static func getAllZodiacSignsWithSymbols() -> [(sign: ZodiacSign, symbol: String, dateRange: String)] {
        return ZodiacSign.allCases.map { sign in
            (sign: sign, symbol: sign.symbol, dateRange: sign.dateRange)
        }
    }
    
    /// Check if two dates have the same zodiac sign
    /// - Parameters:
    ///   - date1: First date
    ///   - date2: Second date
    /// - Returns: Boolean indicating if they share the same zodiac sign
    static func haveSameZodiacSign(_ date1: Date, _ date2: Date) -> Bool {
        do {
            let sign1 = try getZodiacSign(from: date1)
            let sign2 = try getZodiacSign(from: date2)
            return sign1 == sign2
        } catch {
            return false
        }
    }
}

// MARK: - Extensions

extension Date {
    /// Convenience property to get zodiac sign from Date
    var zodiacSign: ZodiacSign? {
        return try? ZodiacUtility.getZodiacSign(from: self)
    }
    
    /// Convenience property to get zodiac sign image from Date
    var zodiacImage: UIImage? {
        return zodiacSign?.image
    }
}

// MARK: - Example Usage and Tests

#if DEBUG
extension ZodiacUtility {
    /// Test function to verify zodiac date boundaries
    static func runTests() {
        print("🔮 Running Zodiac Utility Tests...")
        
        // Test boundary dates
        let testCases: [(month: Int, day: Int, expected: ZodiacSign)] = [
            (3, 21, .aries),    // Aries start
            (4, 19, .aries),    // Aries end
            (4, 20, .taurus),   // Taurus start
            (5, 20, .taurus),   // Taurus end
            (12, 22, .capricorn), // Capricorn start
            (1, 19, .capricorn),  // Capricorn end
            (1, 20, .aquarius),   // Aquarius start
            (2, 18, .aquarius),   // Aquarius end
            (7, 4, .cancer),      // July 4th
            (10, 31, .scorpio),   // Halloween
            (12, 25, .capricorn)  // Christmas
        ]
        
        var passedTests = 0
        let totalTests = testCases.count
        
        for testCase in testCases {
            do {
                let result = try getZodiacSign(month: testCase.month, day: testCase.day)
                if result == testCase.expected {
                    let imageStatus = result.image != nil ? "🖼️" : "❓"
                    print("✅ \(testCase.month)/\(testCase.day) = \(result.displayName) \(imageStatus)")
                    passedTests += 1
                } else {
                    print("❌ \(testCase.month)/\(testCase.day) = \(result.displayName), expected \(testCase.expected.displayName)")
                }
            } catch {
                print("❌ Error testing \(testCase.month)/\(testCase.day): \(error)")
            }
        }
        
        print("\n📊 Test Results: \(passedTests)/\(totalTests) passed")
        
        // Test error cases
        print("\n🚫 Testing Error Cases:")
        
        let errorCases: [(month: Int, day: Int)] = [
            (0, 15),   // Invalid month
            (13, 15),  // Invalid month
            (6, 0),    // Invalid day
            (6, 32),   // Invalid day
            (2, 30)    // Invalid date (Feb 30)
        ]
        
        for errorCase in errorCases {
            do {
                let _ = try getZodiacSign(month: errorCase.month, day: errorCase.day)
                print("❌ Should have thrown error for \(errorCase.month)/\(errorCase.day)")
            } catch {
                print("✅ Correctly caught error for \(errorCase.month)/\(errorCase.day): \(error.localizedDescription)")
            }
        }
    }
}
#endif
