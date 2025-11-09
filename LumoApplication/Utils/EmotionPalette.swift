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
    
    /// Calculate color based on circular gradient from grid position
    private func calculateColor(for coord: GridCoord) -> Color {
        let x = Double(coord.xIdx)
        let y = Double(coord.yIdx)
        
        // Calculate position relative to center
        let dx = x - centerX
        let dy = -(y - centerY)  // Flip Y axis (screen coords go down, we want up)
        
        // Calculate angle in radians
        // atan2 gives us -π to π, we want 0 to 2π
        var angleRad = atan2(dy, dx)
        if angleRad < 0 {
            angleRad += 2.0 * .pi
        }
        
        // Calculate distance from center (0-1 normalized)
        let distance = sqrt(dx * dx + dy * dy)
        let maxDistance = sqrt(centerX * centerX + centerY * centerY)
        let normalizedDistance = min(distance / maxDistance, 1.0)
        
        // Create smooth, continuous hue mapping using wave functions
        // This ensures no harsh transitions anywhere in the circle
        let hue = smoothEmotionHue(angleRadians: angleRad)
        
        // Saturation: more saturated at edges, desaturated at center
        // Range: 0.30 (center) to 0.85 (edge) for rich cosmic colors
        let saturation = 0.30 + (normalizedDistance * 0.55)
        
        // Brightness: darker overall for cosmic feel
        // Range: 0.50 (edge) to 0.75 (center) for mysterious glow
        let brightness = 0.75 - (normalizedDistance * 0.25)
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    /// Creates a smooth, continuous hue mapping for the emotion wheel
    /// Uses spline-like interpolation between key color points
    private func smoothEmotionHue(angleRadians: Double) -> Double {
        // Define key colors around the wheel (angle in radians, target hue)
        // Based on reference emotion wheel image
        let keyPoints: [(angle: Double, hue: Double)] = [
            (0.0 * .pi / 4.0, 0.12),   // 0° Right: Yellow-Orange
            (1.0 * .pi / 4.0, 0.02),   // 45° Upper-Right: Red-Orange
            (2.0 * .pi / 4.0, 0.00),   // 90° Top: Red
            (3.0 * .pi / 4.0, 0.90),   // 135° Upper-Left: Magenta
            (4.0 * .pi / 4.0, 0.75),   // 180° Left: Purple
            (5.0 * .pi / 4.0, 0.62),   // 225° Lower-Left: Blue
            (6.0 * .pi / 4.0, 0.52),   // 270° Bottom: Cyan
            (7.0 * .pi / 4.0, 0.28),   // 315° Lower-Right: Green
            (8.0 * .pi / 4.0, 0.12)    // 360° Right: Back to Yellow (for wrapping)
        ]
        
        // Find which two key points we're between
        for i in 0..<(keyPoints.count - 1) {
            let start = keyPoints[i]
            let end = keyPoints[i + 1]
            
            if angleRadians >= start.angle && angleRadians <= end.angle {
                // Calculate position between the two points (0-1)
                let range = end.angle - start.angle
                let t = (angleRadians - start.angle) / range
                
                // Use smoothstep interpolation for smooth transitions
                // This is better than linear and avoids discontinuities
                let smoothT = smoothstep(t)
                
                // Handle hue wrapping around 0/1 boundary (red region)
                var startHue = start.hue
                var endHue = end.hue
                
                // If we're crossing the red boundary, adjust for shortest path
                if abs(endHue - startHue) > 0.5 {
                    if startHue < endHue {
                        startHue += 1.0
                    } else {
                        endHue += 1.0
                    }
                }
                
                // Interpolate between the two hues
                var hue = startHue + (endHue - startHue) * smoothT
                
                // Wrap back to 0-1 range
                while hue < 0.0 {
                    hue += 1.0
                }
                while hue >= 1.0 {
                    hue -= 1.0
                }
                
                return hue
            }
        }
        
        // Fallback (shouldn't reach here)
        return 0.5
    }
    
    /// Smoothstep function for smooth interpolation
    /// Returns values between 0 and 1 with smooth acceleration/deceleration
    private func smoothstep(_ t: Double) -> Double {
        // Clamp to 0-1
        let x = max(0.0, min(1.0, t))
        // Smoothstep formula: 3t² - 2t³
        return x * x * (3.0 - 2.0 * x)
    }
    
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
