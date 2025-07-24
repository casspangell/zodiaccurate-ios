//
//  Stardust.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/3/25.
//

import Foundation
import SwiftData
import SwiftUI

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

// MARK: - Stardust Manager
@MainActor
class StardustManager: ObservableObject {
    @Published var currentBalance: Int = 0
    @Published var totalEarned: Int = 0
    @Published var totalSpent: Int = 0
    @Published var recentTransactions: [StardustTransaction] = []
    @Published var isLoading: Bool = false
    
    var modelContext: ModelContext
    private var balanceModel: StardustBalance?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        print("🪙 StardustManager: Initializing...")
        loadBalance()
        print("🪙 StardustManager: Initialization complete")
    }
    
    // MARK: - Balance Management
    
    /// Load the current stardust balance from Core Data
    func loadBalance() {
        print("🪙 StardustManager: Loading stardust balance...")
        
        let userId = UserDefaults.standard.string(forKey: "currentUserId") ?? 
                    UserDefaults.standard.string(forKey: "onboardingUUID")
        
        print("🪙 StardustManager: Using userId: \(userId ?? "nil")")
        
        let descriptor = FetchDescriptor<StardustBalance>(
            predicate: #Predicate<StardustBalance> { balance in
                balance.userId == userId
            }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            print("🪙 StardustManager: Found \(results.count) balance records")
            
            if let balance = results.first {
                self.balanceModel = balance
                self.currentBalance = balance.balance
                self.totalEarned = balance.totalEarned
                self.totalSpent = balance.totalSpent
                print("✅ StardustManager: Loaded balance - \(balance.balance) stardust")
            } else {
                // Create new balance for user
                print("🆕 StardustManager: Creating new balance for user")
                let newBalance = StardustBalance(userId: userId, balance: 0)
                modelContext.insert(newBalance)
                self.balanceModel = newBalance
                self.currentBalance = 0
                print("🆕 StardustManager: Created new balance for user")
            }
            
            loadRecentTransactions()
        } catch {
            print("❌ StardustManager: Error loading balance: \(error)")
            // Set default values on error
            self.currentBalance = 0
            self.totalEarned = 0
            self.totalSpent = 0
        }
    }
    
    /// Load recent transactions
    private func loadRecentTransactions() {
        print("🪙 StardustManager: Loading recent transactions...")
        
        let userId = UserDefaults.standard.string(forKey: "currentUserId") ?? 
                    UserDefaults.standard.string(forKey: "onboardingUUID")
        
        var descriptor = FetchDescriptor<StardustTransaction>(
            predicate: #Predicate<StardustTransaction> { transaction in
                transaction.userId == userId
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 20 // Load last 20 transactions
        
        do {
            let results = try modelContext.fetch(descriptor)
            self.recentTransactions = results
            print("✅ StardustManager: Loaded \(results.count) recent transactions")
        } catch {
            print("❌ StardustManager: Error loading transactions: \(error)")
        }
    }
    
    // MARK: - Transaction Methods
    
    /// Earn stardust
    func earnStardust(amount: Int, type: StardustTransactionType, description: String) {
        guard amount > 0 else {
            print("⚠️ StardustManager: Cannot earn negative or zero stardust")
            return
        }
        
        print("🪙 StardustManager: Earning \(amount) stardust (\(type.displayName))")
        
        do {
            let newBalance = currentBalance + amount
            currentBalance = newBalance
            totalEarned += amount
            
            // Update balance model
            balanceModel?.balance = newBalance
            balanceModel?.totalEarned = totalEarned
            balanceModel?.lastUpdated = Date()
            
            // Create transaction record
            let transaction = StardustTransaction(
                userId: UserDefaults.standard.string(forKey: "currentUserId") ?? 
                       UserDefaults.standard.string(forKey: "onboardingUUID"),
                amount: amount,
                type: type,
                description: description,
                balanceAfterTransaction: newBalance
            )
            
            modelContext.insert(transaction)
            
            // Update recent transactions
            recentTransactions.insert(transaction, at: 0)
            if recentTransactions.count > 20 {
                recentTransactions = Array(recentTransactions.prefix(20))
            }
            
            saveContext()
            
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
        } catch {
            print("❌ StardustManager: Error earning stardust: \(error)")
        }
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
        
        // Update balance model
        balanceModel?.balance = newBalance
        balanceModel?.totalSpent = totalSpent
        balanceModel?.lastUpdated = Date()
        
        // Create transaction record
        let transaction = StardustTransaction(
            userId: UserDefaults.standard.string(forKey: "currentUserId") ?? 
                   UserDefaults.standard.string(forKey: "onboardingUUID"),
            amount: -amount, // Negative for spending
            type: type,
            description: description,
            balanceAfterTransaction: newBalance
        )
        
        modelContext.insert(transaction)
        
        // Update recent transactions
        recentTransactions.insert(transaction, at: 0)
        if recentTransactions.count > 20 {
            recentTransactions = Array(recentTransactions.prefix(20))
        }
        
        saveContext()
        
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
            amount: 50,
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
    
    /// Save context to Core Data
    private func saveContext() {
        do {
            try modelContext.save()
            print("✅ StardustManager: Context saved successfully")
        } catch {
            print("❌ StardustManager: Error saving context: \(error)")
        }
    }
    
    /// Get transaction history
    func getTransactionHistory(limit: Int = 50) -> [StardustTransaction] {
        let userId = UserDefaults.standard.string(forKey: "currentUserId") ?? 
                    UserDefaults.standard.string(forKey: "onboardingUUID")
        
        var descriptor = FetchDescriptor<StardustTransaction>(
            predicate: #Predicate<StardustTransaction> { transaction in
                transaction.userId == userId
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("❌ StardustManager: Error loading transaction history: \(error)")
            return []
        }
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
        
        balanceModel?.balance = 0
        balanceModel?.totalEarned = 0
        balanceModel?.totalSpent = 0
        balanceModel?.lastUpdated = Date()
        
        recentTransactions = []
        saveContext()
        
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