import SwiftUI

struct SettingsView: View {
    // 1. State
    @AppStorage("enableReminders") private var enableReminders = true
    
    // 2. AppStorage for each reminder time
    @AppStorage("morningHour") private var morningHour = 9
    @AppStorage("morningMinute") private var morningMinute = 0
    
    @AppStorage("afternoonHour") private var afternoonHour = 14
    @AppStorage("afternoonMinute") private var afternoonMinute = 0
    
    @AppStorage("eveningHour") private var eveningHour = 20
    @AppStorage("eveningMinute") private var eveningMinute = 0
    
    // 3. State to trigger the sheet
    @State private var customizingIdentifier: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        reminderSection
                        
                        Text("App Settings")
                            .font(.headline)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                        
                        appSettingsSection
                        
                        Spacer()
                        
                        Text("Version 1.1.0 Lumo")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.top)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
            }
        }
        // 4. Sheet Modifier
        .sheet(item: $customizingIdentifier) { identifier in
            switch identifier {
            case "morning":
                CustomizeScheduleView(
                    identifier: "morning",
                    hour: $morningHour, // Pass binding
                    minute: $morningMinute // Pass binding
                )
            case "afternoon":
                CustomizeScheduleView(
                    identifier: "afternoon",
                    hour: $afternoonHour,
                    minute: $afternoonMinute
                )
            case "evening":
                CustomizeScheduleView(
                    identifier: "evening",
                    hour: $eveningHour,
                    minute: $eveningMinute
                )
            default:
                EmptyView()
            }
        }
    }
    
    // --- REMINDERS VIEW ---
    var reminderSection: some View {
        VStack(spacing: 16) {
            Toggle(isOn: $enableReminders) {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.purple.opacity(0.6), in: Circle())
                    
                    VStack(alignment: .leading) {
                        Text("Enable Reminders")
                        Text("Stay connected with your feelings")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            .tint(.green)
            .onChange(of: enableReminders) {
                if enableReminders {
                    // 1. Request permission (which also schedules defaults)
                    NotificationManager.shared.requestPermission()
                } else {
                    // 2. Cancel all notifications
                    NotificationManager.shared.cancelAllNotifications()
                }
            }
            
            // --- PRESET TIMES (Only show if reminders are on) ---
            if enableReminders {
                presetTimeRow(
                    icon: "sun.max.fill",
                    label: "Morning",
                    hour: morningHour, // Pass value
                    minute: morningMinute // Pass value
                )
                .onTapGesture {
                    customizingIdentifier = "morning" // Set identifier to show sheet
                }
                
                presetTimeRow(
                    icon: "cloud.sun.fill",
                    label: "Afternoon",
                    hour: afternoonHour,
                    minute: afternoonMinute
                )
                .onTapGesture {
                    customizingIdentifier = "afternoon"
                }
                
                presetTimeRow(
                    icon: "moon.fill",
                    label: "Evening",
                    hour: eveningHour,
                    minute: eveningMinute
                )
                .onTapGesture {
                    customizingIdentifier = "evening"
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    // --- APP SETTINGS VIEW ---
    var appSettingsSection: some View {
        VStack(spacing: 8) {
            // REMOVED: Language row is gone
            
            // 2. Help & Support (Links to new HelpAndSupportView)
            NavigationLink(destination: HelpAndSupportView()) {
                SettingsRow(icon: "questionmark.circle.fill", text: "Help & Support")
            }
            
            // 3. About (Navigates to AboutView)
            NavigationLink(destination: AboutView()) {
                SettingsRow(icon: "info.circle.fill", text: "About")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    // --- Helper for formatting time ---
    private func formatTime(hour: Int, minute: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // --- Modified Row View ---
    func presetTimeRow(icon: String, label: String, hour: Int, minute: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.yellow)
            Text(label)
                .foregroundStyle(.white)
            Spacer()
            // Text is now dynamic and formatted
            Text(formatTime(hour: hour, minute: minute))
                .foregroundStyle(.gray)
        }
        .padding(12)
        .background(.white.opacity(0.05))
        .cornerRadius(10)
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
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 8)
        }
    }
}

// Make String Identifiable so it can be used in .sheet(item:)
extension String: @retroactive Identifiable {
    public var id: String { self }
}

#Preview {
    SettingsView()
}
