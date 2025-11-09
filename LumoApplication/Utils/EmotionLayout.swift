//
//  EmotionLayout.swift
//  LumoApplication
//
//  Created by Ina Song on 9/11/2025.
//

import SwiftUI

// Holds layout info for one emotion bubble
struct EmotionNode {
    let position: CGPoint      // final position of the bubble
    let size: CGFloat          // scaled size based on distance from center
    let color: Color           // bubble color (use palette later)
}

struct EmotionLayout {
    static func node(for emotion: Emotion, in container: CGRect) -> EmotionNode {
        // Layout constants
        let spacing: CGFloat = 120           // space between grid cells
        let baseSize: CGFloat = 180          // default bubble size
        let maxScale: CGFloat = 1.3          // biggest bubble at center
        let minScale: CGFloat = 0.6          // smallest bubble far away
        let offsetScale: CGFloat = 0.15      // how much to push outward
        let maxDist: CGFloat = 500           // how far to affect scaling

        // 1. Grid position of the emotion
        let x = CGFloat(emotion.coord.xIdx) * spacing
        let y = CGFloat(emotion.coord.yIdx) * spacing
        let point = CGPoint(x: x, y: y)

        // 2. Center of the current visible screen
        let screenCenter = CGPoint(x: container.midX, y: container.midY)

        // 3. Distance to center
        let dx = point.x - screenCenter.x
        let dy = point.y - screenCenter.y
        let dist = sqrt(dx * dx + dy * dy)

        // 4. Scale calculation
        let normalized = max(0.0, 1.0 - dist / maxDist)
        let scale = minScale + normalized * (maxScale - minScale)
        let size = baseSize * scale

        // 5. Push outward slightly if near center
        let offsetX = dx / max(dist, 0.1) * size * offsetScale
        let offsetY = dy / max(dist, 0.1) * size * offsetScale
        let finalPosition = CGPoint(x: point.x + offsetX, y: point.y + offsetY)

        return EmotionNode(position: finalPosition, size: size, color: .gray.opacity(0.5))
    }
}
