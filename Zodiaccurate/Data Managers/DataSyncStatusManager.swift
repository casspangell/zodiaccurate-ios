//
//  DataSyncStatusManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 1/15/25.
//

import Foundation
import SwiftUI

@MainActor
class DataSyncStatusManager: ObservableObject {
    @Published var isSyncing: Bool = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var syncProgress: Double = 0.0
    @Published var currentOperation: String = ""
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error
    }
    
    func startSync() {
        isSyncing = true
        syncStatus = .syncing
        syncProgress = 0.0
        currentOperation = "Initializing..."
    }
    
    func updateProgress(_ progress: Double, operation: String) {
        syncProgress = progress
        currentOperation = operation
    }
    
    func completeSync() {
        isSyncing = false
        syncStatus = .success
        syncProgress = 1.0
        currentOperation = "Complete"
        
        // Reset to idle after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                syncStatus = .idle
                syncProgress = 0.0
                currentOperation = ""
            }
        }
    }
    
    func failSync(error: String) {
        isSyncing = false
        syncStatus = .error
        currentOperation = "Error: \(error)"
        
        // Reset to idle after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                syncStatus = .idle
                syncProgress = 0.0
                currentOperation = ""
            }
        }
    }
}
