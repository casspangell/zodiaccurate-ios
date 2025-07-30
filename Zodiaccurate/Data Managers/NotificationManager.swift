import Foundation
import UserNotifications

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
                
                if granted {
                    // Schedule daily horoscope when permission is granted
                    self.scheduleDailyHoroscope()
                }
            }
            
            if let error = error {
                print("🔔 Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleDailyHoroscope() {
        print("🔔 Scheduling daily horoscope...")
        // First check if we have permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("🔔 Notification permission not granted")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Your Daily Horoscope"
            content.body = "Discover what the stars have in store for you today! 🌟"
            content.sound = .default
            
            // Schedule for 9 AM daily
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyHoroscope", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("🔔 Error scheduling notification: \(error)")
                } else {
                    print("🔔 Daily horoscope notification scheduled successfully")
                }
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