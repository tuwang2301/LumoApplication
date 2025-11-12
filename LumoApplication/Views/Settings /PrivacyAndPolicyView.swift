import SwiftUI

struct PrivacyAndPolicyView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("At Lumo, we respect your privacy. This policy explains how we handle your information.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 8)
                    
                    policySection(
                        title: "Information We Collect",
                        icon: "lock.shield.fill",
                        content: "Lumo does not collect, store, or share any personal information. No account required, no tracking, no data collection."
                    )
                    
                    policySection(
                        title: "Use of Information",
                        icon: "hand.raised.fill",
                        content: "Since we don't collect any information, we don't use, process, or share user data in any way."
                    )
                    
                    policySection(
                        title: "Third-Party Services",
                        icon: "network",
                        content: "Lumo does not integrate with or share data with any third-party services outside of Apple's own systems."
                    )
                    
                    policySection(
                        title: "Your Rights",
                        icon: "person.fill.checkmark",
                        content: "As we don't collect or store any user data, there is no personal information to access, modify, or delete."
                    )
                    
                    // Footer
                    VStack(spacing: 12) {
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        Text("We may update this Privacy Policy to reflect changes in our app or applicable laws. The latest version will always be available within the app.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                        
                        Link("Apple Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
    
    // Policy section component
    func policySection(title: String, icon: String, content: String, note: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 28)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            if let note = note {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                    
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationView {
        PrivacyAndPolicyView()
    }
}
