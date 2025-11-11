import SwiftUI
import Lottie

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false // <-- 1. Add state

    var body: some View {
        ZStack {
            StarBackground()
                .ignoresSafeArea()

            AnimatedLightEffect()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                // Settings Button
                HStack {
                                    Spacer()
                                    Button(action: {
                                        showSettings = true
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                
                Spacer()
                
                // Text Content
                Text("Lumo")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                Text("Find Your Inner Cosmos")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .padding(.top, 4)
                
                
                Image("lumologo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200) // You can adjust this size
                                    .padding(.vertical, 70) // Adjust spacing above/below
                
                Text("Are you ready to explore your emotions?")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                // Get Started Button
                Spacer().frame(height: 20)
                
                Button(action: {
                                    // 3. Programmatically navigate by updating the path
                                    appState.path.append("explore")
                                }) {
                                    // Your button's style (no NavigationLink needed)
                                    HStack {
                                        Text("Get Started")
                                            .font(.system(size: 18, weight: .semibold, design: .default))
                                        Image(systemName: "arrow.right")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.7),
                                                Color.purple.opacity(0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(Color.white)
                                    .clipShape(Capsule())
                                }
                                .padding(.horizontal, 40)
                                
                                Spacer().frame(height: 50) // Bottom padding
                            }
                            .padding(.top, 44)
                            .padding(.bottom, 34)
                        }
        
        .sheet(isPresented: $showSettings) {
                    SettingsView()
                        // Add this line to show the grabber:
                        .presentationDragIndicator(.visible)
                }
        
        .sheet(isPresented: $showSettings) { // <-- 3. Add sheet
                    SettingsView()
                }
                    }
                }

#Preview {
    LandingView()
}
