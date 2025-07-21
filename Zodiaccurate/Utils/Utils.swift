//
//  utils.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import Foundation
import SwiftUICore
import SwiftUI

func getDayOfWeek(date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter.string(from: date)
}

func getFormattedDate(date: Date = Date()) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy"
    return formatter.string(from: date)
}

// MARK: - Zodiac Sign Utilities
/// Determines the zodiac sign from a date string
/// - Parameter dateString: The date string in medium format (e.g., "Jan 15, 1990")
/// - Returns: The zodiac sign as a string, or "Unknown" if unable to determine
func determineZodiacSign(from dateString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    
    if let date = formatter.date(from: dateString) {
        do {
            let zodiacSign = try ZodiacUtility.getZodiacSign(from: date)
            return zodiacSign.rawValue
        } catch {
            print("Error determining zodiac sign: \(error)")
            return "Unknown"
        }
    }
    
    return "Unknown"
}

/// Determines the zodiac sign and asset name from a date string
/// - Parameter dateString: The date string in medium format (e.g., "Jan 15, 1990")
/// - Returns: A tuple containing (zodiacSign, assetName), or ("Unknown", "logo") if unable to determine
func determineZodiacSignAndAsset(from dateString: String) -> (zodiacSign: String, assetName: String) {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    
    if let date = formatter.date(from: dateString) {
        do {
            let zodiacSign = try ZodiacUtility.getZodiacSign(from: date)
            return (zodiacSign.rawValue, zodiacSign.assetName)
        } catch {
            print("Error determining zodiac sign: \(error)")
            return ("Unknown", "logo")
        }
    }
    
    return ("Unknown", "logo")
}



// MARK: - Text Utilities
/// Personalizes a message by replacing placeholders with actual values
/// - Parameters:
///   - message: The message template containing placeholders
///   - name: The name to replace {name} placeholder with
/// - Returns: The personalized message
func personalizeMessage(_ message: String, with name: String) -> String {
    // If name is empty, remove the {name} placeholder and clean up spacing
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return message.replacingOccurrences(of: "{name}", with: "")
            .replacingOccurrences(of: "  ", with: " ") // Remove double spaces
            .replacingOccurrences(of: " .", with: ".") // Fix spacing before periods
            .replacingOccurrences(of: " ,", with: ",") // Fix spacing before commas
            .replacingOccurrences(of: " ...", with: "...") // Fix spacing before ellipsis
            .trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        return message.replacingOccurrences(of: "{name}", with: name)
    }
}
