
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
    let canAdd: Bool
    let onReject: (() -> Void)?

    // Visual params
    private let dimOpacity: Double = 0.35
    private let neighborOpacity: Double = 0.7
    private let neighborCount: Int = 6

    // fake zoom from center
    @State private var appear = false
    @State private var isEjecting = false
    
    @State private var cachedBackground = AnyView(StarBackground())

    
    init(
        emotion: Emotion,
        allEmotions: [Emotion],
        cellSize: CGSize,
        bigDiameter: CGFloat,
        onCloseAndCenterScroll: @escaping () -> Void,
        onAdd: @escaping () -> Void,
        onNeighborSelect: @escaping (Emotion) -> Void,
        canAdd: Bool,
        onReject: (() -> Void)? = nil
    ) {
        self.emotion = emotion
        self.allEmotions = allEmotions
        self.cellSize = cellSize
        self.bigDiameter = bigDiameter
        self.onCloseAndCenterScroll = onCloseAndCenterScroll
        self.onAdd = onAdd
        self.onNeighborSelect = onNeighborSelect
        self.canAdd = canAdd
        self.onReject = onReject
    }


    var body: some View {
        ZStack {
            // Fully hide ExploreView behind
            cachedBackground
            
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
            }
            .offset(y: -bigDiameter * 0.2)
            .allowsHitTesting(!isEjecting)
            

            // Center big bubble with fake zoom
            BigBubbleCard(
                emotion: emotion,
                color: EmotionPalette.shared.color(for: emotion),
                diameter: bigDiameter,
                onAdd: {
                    guard canAdd else {
                        onReject?()
                        return
                    }
                    guard isEjecting == false else { return }
                    isEjecting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onAdd()
                    }
                }
            )
            .modifier(EjectToTopRight(isEjecting: isEjecting, bigDiameter: bigDiameter))
            .scaleEffect(appear ? 1.0 : 0.45)
            .opacity(appear ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.88)) {
                    appear = true
                }
            }
            .onTapGesture { if !isEjecting { onCloseAndCenterScroll() } }

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

private struct EjectToTopRight: ViewModifier {
    let isEjecting: Bool
    let bigDiameter: CGFloat
    func body(content: Content) -> some View {
        // target margin
        let m: CGFloat = 24
        let targetX = UIScreen.main.bounds.width/2  - m
        let targetY = -UIScreen.main.bounds.height/1.5
        
        return content
            .offset(x: isEjecting ? targetX : 0,
                    y: isEjecting ? targetY : 0)
            .scaleEffect(isEjecting ? 0.45 : 1.0)
            .opacity(isEjecting ? 0.0 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: isEjecting)
    }
}
