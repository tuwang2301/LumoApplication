import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    // 1. Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Schedule the default reminders
                self.scheduleDefaultReminders()
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. Schedule a Specific Notification
    func scheduleNotification(hour: Int, minute: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Lumo"
        content.body = "How are you feeling right now? Take a moment to explore your emotions."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier, // "morning", "afternoon", etc.
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier): \(error.localizedDescription)")
            } else {
                print("\(identifier) reminder scheduled for \(hour):\(String(format: "%02d", minute)).")
            }
        }
    }
    
    // 3. Schedule Defaults (called when permission is first granted)
    func scheduleDefaultReminders() {
        scheduleNotification(hour: 9, minute: 0, identifier: "morning")
        scheduleNotification(hour: 14, minute: 0, identifier: "afternoon")
        scheduleNotification(hour: 20, minute: 0, identifier: "evening")
    }
    
    func cancelNotification(identifier: String) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            print("Cancelled notification: \(identifier)")
        }
        
        // 5. --- CANCEL ALL NOTIFICATIONS ---
        func cancelAllNotifications() {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            print("All pending notifications cancelled.")
        }

    }
