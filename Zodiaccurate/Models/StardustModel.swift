//
//  StardustModel.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/3/25.
//

import Foundation
import SwiftData

// MARK: - Stardust Transaction Types
enum StardustTransactionType: String, CaseIterable, Codable {
    case earned = "earned"
    case spent = "spent"
    case bonus = "bonus"
    case dailyReward = "daily_reward"
    case horoscopeGeneration = "horoscope_generation"
    case featureUnlock = "feature_unlock"
    case referral = "referral"
    case achievement = "achievement"
    
    var displayName: String {
        switch self {
        case .earned: return "Earned"
        case .spent: return "Spent"
        case .bonus: return "Bonus"
        case .dailyReward: return "Daily Reward"
        case .horoscopeGeneration: return "Horoscope Generation"
        case .featureUnlock: return "Feature Unlock"
        case .referral: return "Referral Bonus"
        case .achievement: return "Achievement"
        }
    }
    
    var emoji: String {
        switch self {
        case .earned: return "✨"
        case .spent: return "💫"
        case .bonus: return "🌟"
        case .dailyReward: return "⭐"
        case .horoscopeGeneration: return "🔮"
        case .featureUnlock: return "🔓"
        case .referral: return "👥"
        case .achievement: return "🏆"
        }
    }
}

// MARK: - Stardust Transaction Model
@Model
class StardustTransaction {
    var id: UUID
    var userId: String?
    var amount: Int
    var type: StardustTransactionType
    var transactionDescription: String
    var timestamp: Date
    var balanceAfterTransaction: Int
    
    init(userId: String? = nil, amount: Int, type: StardustTransactionType, description: String, balanceAfterTransaction: Int) {
        self.id = UUID()
        self.userId = userId
        self.amount = amount
        self.type = type
        self.transactionDescription = description
        self.timestamp = Date()
        self.balanceAfterTransaction = balanceAfterTransaction
    }
}

// MARK: - Stardust Balance Model
@Model
class StardustBalance {
    var id: UUID
    var userId: String?
    var balance: Int
    var lastUpdated: Date
    var totalEarned: Int
    var totalSpent: Int
    
    init(userId: String? = nil, balance: Int = 0) {
        self.id = UUID()
        self.userId = userId
        self.balance = balance
        self.lastUpdated = Date()
        self.totalEarned = 0
        self.totalSpent = 0
    }
}

