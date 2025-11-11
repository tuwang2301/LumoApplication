import SwiftUI
import Lottie

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    
    // --- State for Animations ---
    @State private var showTitle = false
    @State private var showLottie = false
    @State private var showCard1 = false
    @State private var showCard2 = false
    @State private var showButton = false
    @State private var hasAppeared = false
    
    var body: some View {
        ZStack {
            StarBackground().ignoresSafeArea()
            AnimatedLightEffect().ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // --- 1. Title (Unchanged) ---
                Text("Lumo")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 10)

                Text("Find Your Inner Cosmos")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.top, 4)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 10)
                
                // --- Lottie Animation ---
                LottieView(
                    name: "ani",
                    loopMode: .loop
                )
                .frame(width: 250, height: 250)
                // 2. Padding between logo and cards smaller
                .padding(.vertical, 20) // Reduced from 30
                .opacity(showLottie ? 1 : 0)
                .scaleEffect(showLottie ? 1 : 0.8)
                
                // 2. Padding between logo and cards smaller
                Spacer().frame(height: 20) // Replaced flexible Spacer
                
                // --- Feature List (Unchanged) ---
                VStack(spacing: 16) {
                    FeatureRow(
                        iconName: "puzzlepiece.fill",
                        title: "Explore your emotions",
                        subtitle: "Identify Your Emotions Through Interactive Emotions Bubbles."
                    )
                    .opacity(showCard1 ? 1 : 0)
                    .offset(x: showCard1 ? 0 : -50)
                    
                    FeatureRow(
                        iconName: "cube.transparent.fill",
                        title: "Visualise your emotions",
                        subtitle: "Drag And Drop Interactive Bubbles To Visually Explore What You're Feeling"
                    )
                    .opacity(showCard2 ? 1 : 0)
                    .offset(x: showCard2 ? 0 : 50)
                }
                .padding(.horizontal, 20)
                
                // 3. Padding between button and cards bit bigger
                Spacer().frame(height: 80) // Replaced flexible Spacer
                
                // --- "I'm Ready" Button ---
                ConfirmationLumoButton(
                    text: "I'm Ready  →",
                    isFullWidth: false, // 1. Use the small button
                    action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.hasSeenHook = true
                        }
                    }
                )
                // Removed .padding(.horizontal, 40)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
                
                Spacer().frame(height: 50)
            }
            .padding(.top, 44)
            .padding(.bottom, 34)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            // Animation timings (unchanged)
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showTitle = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
                showLottie = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.2)) {
                showCard1 = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.5)) {
                showCard2 = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(2.0)) {
                showButton = true
            }
        }
    }
}

struct FeatureRow: View {
    let iconName: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon (unchanged)
            Image(systemName: iconName)
                .font(.title)
                .foregroundStyle(Color.blue)
                .frame(width: 44)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.white.opacity(0.7))
                                    // --- 1. THIS IS THE KEY ---
                                    // This forces the text to wrap vertically
                                    // instead of expanding horizontally.
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.7)
                            }
                            // --- 2. THIS IS STILL NEEDED ---
                            // This gives the VStack a defined boundary to wrap within.
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        
                        }
        .padding(16)
        .background(.ultraThinMaterial) // Glass effect
        .cornerRadius(20)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
