import SwiftUI

struct AnimatedLightEffect: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Light 1: Blue
            // This circle will move from top-right to bottom-left
            Circle()
                .fill(Color.blue.opacity(0.5)) // Low opacity
                .frame(width: 150) // Large size
                .blur(radius: 20) // Very blurred
                .offset(
                    x: animate ? -20 : 20,
                    y: animate ? -15 : 15
                )
            
            // Light 2: Purple
            // This circle will move from top-left to bottom-right
            Circle()
                .fill(Color.purple.opacity(0.5))
                .frame(width: 150)
                .blur(radius: 20)
                .offset(
                    x: animate ? 15 : -15,
                    y: animate ? 20 : -20
                )
        }
        .onAppear {
            // Start the animation on a 12-second loop
            withAnimation(
                .easeInOut(duration: 10.0).repeatForever(autoreverses: true)
            ) {
                animate.toggle()
            }
        }
    }
}

#Preview {
    // Add a black background to see the effect
    ZStack {
        Color.black.ignoresSafeArea()
        AnimatedLightEffect()
    }
}
