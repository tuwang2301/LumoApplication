
import SwiftUI

struct FocusedEmotionOverlay: View {
    // Input
    let emotion: Emotion
    let allEmotions: [Emotion]
    let cellSize: CGSize
    let bigDiameter: CGFloat
    let onCloseAndCenterScroll: () -> Void       // center bubble tap
    let onAdd: () -> Void                         // plus tap
    let onNeighborSelect: (Emotion) -> Void       // neighbor tap

    // Visual params
    private let dimOpacity: Double = 0.35
    private let neighborOpacity: Double = 0.7
    private let neighborCount: Int = 6

    // fake zoom from center
    @State private var appear = false

    var body: some View {
        ZStack {
            // Fully hide ExploreView behind
            Color.black.ignoresSafeArea()
            StarBackground().ignoresSafeArea()
            
            Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture { onCloseAndCenterScroll() }


            // Neighbor ring
            ZStack {
                ForEach(ringNeighbors(), id: \.emotion.id) { item in
                    SmallBubble(
                        color: EmotionPalette.shared.color(for: item.emotion),
                        size: item.size,
                        emotionName: item.emotion.label
                    )
                    .opacity(neighborOpacity)
                    .position(item.position)
                    .onTapGesture { onNeighborSelect(item.emotion) }
                }
            }.offset(y: -bigDiameter * 0.2)

            // Center big bubble with fake zoom
            BigBubbleCard(
                emotion: emotion,
                color: EmotionPalette.shared.color(for: emotion),
                diameter: bigDiameter,
                onAdd: onAdd
            )
            .scaleEffect(appear ? 1.0 : 0.65)
            .opacity(appear ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                    appear = true
                }
            }
            .onTapGesture {
                onCloseAndCenterScroll()
            }
        }
        .contentShape(Rectangle())
        .transition(.scale.combined(with: .opacity))
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: emotion.id)
    }

    // Pick six closest and place them on a circle around the center
    private func ringNeighbors() -> [(emotion: Emotion, position: CGPoint, size: CGFloat)] {
        let cx = emotion.coord.xIdx
        let cy = emotion.coord.yIdx
        let sorted = allEmotions
            .filter { $0.id != emotion.id }
            .sorted { a, b in
                let da = squaredGridDist(ax: a.coord.xIdx, ay: a.coord.yIdx, bx: cx, by: cy)
                let db = squaredGridDist(ax: b.coord.xIdx, ay: b.coord.yIdx, bx: cx, by: cy)
                return da < db
            }
        let picked = Array(sorted.prefix(neighborCount))

        let small = min(cellSize.width, cellSize.height)
        let smallRadius = small * 0.5
        let bigRadius = bigDiameter * 0.5
        let pad: CGFloat = 14
        let ringRadius = bigRadius + smallRadius + pad

        let bounds = UIScreen.main.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let baseAngle = -CGFloat.pi / 2
        let step = 2 * CGFloat.pi / CGFloat(neighborCount)

        return picked.enumerated().map { i, e in
            let theta = baseAngle + step * CGFloat(i)
            let px = center.x + cos(theta) * ringRadius
            let py = center.y + sin(theta) * ringRadius
            return (emotion: e,
                    position: CGPoint(x: px, y: py),
                    size: small)
        }
    }

    private func squaredGridDist(ax: Int, ay: Int, bx: Int, by: Int) -> Int {
        let dx = ax - bx
        let dy = ay - by
        return dx*dx + dy*dy
    }
}

#Preview {
    let center = Emotion(id: "disconnected",
                         label: "Disconnected",
                         coord: GridCoord(xIdx: 7, yIdx: 7),
                         description: "Feeling separate from others",
                         vRaw: 0.3, aRaw: 0.28)

    let others: [Emotion] = (0..<40).map { i in
        Emotion(id: "e\(i)",
                label: "E\(i)",
                coord: GridCoord(xIdx: 3 + (i % 10), yIdx: 3 + (i / 10)),
                description: nil, vRaw: 0.4, aRaw: 0.5)
    }

    return ZStack {
        StarBackground()
        FocusedEmotionOverlay(
            emotion: center,
            allEmotions: others + [center],
            cellSize: .init(width: 150, height: 150),
            bigDiameter: 320,
            onCloseAndCenterScroll: {},
            onAdd: {},
            onNeighborSelect: { _ in }
        )
    }
}
