import Foundation

// This struct will be used to store our custom reminders
// Codable: So we can save it to UserDefaults
// Identifiable/Hashable: So we can use it in Lists and for sheets
struct Reminder: Codable, Identifiable, Hashable {
    var id = UUID()
    var hour: Int
    var minute: Int
    var isEnabled: Bool = true
    
    // Helper to get a Date object from the hour/minute
    func date() -> Date {
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
