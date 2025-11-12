import SwiftUI
import Lottie

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    
    // --- State variables ---
    @State private var showLogo = false
    @State private var showPrompt = false
    @State private var showButton = false
    @State private var hasAppeared = false // To ensure it only runs once

    var body: some View {
        ZStack {
            StarBackground().ignoresSafeArea()
            AnimatedLightEffect().ignoresSafeArea()

            VStack(spacing: 0) {
                
                Spacer().frame(height: 50)
                
                // --- Logo ---
                LottieView(
                    name: "ani",
                    loopMode: .loop
                )
                .frame(width: 250, height: 250)
                .padding(.bottom, 40)
                .padding(.top, 20)
                .opacity(showLogo ? 1 : 0)
                .offset(y: showLogo ? 0 : 20)
                
                // --- Prompt Text ---
                Text("How are you feeling right now?")
                    .font(.system(size: 32, weight: .medium, design: .default))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(showPrompt ? 1 : 0)
                    .offset(y: showPrompt ? 0 : 20)
                
                Spacer().frame(height: 70)
                
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
            .padding(.bottom, 34)
        }

        .overlay(alignment: .topTrailing) {
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                showLogo = true
            }
                        
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
