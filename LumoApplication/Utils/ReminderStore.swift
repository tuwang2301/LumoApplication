import Foundation
import SwiftUI // Keep this if you have it
import Combine // <-- ADD THIS LINE

class ReminderStore: ObservableObject {
//...
    @Published var reminders: [Reminder] = []
    
    private let userDefaultsKey = "customReminders"
    
    init() {
        load()
    }
    
    // 1. --- Persistence (Load/Save) ---
    
    func load() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        if let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: data) {
            self.reminders = decodedReminders
        }
    }
    
    func save() {
        if let encodedData = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
        // Sync notifications any time we save
        syncNotifications()
    }
    
    // 2. --- CRUD (Create, Read, Update, Delete) ---
    
    func add(reminder: Reminder) {
        reminders.append(reminder)
        save()
    }
    
    func update(reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        reminders[index] = reminder
        save()
    }
    
    func delete(reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        // We must also cancel the notification for the one we just deleted
        NotificationManager.shared.cancelNotification(identifier: reminder.id.uuidString)
        save()
    }
    
    // 3. --- Notification Syncing ---
    
    // Syncs all notifications with our stored list
    func syncNotifications() {
        // First, clear all previously scheduled reminders
        NotificationManager.shared.cancelAllNotifications()
        
        // Then, re-schedule only the enabled ones
        for reminder in reminders where reminder.isEnabled {
            NotificationManager.shared.scheduleNotification(
                hour: reminder.hour,
                minute: reminder.minute,
                identifier: reminder.id.uuidString // Use the reminder's ID
            )
        }
    }
}
