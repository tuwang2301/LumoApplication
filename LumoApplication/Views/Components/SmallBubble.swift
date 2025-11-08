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

    var body: some View {
        ZStack{
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.65, height: size * 0.65)
                .blur(radius: size * 0.1)
            BubbleFrame(size: size)
            Text(emotionName)
                .font(.system(size: size * 0.085,weight: .semibold))
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

