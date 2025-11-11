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
    
    // Tunables
    private let gammaU: Double = 0.78
    private let gammaV: Double = 0.78
    private let edgeGain: Double = 0.55
    private let alphaAll: Double = 0.62
    
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
    
    // helpers for vector hue interpolation
    private func hueToVec(_ h: Double) -> (x: Double, y: Double) {
        let a = 2.0 * .pi * h
        return (cos(a), sin(a))
    }
    private func vecToHue(_ x: Double, _ y: Double) -> Double {
        var ang = atan2(y, x) / (2.0 * .pi)
        if ang < 0 { ang += 1 }
        return ang
    }

    private func calculateColor(for coord: GridCoord) -> Color {
        // normalized grid position u v in [0,1]  v = 0 top
        var u = Double(coord.xIdx) / Double(gridSize - 1)
        var v = Double(coord.yIdx) / Double(gridSize - 1)

        // corner hues
        // TL red, TR yellow, BL blue, BR green
        let TL = 0.00        // red
        let TR = 1.0/6.0     // yellow
        let BL = 2.0/3.0     // blue
        let BR = 0.34        // green (slightly deeper to enrich bottom-right ramp)

        // gradient acceleration
        u = pow(u, gammaU)
        v = pow(v, gammaV)

        // bilinear hue using vector interpolation for continuity
        let TLv = hueToVec(TL)
        let TRv = hueToVec(TR)
        let BLv = hueToVec(BL)
        let BRv = hueToVec(BR)
        let topX = lerp(TLv.x, TRv.x, u)
        let topY = lerp(TLv.y, TRv.y, u)
        let botX = lerp(BLv.x, BRv.x, u)
        let botY = lerp(BLv.y, BRv.y, u)
        let mixX = lerp(topX, botX, v)
        let mixY = lerp(topY, botY, v)
        let hue = vecToHue(mixX, mixY)
        let m = min(1.0, sqrt(mixX*mixX + mixY*mixY))

        // distance from center for fade  r in [0,1]
        let cx = 0.5, cy = 0.5
        let dx = u - cx
        let dy = v - cy
        let r = min(sqrt(dx*dx + dy*dy) / sqrt(cx*cx + cy*cy), 1.0)

        // steeper toward edges but keep center clean
        var t = 1.0 - pow(1.0 - r, edgeGain)
        t = smoothstep(t)

        // brightness and saturation
        let brightness = lerp(0.92, 0.68, t)

        // stronger saturation overall and richer center
        let edgeSatBase = lerp(0.48, 0.68, t)
        let centerLift = 0.30 * pow(1.0 - r, 0.85)
        let chromaFloor = 0.24 + 0.40 * (1.0 - m)
        var saturation = max(edgeSatBase + centerLift, chromaFloor)
        
        // quadrant emphasis for bottom-right (deeper green ramp near 13,13)
        let qBR = pow(max(0.0, u), 2.0) * pow(max(0.0, v), 2.0)
        saturation = min(0.92, saturation + 0.08 * qBR)
        let finalBrightness = max(0.0, brightness - 0.06 * qBR)

        return Color(hue: hue, saturation: saturation, brightness: finalBrightness, opacity: alphaAll)
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
