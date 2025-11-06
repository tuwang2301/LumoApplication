import SwiftUI

struct StarBackground: View {
    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }
    
    @State private var twinkle = false
    
    // Generate Stars
    let stars: [Star] = (0..<200).map { _ in
        Star(
            x: CGFloat.random(in: 0...400),
            y: CGFloat.random(in: 0...900),
            size: CGFloat.random(in: 1...3)
        )
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white)
                    .frame(width: star.size, height: star.size)
                    .position(x: star.x, y: star.y)
                    .opacity(twinkle ? Double.random(in: 0.3...1.0) : Double.random(in: 0.1...0.6))
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.5...1.5))
                            .repeatForever(autoreverses: true),
                        value: twinkle
                    )
            }
        }
        .onAppear {
            twinkle.toggle()
        }
    }
}

#Preview {
    StarBackground()
}
