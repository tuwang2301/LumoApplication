import SwiftUI

struct LandingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false

    var body: some View {
        ZStack {
            StarBackground()
                .ignoresSafeArea()

            AnimatedLightEffect()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Settings button (top-right)
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                            .padding(.trailing, 25)
                            .padding(.top, -40)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)

                Spacer()

                // Prompt text
                Text("How are you feeling now?")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer().frame(height: 450)

                // Reusable Get Started button
                ConfirmationLumoButton(text: "Get Started") {
                    appState.path.append("explore")
                }
                .padding(.horizontal, 40)

                Spacer().frame(height: 50)
            }
            .padding(.top, 44)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(AppState())
}
