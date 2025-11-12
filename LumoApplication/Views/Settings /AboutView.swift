import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 10) {
                    // --- Header ---
                    Image("lumologo") // Use your app logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                    
                    Text("Lumo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.1.0")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.bottom, 30)

                    Text("Lumo is a space to notice how you feel. By simply recognizing your emotions, you reclaim the agency to move through them. Through aesthetics and sensory experience, Lumo invites you to reconnect with your inner self.")
                        .font(.body)
                        .foregroundStyle(.gray)
                                                
                    
                    // --- Credits ---
                    VStack(spacing: 4) {
                        Text("Made from ❤️ by i5Pro")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text("© 2025 Lumo. All rights reserved.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 80)
                    
                }
                .padding(.horizontal, 50)
            }
        }
        .navigationTitle("About")
        .preferredColorScheme(.dark)
    }
    
    // Helper view for a feature row
    func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.purple)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
