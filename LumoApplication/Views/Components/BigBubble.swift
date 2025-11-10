//
//  BigBubbleCard.swift
//  LumoApplication
//

import SwiftUI

struct BigBubbleCard: View {
    // Input
    let emotion: Emotion
    let color: Color
    var diameter: CGFloat = 300
    var onAdd: (() -> Void)? = nil

    // Computed
    private var titleFontSize: CGFloat { diameter * 0.12 }

    var body: some View {
        ZStack {
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color, .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: diameter * 0.6
                    )
                )
                .blur(radius: diameter * 0.06)
                .opacity(0.9)

            // Glass frame
            BubbleFrame(size: diameter)

            // Content
            VStack(spacing: diameter * 0.035) {
                Text(emotion.label)
                    .font(.system(size: diameter * 0.11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 2)

                if let desc = emotion.description, desc.isEmpty == false {
                    Text(desc)
                        .font(.system(size: diameter * 0.05, weight: .medium))
                        .foregroundColor(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, diameter * 0.15)
                        .padding(.vertical, diameter * 0.02)
                        .accessibilityLabel(Text("Description"))
                }

                Button {
                    onAdd?()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: diameter * 0.06, weight: .semibold))
                        .padding(diameter * 0.05)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.white.opacity(0.25)))
                        .overlay(
                            Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Add emotion"))
            }
            .padding(.top, diameter * 0.12)
        }
        .frame(width: diameter, height: diameter)
        // Subtle tilt for depth
        .rotation3DEffect(.degrees(6), axis: (x: 1, y: 0, z: 0))
        .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(emotion.label))
    }
}

#Preview {
    // Mock data for preview
    let mock = Emotion(
        id: "discouraged",
        label: "Discouraged",
        coord: GridCoord(xIdx: 0, yIdx: 4),
        description: "I feel low and I struggle to see things improving soon.",
        vRaw: 0.25,
        aRaw: 0.308
    )

    return ZStack {
        StarBackground()
        BigBubbleCard(
            emotion: mock,
            color: Color.blue.opacity(0.55),
            diameter: 320,
            onAdd: { print("Added:", mock.label) }
        )
    }
}
