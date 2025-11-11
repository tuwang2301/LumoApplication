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
                                NotificationManager.shared.requestPermission()
                                reminderStore.syncNotifications()
                            } else {
                                NotificationManager.shared.cancelAllNotifications()
                            }
                        }
                        
                        // --- DYNAMIC LIST OF REMINDERS ---
                        if enableReminders {
                            ForEach($reminderStore.reminders) { $reminder in
                                reminderRow(for: $reminder)
                            }
                            .onDelete(perform: deleteReminder)
                            
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
                    
                    // --- APP SETTINGS SECTION ---
                    Section("App Settings") {
                        NavigationLink(destination: HelpAndSupportView()) {
                            SettingsRow(icon: "questionmark.circle.fill", text: "Help & Support")
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            SettingsRow(icon: "info.circle.fill", text: "About")
                        }
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
            }
        }
        .sheet(item: $reminderToEdit) { reminder in
            if let index = reminderStore.reminders.firstIndex(where: { $0.id == reminder.id }) {
                CustomizeScheduleView(reminder: $reminderStore.reminders[index])
                    .onDisappear {
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
            
            Toggle("", isOn: reminder.isEnabled)
                .tint(.blue)
                .onChange(of: reminder.wrappedValue.isEnabled) {
                    reminderStore.save()
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            reminderToEdit = reminder.wrappedValue
        }
    }
    
    // --- Helper Functions for Add/Delete ---
    func addReminder() {
        let newReminder = Reminder(hour: 12, minute: 0)
        reminderStore.add(reminder: newReminder)
        reminderToEdit = newReminder
    }
    
    func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminderStore.reminders[index]
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
