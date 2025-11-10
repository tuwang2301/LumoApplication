import SwiftUI

struct HelpAndSupportView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    faqItem(
                        question: "How do I explore my emotions?",
                        answer: "You can see what emotions you are feeling by tapping on one of the bubbles in the '2d space' tab. This will take you to the summary page where you can confirm your entry."
                    )
                    
                    faqItem(
                        question: "How do I customize reminders?",
                        answer: "In the Settings page, you can tap directly on the 'Morning', 'Afternoon', or 'Evening' times to set a custom time for that reminder."
                    )
        
                    
                    faqItem(
                                                question: "Is my data private?",
                                                answer: "Yes. All your entries are stored securely on your device. We do not have access to your personal emotion data."
                                            )
                }
                .padding()
            }
            .navigationTitle("Help & Support")
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
