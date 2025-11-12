import SwiftUI

struct SettingsView: View {
    // 1. State
    @AppStorage("enableReminders") private var enableReminders = true
    
    // 2. The new source of truth for our list
    @StateObject private var reminderStore = ReminderStore()
    
    // 3. State to trigger the edit sheet
    @State private var reminderToEdit: Reminder?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Use a List for the modern iOS settings look
                List {
                    
                    // --- REMINDERS SECTION ---
                    Section(
                        header: Text("Reminders").font(.headline),
                        footer: Text("Add or edit your daily check-in reminders.")
                    ) {
                        // Main Enable Toggle
                        Toggle(isOn: $enableReminders) {
                            Text("Enable Reminders")
                                .font(.headline)
                        }
                        .tint(.green)
                        .onChange(of: enableReminders) {
                            if enableReminders {
                                // Request permission and sync
                                NotificationManager.shared.requestPermission()
                                reminderStore.syncNotifications()
                            } else {
                                // This requires 'cancelAllNotifications()' to exist
                                NotificationManager.shared.cancelAllNotifications()
                            }
                        }
                        
                        // --- DYNAMIC LIST OF REMINDERS ---
                        if enableReminders {
                            // We loop over the reminders in the store
                            ForEach($reminderStore.reminders) { $reminder in
                                reminderRow(for: $reminder)
                            }
                            .onDelete(perform: deleteReminder) // <-- Swipe to delete
                            
                            // --- "Add Reminder" BUTTON ---
                            Button(action: addReminder) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Reminder")
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                    
                    Section("App Settings") {
                        
                        NavigationLink(destination: AboutView()) {
                            SettingsRow(icon: "info.circle.fill", text: "About")
                        }
                        NavigationLink(destination: PrivacyAndPolicyView()) {
                            SettingsRow(icon: "questionmark.circle.fill", text: "Privacy & Policy") // Renamed
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .listStyle(.insetGrouped) // Use the inset grouped style
                .scrollContentBackground(.hidden) // Make list bg transparent
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
            }
        }
        .sheet(item: $reminderToEdit) { reminder in
            // This sheet is triggered when reminderToEdit is set
            // We must find the *binding* to the reminder in the store
            if let index = reminderStore.reminders.firstIndex(where: { $0.id == reminder.id }) {
                // Pass the binding to the sheet
                CustomizeScheduleView(reminder: $reminderStore.reminders[index])
                    .onDisappear {
                        // When the sheet is closed, save and sync all changes
                        reminderStore.save()
                    }
            }
        }
    }
    
    // --- View for a single reminder row ---
    func reminderRow(for reminder: Binding<Reminder>) -> some View {
        HStack {
            Text(reminder.wrappedValue.date(), style: .time)
                .font(.title3)
            
            Spacer()
            
            // This toggle updates the .isEnabled property on the Reminder
            Toggle("", isOn: reminder.isEnabled)
                .tint(.blue)
                .onChange(of: reminder.wrappedValue.isEnabled) {
                    // Save and sync when this toggle is flipped
                    reminderStore.save()
                }
        }
        .contentShape(Rectangle()) // Make the whole row tappable
        .onTapGesture {
            // Tapping the row (not the toggle) opens the edit sheet
            reminderToEdit = reminder.wrappedValue
        }
    }
    
    // --- Helper Functions for Add/Delete ---
    func addReminder() {
        let newReminder = Reminder(hour: 12, minute: 0) // Default to 12:00 PM
        reminderStore.add(reminder: newReminder)
        // Immediately open the edit sheet for the new reminder
        reminderToEdit = newReminder
    }
    
    func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminderStore.reminders[index]
            // This calls the store's delete, which also cancels the notification
            reminderStore.delete(reminder: reminder)
        }
    }

    // --- Reusable row for App Settings ---
    struct SettingsRow: View {
        var icon: String
        var text: String
        var value: String? = nil
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.gray.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
                
                Text(text)
                    .foregroundStyle(.white)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
#Preview {
    SettingsView()
}
