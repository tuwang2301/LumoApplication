import SwiftUI

/// Color palette generator for emotion bubbles based on grid position
/// Creates a cosmic, dreamy color scheme that blends naturally
class EmotionPalette {
    static let shared = EmotionPalette()
    
    // Cache for performance - pre-calculate all 196 colors (14x14)
    private var colorCache: [GridCoord: Color] = [:]
    
    // Grid configuration
    private let gridSize: Double = 14.0
    private let centerX: Double = 6.5  // 0-indexed center
    private let centerY: Double = 6.5
    
    private init() {
        precalculateColors()
    }
    
    /// Pre-calculate all colors for the 14x14 grid
    private func precalculateColors() {
        for x in 0..<Int(gridSize) {
            for y in 0..<Int(gridSize) {
                let coord = GridCoord(xIdx: x, yIdx: y)
                colorCache[coord] = calculateColor(for: coord)
            }
        }
    }
    
    /// Get color for a specific grid coordinate
    func color(for coord: GridCoord) -> Color {
        return colorCache[coord] ?? .gray
    }
    
    /// Get color for an emotion (convenience method)
    func color(for emotion: Emotion) -> Color {
        return color(for: emotion.coord)
    }
    
    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }

    // hue interpolation on circle with wrap handling
    private func lerpHue(_ h0: Double, _ h1: Double, _ t: Double) -> Double {
        var a = h0, b = h1
        if abs(b - a) > 0.5 { if a < b { a += 1 } else { b += 1 } }
        var h = a + (b - a) * t
        if h >= 1 { h -= 1 }
        if h < 0 { h += 1 }
        return h
    }

    // gentle curve
    private func smoothstep(_ t: Double) -> Double { t * t * (3 - 2 * t) }
    
    /// Calculate color based on circular gradient from grid position
//    private func calculateColor(for coord: GridCoord) -> Color {
//        let x = Double(coord.xIdx)
//        let y = Double(coord.yIdx)
//        
//        // Calculate position relative to center
//        let dx = x - centerX
//        let dy = -(y - centerY)  // Flip Y axis (screen coords go down, we want up)
//        
//        // Calculate angle in radians
//        // atan2 gives us -π to π, we want 0 to 2π
//        var angleRad = atan2(dy, dx)
//        if angleRad < 0 {
//            angleRad += 2.0 * .pi
//        }
//        
//        // Calculate distance from center (0-1 normalized)
//        let distance = sqrt(dx * dx + dy * dy)
//        let maxDistance = sqrt(centerX * centerX + centerY * centerY)
//        let normalizedDistance = min(distance / maxDistance, 1.0)
//        
//        // Create smooth, continuous hue mapping using wave functions
//        // This ensures no harsh transitions anywhere in the circle
//        let hue = smoothEmotionHue(angleRadians: angleRad)
//        
//        // Saturation: more saturated at edges, desaturated at center
//        // Range: 0.30 (center) to 0.85 (edge) for rich cosmic colors
//        let saturation = 0.30 + (normalizedDistance * 0.55)
//        
//        // Brightness: darker overall for cosmic feel
//        // Range: 0.50 (edge) to 0.75 (center) for mysterious glow
//        let brightness = 0.75 - (normalizedDistance * 0.25)
//        
//        return Color(hue: hue, saturation: saturation, brightness: brightness)
//    }

    private func calculateColor(for coord: GridCoord) -> Color {
        // normalized grid position u v in [0,1]  v = 0 top
        let u = Double(coord.xIdx) / Double(gridSize - 1)
        let v = Double(coord.yIdx) / Double(gridSize - 1)

        // corner hues
        // TL red, TR yellow, BL blue, BR green
        let TL = 0.00        // red
        let TR = 1.0/6.0     // yellow
        let BL = 2.0/3.0     // blue
        let BR = 1.0/3.0     // green

        // bilinear hue: top and bottom, then vertical blend
        let hueTop = lerpHue(TL, TR, u)     // red → yellow
        let hueBot = lerpHue(BL, BR, u)     // blue → green
        let hue    = lerpHue(hueTop, hueBot, v)

        // distance from center for fade  r in [0,1]
        let cx = 0.5, cy = 0.5
        let dx = u - cx
        let dy = v - cy
        let r = min(sqrt(dx*dx + dy*dy) / sqrt(cx*cx + cy*cy), 1.0)

        // smoother falloff so 중심이 더 옅고 가장자리는 선명
        let t = smoothstep(pow(r, 0.85))    // soft curve
        let saturation = lerp(0.26, 0.88, t)    // center 0.26 → edge 0.88
        let brightness = lerp(0.86, 0.58, t)    // center 0.86 → edge 0.58

        // tiny variance only on saturation so 열과 행의 hue 연결은 깨지지 않음
        let seed = sin(Double(coord.xIdx) * 12.9898 + Double(coord.yIdx) * 78.233) * 43758.5453
        let frac = seed - floor(seed)
        let sat = max(0.0, min(1.0, saturation + (frac - 0.5) * 0.02))

        return Color(hue: hue, saturation: sat, brightness: brightness)
    }

//
//    
//    /// Creates a smooth, continuous hue mapping for the emotion wheel
//    /// Uses spline-like interpolation between key color points
//    private func smoothEmotionHue(angleRadians: Double) -> Double {
//        // Define key colors around the wheel (angle in radians, target hue)
//        // Based on reference emotion wheel image
//        let keyPoints: [(angle: Double, hue: Double)] = [
//            (0.0 * .pi / 4.0, 0.12),   // 0° Right: Yellow-Orange
//            (1.0 * .pi / 4.0, 0.02),   // 45° Upper-Right: Red-Orange
//            (2.0 * .pi / 4.0, 0.00),   // 90° Top: Red
//            (3.0 * .pi / 4.0, 0.90),   // 135° Upper-Left: Magenta
//            (4.0 * .pi / 4.0, 0.75),   // 180° Left: Purple
//            (5.0 * .pi / 4.0, 0.62),   // 225° Lower-Left: Blue
//            (6.0 * .pi / 4.0, 0.52),   // 270° Bottom: Cyan
//            (7.0 * .pi / 4.0, 0.28),   // 315° Lower-Right: Green
//            (8.0 * .pi / 4.0, 0.12)    // 360° Right: Back to Yellow (for wrapping)
//        ]
//        
//        // Find which two key points we're between
//        for i in 0..<(keyPoints.count - 1) {
//            let start = keyPoints[i]
//            let end = keyPoints[i + 1]
//            
//            if angleRadians >= start.angle && angleRadians <= end.angle {
//                // Calculate position between the two points (0-1)
//                let range = end.angle - start.angle
//                let t = (angleRadians - start.angle) / range
//                
//                // Use smoothstep interpolation for smooth transitions
//                // This is better than linear and avoids discontinuities
//                let smoothT = smoothstep(t)
//                
//                // Handle hue wrapping around 0/1 boundary (red region)
//                var startHue = start.hue
//                var endHue = end.hue
//                
//                // If we're crossing the red boundary, adjust for shortest path
//                if abs(endHue - startHue) > 0.5 {
//                    if startHue < endHue {
//                        startHue += 1.0
//                    } else {
//                        endHue += 1.0
//                    }
//                }
//                
//                // Interpolate between the two hues
//                var hue = startHue + (endHue - startHue) * smoothT
//                
//                // Wrap back to 0-1 range
//                while hue < 0.0 {
//                    hue += 1.0
//                }
//                while hue >= 1.0 {
//                    hue -= 1.0
//                }
//                
//                return hue
//            }
//        }
//        
//        // Fallback (shouldn't reach here)
//        return 0.5
//    }
//    
    
    /// Get multiple colors for selected emotions (for visualization)
    func colors(for emotions: [Emotion]) -> [Color] {
        return emotions.map { color(for: $0) }
    }
    
    /// Create a gradient from multiple emotion colors
    func createGradient(from emotions: [Emotion]) -> LinearGradient {
        let colors = colors(for: emotions)
        return LinearGradient(
            colors: colors.isEmpty ? [.gray] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview Helper
extension EmotionPalette {
    /// Generate preview data for testing color palette
    static func previewColors() -> [[Color]] {
        var grid: [[Color]] = []
        for y in 0..<14 {
            var row: [Color] = []
            for x in 0..<14 {
                let coord = GridCoord(xIdx: x, yIdx: y)
                row.append(EmotionPalette.shared.color(for: coord))
            }
            grid.append(row)
        }
        return grid
    }
}
