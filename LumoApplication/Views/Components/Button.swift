import SwiftUI

// MARK: - Reusable Lumo Button
struct ConfirmationLumoButton: View {
    let text: String
    var isFullWidth: Bool = false // <-- ADD THIS
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                // Frame is now flexible
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
        }
        .buttonStyle(LumoPrimaryCapsuleButton())
    }
}

// MARK: - Glass Capsule Style
struct LumoPrimaryCapsuleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        return configuration.label
            .font(.headline) // <-- Moved font here
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    // ... (rest of your style code is perfect, no change needed)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.35),
                                        Color.blue.opacity(0.25),
                                        Color.pink.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: Color.purple.opacity(isPressed ? 0.15 : 0.25),
                        radius: isPressed ? 2 : 10,
                        y: isPressed ? 1 : 4
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
    }
}
