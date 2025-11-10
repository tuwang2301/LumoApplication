import SwiftUI

struct CustomizeScheduleView: View {
    let identifier: String
    
    // These bindings are connected to @AppStorage in SettingsView
    @Binding var hour: Int
    @Binding var minute: Int
    
    // This local state is just for the DatePicker
    @State private var date: Date
    
    @Environment(\.dismiss) var dismiss
    
    init(identifier: String, hour: Binding<Int>, minute: Binding<Int>) {
        self.identifier = identifier
        self._hour = hour
        self._minute = minute
        
        // Create a Date object from the initial hour/minute for the picker
        let initialDate = Calendar.current.date(bySettingHour: hour.wrappedValue, minute: minute.wrappedValue, second: 0, of: Date())!
        self._date = State(initialValue: initialDate)
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select a time",
                    selection: $date, // Picker updates the local 'date' state
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Button(action: {
                    // 1. Get new hour/minute from the picker's state
                    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                    let newHour = components.hour ?? self.hour
                    let newMinute = components.minute ?? self.minute
                    
                    // 2. Update the @AppStorage variables via the bindings
                    self.hour = newHour
                    self.minute = newMinute
                    
                    // 3. Reschedule the notification
                    NotificationManager.shared.scheduleNotification(
                        hour: newHour,
                        minute: newMinute,
                        identifier: identifier
                    )
                    
                    // 4. Close the sheet
                    dismiss()
                }) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Customize \(identifier.capitalized)")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .preferredColorScheme(.dark)
        }
    }
}
