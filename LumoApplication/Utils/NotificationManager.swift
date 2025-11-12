import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    // 1. --- REQUEST PERMISSION ---
    // This now *only* requests permission.
    // It no longer schedules any default reminders.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // 2. --- SCHEDULE A SPECIFIC NOTIFICATION ---
    // This is used by ReminderStore to schedule each reminder.
    func scheduleNotification(hour: Int, minute: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Lumo"
        content.body = "How are you feeling right now? Take a moment to explore your emotions."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // This trigger repeats daily at the specified time
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier, // The Reminder's UUID
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier): \(error.localizedDescription)")
            } else {
                print("Reminder \(identifier) scheduled for \(hour):\(String(format: "%02d", minute)).")
            }
        }
    }
    
    // 3. --- CANCEL A SPECIFIC NOTIFICATION ---
    // Used by ReminderStore when deleting a reminder.
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification: \(identifier)")
    }
        
    // 4. --- CANCEL ALL NOTIFICATIONS ---
    // Used when the user toggles "Enable Reminders" off.
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications cancelled.")
    }

}
