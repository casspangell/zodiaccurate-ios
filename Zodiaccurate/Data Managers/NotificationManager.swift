//
//  NotificationManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - Notification Names
extension Notification.Name {
    static let stardustEarned = Notification.Name("stardustEarned")
    static let badgeAnimationTriggered = Notification.Name("badgeAnimationTriggered")
    static let consentAccepted = Notification.Name("consentAccepted")
    static let setHeaderBackgroundOpacity = Notification.Name("setHeaderBackgroundOpacity")
    static let setHeaderBackgroundZeroOpacity = Notification.Name("setHeaderBackgroundZeroOpacity")
    static let setHeaderFullOpacity = Notification.Name("setHeaderFullOpacity")
    static let triggerTransitionHeaderAnimation = Notification.Name("triggerTransitionHeaderAnimation")
}

// MARK: - Notification Manager
@MainActor
class NotificationManager: ObservableObject {
    @Published var isNotificationsEnabled = false
    
    init() {
        print("🔔 NotificationManager initialized")
        checkNotificationStatus()
    }
    
    func checkNotificationStatus() {
        print("🔔 Checking notification status...")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let wasEnabled = self.isNotificationsEnabled
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
                print("🔔 Notification status: \(settings.authorizationStatus.rawValue), isEnabled: \(self.isNotificationsEnabled)")
                
                if wasEnabled != self.isNotificationsEnabled {
                    print("🔔 Status changed from \(wasEnabled) to \(self.isNotificationsEnabled)")
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        print("🔔 Requesting notification permission...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                print("🔔 Permission request result: granted=\(granted)")
                self.isNotificationsEnabled = granted
            }
            
            if let error = error {
                print("🔔 Notification permission error: \(error)")
            }
        }
    }

    
    func cancelAllNotifications() {
        print("🔔 Cancelling all notifications...")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔔 All notifications cancelled")
    }
    
    func toggleNotifications() {
        print("🔔 Toggle notifications called, current state: \(isNotificationsEnabled)")
        if isNotificationsEnabled {
            cancelAllNotifications()
            isNotificationsEnabled = false
        } else {
            requestNotificationPermission()
        }
    }
} 
