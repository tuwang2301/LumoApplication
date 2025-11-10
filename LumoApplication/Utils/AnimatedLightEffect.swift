import SwiftUI

struct AnimatedLightEffect: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Light 1: Blue
            // This circle will move from top-right to bottom-left
            Circle()
                .fill(Color.blue.opacity(0.5)) // Low opacity
                .frame(width: 400) // Large size
                .blur(radius: 120) // Very blurred
                .offset(
                    x: animate ? -200 : 200,
                    y: animate ? -150 : 150
                )
            
            // Light 2: Purple
            // This circle will move from top-left to bottom-right
            Circle()
                .fill(Color.purple.opacity(0.5))
                .frame(width: 350)
                .blur(radius: 100)
                .offset(
                    x: animate ? 150 : -150,
                    y: animate ? 200 : -200
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
