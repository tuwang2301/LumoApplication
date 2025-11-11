import SwiftUI

struct HelpAndSupportView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    faqItem(
                        question: "How do I explore my emotions?",
                        // This answer is updated to be clearer
                        answer: "You can see what emotions you are feeling by tapping on one of the bubbles in the 'Explore' tab. This will take you to the summary page where you can confirm your entry."
                    )
                    
                    // --- THIS FAQ IS UPDATED ---
                    faqItem(
                        question: "How do I customize reminders?",
                        answer: "In Settings, you can tap 'Add Reminder' to create a new one. You can also tap on any existing reminder to edit its time, or swipe left to delete it."
                    )
                    // --- END OF UPDATE ---
                    
                    faqItem(
                        question: "Is my data private?",
                        answer: "Yes. All your entries are stored securely on your device. We do not have access to your personal emotion data."
                    )
                }
                .padding()
            }
            // --- THIS TITLE IS RENAMED ---
            .navigationTitle("FAQ")
            .preferredColorScheme(.dark)
        }
    }
    
    // Helper view for a single FAQ item
    func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(answer)
                .font(.body)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    NavigationView {
        HelpAndSupportView()
    }
}
