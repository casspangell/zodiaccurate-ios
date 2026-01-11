//
//  DataSyncIndicator.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 1/15/25.
//

import SwiftUI

struct DataSyncIndicator: View {
    @ObservedObject var syncStatusManager: DataSyncStatusManager
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.deepBlue.opacity(0.3))
                .frame(width: 12, height: 12)
            
            // Status indicator dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                .opacity(pulseAnimation ? 0.6 : 1.0)
                .animation(
                    syncStatusManager.syncStatus == .syncing
                        ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
                        : .default,
                    value: pulseAnimation
                )
        }
        .onAppear {
            if syncStatusManager.syncStatus == .syncing {
                pulseAnimation = true
            }
        }
        .onChange(of: syncStatusManager.syncStatus) { oldValue, newValue in
            if newValue == .syncing {
                pulseAnimation = true
            } else {
                pulseAnimation = false
            }
        }
    }
    
    private var statusColor: Color {
        switch syncStatusManager.syncStatus {
        case .idle:
            return Color.gray.opacity(0.5)
        case .syncing:
            return Color.yellow
        case .success:
            return Color.accentGreen
        case .error:
            return Color.deepPink
        }
    }
}
