//
//  BigBubble.swift
//  LumoApplication
//
//  Created by Ina Song on 8/11/2025.
//

import SwiftUI

struct BigBubble:View {
    let color: Color
    let size: CGFloat
    let emotionName: String
    let emotionDescription: String
    
    init(color: Color, size: CGFloat = 500, emotionName: String, emotionDescription: String) {
        self.color = color
        self.size = size
        self.emotionName = emotionName
        self.emotionDescription = emotionDescription
    }

    var body: some View {
        ZStack{
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
            BubbleFrame(size: size)
            ZStack {
                Text(emotionName)
                    .font(.system(size: size * 0.085,weight: .semibold))
                    .foregroundColor(.white)
                Text(emotionDescription)
                    .font(.system(size: size * 0.02,weight: .semibold))
                    .foregroundColor(.white)            }
        }
    }
}

#Preview {
    ZStack{
        StarBackground()
        BigBubble(color: .blue.opacity(0.5),
            emotionName: "Overwhelmed", emotionDescription: "I feel pressure from too many demands at once and I cannot keep up.")
    }
}

