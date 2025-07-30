//
//  Stardust.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/3/25.
//

import Foundation
import SwiftUI

// MARK: - Stardust Manager
@MainActor
class StardustManager: ObservableObject {
    @Published var currentBalance: Int = 0
    @Published var totalEarned: Int = 0
    @Published var totalSpent: Int = 0
    @Published var recentTransactions: [StardustTransaction] = []
    @Published var isLoading: Bool = false
    
    init() {
        loadBalance()
    }
    
    // MARK: - Balance Management
    
    /// Load the current stardust balance (no longer saving to UserDefaults)
    func loadBalance() {
        // Set default values
        self.currentBalance = 0
        self.totalEarned = 0
        self.totalSpent = 0
        
        print("✅ StardustManager: Loaded balance - \(currentBalance) stardust")
        
        loadRecentTransactions()
    }
    
    /// Load recent transactions (no longer saving to UserDefaults)
    private func loadRecentTransactions() {
        self.recentTransactions = []
        print("🆕 StardustManager: No transactions found, starting fresh")
    }
    
    // MARK: - Transaction Methods
    
    /// Earn stardust
    func earnStardust(amount: Int, type: StardustTransactionType, description: String) {
        guard amount > 0 else {
            print("⚠️ StardustManager: Cannot earn negative or zero stardust")
            return
        }
        
        print("🪙 StardustManager: Earning \(amount) stardust (\(type.displayName))")
        
        let newBalance = currentBalance + amount
        currentBalance = newBalance
        totalEarned += amount
        
        print("💾 StardustManager: Updated balance - Balance: \(newBalance), Total Earned: \(totalEarned)")
        
        // Create transaction record
        let transaction = StardustTransaction(
            userId: nil,
            amount: amount,
            type: type,
            description: description,
            balanceAfterTransaction: newBalance
        )
        
        // Update recent transactions
        recentTransactions.insert(transaction, at: 0)
        if recentTransactions.count > 20 {
            recentTransactions = Array(recentTransactions.prefix(20))
        }
        
        print("✅ StardustManager: Successfully updated stardust data")
        print("📊 StardustManager: Current balance: \(currentBalance), Total earned: \(totalEarned)")
        
        // Trigger localized earning animation via notification
        NotificationCenter.default.post(
            name: .stardustEarned,
            object: nil,
            userInfo: [
                "amount": amount,
                "type": type
            ]
        )
        
        print("✅ StardustManager: Earned \(amount) stardust. New balance: \(newBalance)")
    }
    
    /// Spend stardust
    func spendStardust(amount: Int, type: StardustTransactionType, description: String) -> Bool {
        guard amount > 0 else {
            print("⚠️ StardustManager: Cannot spend negative or zero stardust")
            return false
        }
        
        guard currentBalance >= amount else {
            print("❌ StardustManager: Insufficient stardust. Balance: \(currentBalance), Required: \(amount)")
            return false
        }
        
        print("🪙 StardustManager: Spending \(amount) stardust (\(type.displayName))")
        
        let newBalance = currentBalance - amount
        currentBalance = newBalance
        totalSpent += amount
        
        print("💾 StardustManager: Updated balance - Balance: \(newBalance), Total Spent: \(totalSpent)")
        
        // Create transaction record
        let transaction = StardustTransaction(
            userId: nil,
            amount: -amount, // Negative for spending
            type: type,
            description: description,
            balanceAfterTransaction: newBalance
        )
        
        // Update recent transactions
        recentTransactions.insert(transaction, at: 0)
        if recentTransactions.count > 20 {
            recentTransactions = Array(recentTransactions.prefix(20))
        }
        
        print("✅ StardustManager: Successfully updated stardust data")
        print("📊 StardustManager: Current balance: \(currentBalance), Total spent: \(totalSpent)")
        
        print("✅ StardustManager: Spent \(amount) stardust. New balance: \(newBalance)")
        return true
    }
    
    /// Check if user can afford a purchase
    func canAfford(amount: Int) -> Bool {
        return currentBalance >= amount
    }
    
    // MARK: - Earning Methods
    
    /// Earn stardust for completing onboarding
    func earnOnboardingReward() {
        earnStardust(
            amount: 15,
            type: .achievement,
            description: "Completed onboarding and received your first horoscope"
        )
    }
    
    /// Earn stardust for daily login
    func earnDailyReward() -> Bool {
        let lastDailyReward = UserDefaults.standard.object(forKey: "lastDailyReward") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        if calendar.isDateInToday(lastDailyReward) {
            print("⚠️ StardustManager: Daily reward already claimed today")
            return false
        }
        
        let rewardAmount = calculateDailyRewardAmount()
        earnStardust(
            amount: rewardAmount,
            type: .dailyReward,
            description: "Daily login reward"
        )
        
        UserDefaults.standard.set(Date(), forKey: "lastDailyReward")
        return true
    }
    
    /// Calculate daily reward amount (increases with consecutive days)
    private func calculateDailyRewardAmount() -> Int {
        let consecutiveDays = UserDefaults.standard.integer(forKey: "consecutiveDailyRewards")
        let baseAmount = 10
        let bonusPerDay = 2
        return baseAmount + (consecutiveDays * bonusPerDay)
    }
    
    /// Earn stardust for generating a horoscope
    func earnHoroscopeGenerationReward() {
        earnStardust(
            amount: 25,
            type: .horoscopeGeneration,
            description: "Generated a personalized horoscope"
        )
    }
    
    /// Earn stardust for achievements
    func earnAchievementReward(achievementName: String, amount: Int = 100) {
        earnStardust(
            amount: amount,
            type: .achievement,
            description: "Achievement unlocked: \(achievementName)"
        )
    }
    
    // MARK: - Spending Methods
    
    /// Spend stardust to unlock premium features
    func unlockFeature(featureName: String, cost: Int) -> Bool {
        return spendStardust(
            amount: cost,
            type: .featureUnlock,
            description: "Unlocked feature: \(featureName)"
        )
    }
    
    /// Spend stardust for premium horoscope generation
    func generatePremiumHoroscope() -> Bool {
        return spendStardust(
            amount: 50,
            type: .horoscopeGeneration,
            description: "Generated premium horoscope"
        )
    }
    
    // MARK: - Utility Methods
    
    /// Save data to UserDefaults (no longer needed as data is saved immediately)
    private func saveContext() {
        // Data is saved immediately in earnStardust and spendStardust methods
        print("✅ StardustManager: Data already saved to UserDefaults")
    }
    
    /// Get transaction history
    func getTransactionHistory(limit: Int = 50) -> [StardustTransaction] {
        return Array(recentTransactions.prefix(limit))
    }
    
    /// Get statistics
    func getStatistics() -> (totalEarned: Int, totalSpent: Int, netBalance: Int) {
        return (totalEarned: totalEarned, totalSpent: totalSpent, netBalance: totalEarned - totalSpent)
    }
    
    /// Reset balance (for testing)
    func resetBalance() {
        print("🔄 StardustManager: Resetting balance...")
        currentBalance = 0
        totalEarned = 0
        totalSpent = 0
        
        recentTransactions = []
        
        print("✅ StardustManager: Balance reset to 0")
    }
}

// MARK: - Stardust Views

struct StardustBalanceView: View {
    @ObservedObject var stardustManager: StardustManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("\(stardustManager.currentBalance)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Stardust")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(stardustManager.totalEarned)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(stardustManager.totalSpent)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StardustTransactionView: View {
    let transaction: StardustTransaction
    
    var body: some View {
        HStack {
            Text(transaction.type.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.transactionDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.amount > 0 ? "+" : "")\(transaction.amount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.amount > 0 ? .green : .red)
                
                Text(transaction.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct StardustHistoryView: View {
    @ObservedObject var stardustManager: StardustManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)
                .padding(.horizontal)
            
            if stardustManager.recentTransactions.isEmpty {
                VStack {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(stardustManager.recentTransactions, id: \.id) { transaction in
                        StardustTransactionView(transaction: transaction)
                            .padding(.horizontal)
                        
                        if transaction.id != stardustManager.recentTransactions.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
} 
