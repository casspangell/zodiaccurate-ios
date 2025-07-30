//
//  UserProfileManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 6/19/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserProfileManager: ObservableObject {
    @Published var profile: UserProfile?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProfile()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadProfile()
    }
    
    private func loadProfile() {
        // Load from SwiftData first
        let descriptor = FetchDescriptor<UserDataModel>()
        do {
            let results = try modelContext.fetch(descriptor)
            if let userData = results.first {
                profile = UserProfile(from: userData)
                return
            }
        } catch {
            print("❌ Error loading user data from SwiftData: \(error)")
        }
        
        // Fallback to UserDefaults
        profile = UserProfile.fromUserDefaults()
    }
    
    // Get user's zodiac sign
    var zodiacSign: String {
        return profile?.zodiacSign ?? OnboardingDataAccess.zodiacSign
    }
    
    // Get user's name
    var firstName: String {
        return profile?.firstName ?? OnboardingDataAccess.firstName
    }
    
    // Get user's birth date
    var birthDate: String {
        return profile?.birthDate ?? OnboardingDataAccess.birthDate
    }
    
    // Get user's birth time
    var birthTime: String {
        return profile?.birthTime ?? OnboardingDataAccess.birthTime
    }
    
    // Get user's responses
    var responses: [(String, String, String)] {
        return profile?.responses ?? OnboardingDataAccess.responses
    }
    
    // Get a specific response
    func getResponse(for key: String) -> (question: String, answer: String)? {
        guard let tuple = responses.first(where: { $0.1 == key }) else { return nil }
        return (question: tuple.0, answer: tuple.2)
    }
    
    // Get just the answer for a key (backward compatibility)
    func getAnswer(for key: String) -> String? {
        return getResponse(for: key)?.answer
    }
    
    // Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        return OnboardingDataAccess.hasCompletedOnboarding
    }
    
    // Get zodiac sign asset name for UI
    var zodiacSignAssetName: String {
        let sign = zodiacSign.lowercased()
        switch sign {
        case "aries": return "Aries"
        case "taurus": return "Taurus"
        case "gemini": return "Gemini"
        case "cancer": return "Cancer"
        case "leo": return "Leo"
        case "virgo": return "Virgo"
        case "libra": return "Libra"
        case "scorpio": return "Scorpio"
        case "sagittarius": return "Saggitarius"
        case "capricorn": return "Capricorn"
        case "aquarius": return "Aquarius"
        case "pisces": return "Pisces"
        default: return "logo"
        }
    }
}

// Subscription Status View Component
struct SubscriptionStatusView: View {
    let status: SubscriptionStatus
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
                .shadow(color: status.color.opacity(0.5), radius: 4, x: 0, y: 2)
            Text(status.rawValue)
                .font(.dmSansMedium(size: 10))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// Subscription Status Enum
enum SubscriptionStatus: String, CaseIterable {
    case subscribed = "Subscribed"
    case trial = "Trial"
    case expired = "Expired"
    
    var color: Color {
        switch self {
        case .subscribed:
            return .green
        case .trial:
            return .orange
        case .expired:
            return .red
        }
    }
} 
