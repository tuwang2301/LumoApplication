import SwiftUI

struct CustomizeScheduleView: View {
    // This view now edits a single Reminder object
    @Binding var reminder: Reminder
    
    // Local state for the picker
    @State private var date: Date
    
    @Environment(\.dismiss) var dismiss
    
    init(reminder: Binding<Reminder>) {
        self._reminder = reminder
        // Set the picker's state from the reminder we're editing
        self._date = State(initialValue: reminder.wrappedValue.date())
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select a time",
                    selection: $date,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Reminder")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    // 1. Get components from the local date picker
                    let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                    
                    // 2. Update the Reminder object via its binding
                    reminder.hour = components.hour ?? 9
                    reminder.minute = components.minute ?? 0
                    
                    // 3. Close the sheet
                    dismiss()
                }
            )
            .preferredColorScheme(.dark)
        }
    }
}
