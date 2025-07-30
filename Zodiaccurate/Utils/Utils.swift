//
//  utils.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/5/25.
//

import Foundation
import SwiftUICore
import SwiftUI
import UIKit

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

// MARK: - Safe Area Utilities
/// Gets the safe area top inset using the modern UIWindowScene approach
/// - Returns: The safe area top inset as CGFloat, or 0 if unable to determine
func getSafeAreaTop() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
        return 0
    }
    return window.safeAreaInsets.top
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

// MARK: - Form Utilities

// MARK: - Validation Utilities
/// Validates email format using regex
/// - Parameter email: The email string to validate
/// - Returns: True if email format is valid, false otherwise
func validateEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

/// Password strength levels
enum PasswordStrength: String {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .yellow
        case .strong: return .green
        }
    }
}

/// Determines password strength level based on complexity requirements
/// - Parameter password: The password string to evaluate
/// - Returns: PasswordStrength enum value
func passwordStrengthLevel(_ password: String) -> PasswordStrength {
    let length = password.count >= 8
    let upper = password.range(of: "[A-Z]", options: .regularExpression) != nil
    let lower = password.range(of: "[a-z]", options: .regularExpression) != nil
    let number = password.range(of: "[0-9]", options: .regularExpression) != nil
    let strong = length && upper && lower && number && password.count >= 12
    if strong { return .strong }
    if length && upper && lower && number { return .medium }
    return .weak
}

/// Checks if password meets all requirements and returns individual requirement status
/// - Parameter password: The password string to evaluate
/// - Returns: Tuple containing (overallValid, [length, uppercase, lowercase, number])
func passwordMeetsRequirements(_ password: String) -> (Bool, [Bool]) {
    let length = password.count >= 8
    let upper = password.range(of: "[A-Z]", options: .regularExpression) != nil
    let lower = password.range(of: "[a-z]", options: .regularExpression) != nil
    let number = password.range(of: "[0-9]", options: .regularExpression) != nil
    return (length && upper && lower && number, [length, upper, lower, number])
}

// MARK: - Preference Keys

/// Preference key for header height
struct HeaderHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
