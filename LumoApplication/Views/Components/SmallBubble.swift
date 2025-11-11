//
//  SmallBubble.swift
//  LumoApplication
//
//  Created by Ina Song on 7/11/2025.
//
import SwiftUI

struct SmallBubble:View {
    let color: Color
    let size: CGFloat
    let emotionName: String
    
    init(color: Color, size: CGFloat = 200, emotionName: String) {
        self.color = color
        self.size = size
        self.emotionName = emotionName
    }

    var body: some View {
        ZStack{
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.3), .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .blur(radius: size * 0.15)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 0.65, height: size * 0.65)
                .blur(radius: size * 0.14)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.2, height: size * 0.2)
                .blur(radius: size * 0.09)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white.opacity(0.4), .clear]),
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.20, height: size * 0.20)
                .blur(radius: size * 0.06)
            BubbleFrame(size: size)
            Text(emotionName)
                .font(.system(size: size * 0.11,weight: .semibold))
                .foregroundColor(.white)

        }
    }
}

#Preview {
    ZStack{
        StarBackground()
        HStack{
            VStack{
                SmallBubble(color: .blue.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .purple.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .green.opacity(0.5)  , size: 200,
                            emotionName: "Overwhelmed")
            }
            VStack{
                SmallBubble(color: .blue.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .purple.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .green.opacity(0.5)  , size: 200,
                            emotionName: "Overwhelmed")
            }
            VStack{
                SmallBubble(color: .blue.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .purple.opacity(0.5) , size: 200,
                            emotionName: "Overwhelmed")
                SmallBubble(color: .green.opacity(0.5)  , size: 200,
                            emotionName: "Overwhelmed")
            }
        }
    }
}

