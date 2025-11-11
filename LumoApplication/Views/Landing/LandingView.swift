import SwiftUI
import Lottie // <-- 1. Added this missing import

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    
    // --- State variables ---
    @State private var showLogo = false
    // @State private var showTitle = false // <-- 2. Removed this
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
                
                // --- 3. Removed the "Lumo" and "Find Your Inner Cosmos" Text views ---
                
                // --- Your Logo ---
                LottieView(
                    name: "ani",
                    loopMode: .loop
                )
                .frame(width: 250, height: 250)
                .padding(.vertical, 60)
                .opacity(showLogo ? 1 : 0)
                .offset(y: showLogo ? 0 : 20)
                
                // --- Prompt Text ---
                Text("How are you feeling right now?") // Your new text
                    .font(.system(size: 32, weight: .medium, design: .default)) // Your new font
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(showPrompt ? 1 : 0)
                    .offset(y: showPrompt ? 0 : 20)
                
                
                // --- Get Started Button ---
                Spacer().frame(height: 90) // Your new spacer
                
                ConfirmationLumoButton(
                    text: "Explore Emotions →",
                    isFullWidth: false,
                    action: {
                        appState.path.append("explore")
                    }
                )
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
                
                Spacer().frame(height: 50)
            }
            .padding(.top, 44)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
        // --- 4. ADD THIS ONAPPEAR MODIFIER ---
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            // Staged animations
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showLogo = true
            }
            
            // 'showTitle' animation removed
            
            // Timings adjusted to close the gap
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
                showPrompt = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(1.3)) {
                showButton = true
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(AppState())
}
