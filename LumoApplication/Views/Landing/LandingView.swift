import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    
    // This state controls the settings sheet
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Layer 1: Star Background
            StarBackground()
                .ignoresSafeArea()

            // Layer 2: Animated Light Effect
            AnimatedLightEffect()
                .ignoresSafeArea()

            // Layer 3: Main Content
            VStack(spacing: 0) {
                
                // --- Settings Button (Top Right) ---
                HStack {
                    Spacer()
                    Button(action: {
                        showSettings = true // This opens the sheet
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // --- Text Content ---
                Text("Lumo")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text("Find Your Inner Cosmos")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.top, 4)
                
                // --- Your Logo ---
                Image("lumologo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .padding(.vertical, 60)
                
                // --- Prompt Text ---
                Text("Hi, Are you ready to explore your emotions?")
                    .font(.system(size: 22, weight: .medium, design: .default))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                
                // --- 1. THIS IS THE MODIFIED BLOCK ---
                
                Spacer().frame(height: 30)
                
                Button(action: {
                    // This uses your AppState to navigate
                    appState.path.append("explore")
                }) {
                    ConfirmationLumoButton(
                        text: "Get Started  →",
                        isFullWidth: false,
                        action: {
                            appState.path.append("explore")
                        }
                    )
                }
                
                Spacer().frame(height: 50) // Bottom padding
            }
            .padding(.top, 44)
            .padding(.bottom, 34)
        }
        // --- Settings Sheet Modifier ---
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(AppState())
}
