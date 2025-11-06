import SwiftUI

struct BubbleCircle: View {
    let size: CGFloat
    let label: String
    let colors: [Color]
    let definition: String
    
    @State private var isExpanded = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: size, height: size)
                .blur(radius: 5)
            
            // Transparent layer
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.6)
                        ]),
                        center: .center,
                        startRadius: size * 0.35,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)
            
            // Color core glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 40)
            
            // Inner shadow / text
            Circle()
                .fill(Color.black.opacity(0.1))
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 40)
                .overlay(
                    VStack(spacing: size * 0.01) {
                        Text(label)
                            .font(.system(size: size * 0.1, weight: .bold))
                            .foregroundColor(.white)
                        
                        if isExpanded {
                            Text(definition)
                                .font(.system(size: size * 0.1, weight: .regular))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                )
            
            // Gloss effect
            glossEffect(size: size)
        }
        .scaleEffect(isExpanded ? 1.2 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isExpanded)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    // MARK: - Gloss Effect
    private func glossEffect(size: CGFloat) -> some View {
        ZStack {
            // Main highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.5),
                            .white.opacity(0.25),
                            .white.opacity(0.05),
                            .clear
                        ],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
            
            // Bottom reflection
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.15),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.7, height: size * 0.15)
                .offset(y: size * 0.35)
                .blur(radius: 5)
        }
    }
}

#Preview {
    ZStack {
        // Star background (nếu muốn có thể tắt bằng tham số)
        StarBackground()
        VStack(spacing: 40) {
            BubbleCircle(size: 150, label: "Joy",colors: [.purple], definition: "Happy Happy Happy")
            BubbleCircle(size: 150, label: "Calm", colors: [.blue],
            definition: "Keep calm and carry on")
            BubbleCircle(size: 150, label: "Energy", colors: [.orange], definition: "Energy is the spice of life")
            BubbleCircle(size: 150, label: "Relax", colors: [.clear], definition: "Take a deep breath")
        }
    }
   
    .preferredColorScheme(.dark)
}
