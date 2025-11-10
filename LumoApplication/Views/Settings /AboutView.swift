import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // --- Header ---
                    Image("lumologo") // Use your app logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(20)
                    
                    Text("Lumo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.1.0")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    Text("Find Your Inner Cosmos")
                        .font(.title3)
                        .padding(.bottom, 20)
                    
                    // --- Mission ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Our Mission")
                            .font(.headline)
                        Text("Lumo is a personal companion designed to help you explore, understand, and visualise your emotions. We believe that by checking in with your inner cosmos, you can find greater clarity and peace.")
                            .font(.body)
                            .foregroundStyle(.gray)
                    }
                    
                    
                    // --- Credits ---
                    VStack(spacing: 4) {
                        Text("Made with ❤️ by i5Pro")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text("© 2025 Lumo. All rights reserved.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 80)
                    
                }
                .padding()
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
