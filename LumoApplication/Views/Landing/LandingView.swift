import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    
    // --- 1. ADD THESE STATE VARIABLES ---
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showPrompt = false
    @State private var showButton = false
    @State private var hasAppeared = false // To ensure it only runs once

    var body: some View {
        ZStack {
            StarBackground().ignoresSafeArea()
            AnimatedLightEffect().ignoresSafeArea()

            VStack(spacing: 0) {
                
                // --- Settings Button (Top Right) ---
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // --- 2. MODIFY THE CONTENT ---
                
                // --- Text Content ---
                Text("Lumo")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)
                
                Text("Find Your Inner Cosmos")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.top, 4)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)
                
                // --- Your Logo ---
                Image("lumologo") // Using your updated asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .padding(.vertical, 60)
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : 20)
                
                // --- Prompt Text ---
                Text("Are you ready to explore your emotions?") // Using your updated text
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(showPrompt ? 1 : 0)
                    .offset(y: showPrompt ? 0 : 20)
                
                
                // --- Get Started Button ---
                Spacer().frame(height: 90)
                
                ConfirmationLumoButton(
                    text: "Get Started  →",
                    isFullWidth: false,
                    action: {
                        appState.path.append("explore")
                    }
                )
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
                
                // --- END OF MODIFICATIONS ---
                
                Spacer().frame(height: 50)
            }
            .padding(.top, 44)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
        // --- 3. ADD THIS ONAPPEAR MODIFIER ---
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            // Staged animations
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showLogo = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
                showTitle = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(1.5)) {
                showPrompt = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(1.8)) {
                showButton = true
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(AppState())
}
