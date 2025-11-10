import SwiftUI

struct ExploreView: View {
    private static let size: CGFloat = 150
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = 14
    
    @EnvironmentObject var appState: AppState
    
    @State private var cachedBackground = AnyView(StarBackground())
    @State private var showHelp = false
    @State private var showMaxReached = false
    @State private var showAlreadySelected = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var focusedEmotion: Emotion? = nil

    // overlay timing control
    @State private var isPreparingOverlay = false    // stage A: recenter first, then open overlay
    
    // Load emotions from JSON
    private let emotions: [Emotion] = EmotionLoader.loadEmotions()
    
    private var emotionsGrid: [Emotion] {
        emotions.sorted {
            if $0.coord.yIdx != $1.coord.yIdx {
                return $0.coord.yIdx < $1.coord.yIdx   // top to bottom
            } else {
                return $0.coord.xIdx < $1.coord.xIdx   // left to right
            }
        }
    }

    let gridItems = Array(
        repeating: GridItem(
            .fixed(size),
            spacing: spacingBetweenColumns,
            alignment: .center
        ),
        count: totalColumns
    )

    var body: some View {
        // Use ScrollViewReader so we can recenter to a specific index
        ScrollViewReader { proxy in
            ZStack {
                cachedBackground

                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    LazyVGrid(
                        columns: gridItems,
                        alignment: .center,
                        spacing: Self.spacingBetweenRows
                    ) {
                        ForEach(Array(emotionsGrid.enumerated()), id: \.element.id) { index, emotion in
                            GeometryReader { proxy in
                                SmallBubble(
                                    color: EmotionPalette.shared.color(for: emotion),
                                    size: Self.size,
                                    emotionName: emotion.label
                                )
                                    .scaleEffect(
                                        scale(
                                            proxy: proxy,
                                            value: index
                                        )
                                    )
                                    .offset(
                                        x: offsetX(index),
                                        y: 0
                                    )
                            }
                            .overlay(
                                Color.clear
                                    .frame(width: 1, height: 1)
                                    .id(centerID(for: index)),
                                alignment: .center
                            )
                            .id(index)  // Add id for scroll positioning
                            .onTapGesture {
                                // Stage A: recenter the tapped emotion to the true screen center
                                isPreparingOverlay = true
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                                    scrollViewProxy?.scrollTo(centerID(for: index), anchor: .center)
                                }
                                // After the recenter animation, open the overlay
                                let delay = 0.45
                                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                    isPreparingOverlay = false
                                    focusedEmotion = emotion
                                }
                            }
                            // You need to add height
                            .frame(height: Self.size)
                        }
                    }
                    // FIX: Add padding so rightmost column can be centered
                    .padding(.horizontal, UIScreen.main.bounds.width / 4)
                    .padding(.vertical, UIScreen.main.bounds.height / 6)
                }
                .defaultScrollAnchor(.center)  // Start at center

                // Overlay sits on top and fully hides the grid behind it
                if let fe = focusedEmotion {
                    FocusedEmotionOverlay(
                        emotion: fe,
                        allEmotions: emotionsGrid,
                        cellSize: .init(width: Self.size, height: Self.size),
                        bigDiameter: 300,
                        // center bubble tap => close and keep this emotion centered
                        onCloseAndCenterScroll: {
                            if let idx = emotionsGrid.firstIndex(where: { $0.id == fe.id }) {
                                withAnimation(.spring()) {
                                    scrollViewProxy?.scrollTo(centerID(for: idx), anchor: .center)
                                }
                            }
                            focusedEmotion = nil
                        },
                        // plus tap => keep old selection logic, then recenter and close
                        onAdd: {
                            if appState.selectedEmotions.count >= 8 {
                                showMaxReached = true
                                return
                            }
                            if appState.selectedEmotions.contains(where: { $0.id == fe.id }) {
                                showAlreadySelected = true
                                return
                            }
                            appState.selectedEmotions.append(fe)
                            if let idx = emotionsGrid.firstIndex(where: { $0.id == fe.id }) {
                                withAnimation(.spring()) {
                                    scrollViewProxy?.scrollTo(centerID(for: idx), anchor: .center)
                                }
                            }
                            focusedEmotion = nil
                        },
                        // neighbor tap => switch the overlay focus immediately
                        onNeighborSelect: { newEmotion in
                            withAnimation(.spring()) { focusedEmotion = newEmotion }
                        }
                    )
                    .zIndex(100)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear { scrollViewProxy = proxy }
        }
        .toolbar {
            // Right Button
            ToolbarItem(placement: .navigationBarTrailing, ) {
                Button(action: {
                    if appState.selectedEmotions.isEmpty {
                        showHelp = true
                    } else {
                        appState.path.append("confirmation")
                    }
                }) {
                    Image("BlackHole")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .badge(count: appState.selectedEmotions.count)
                }
                .padding()
                .popover(isPresented: $showHelp) {
                    Text("Please select at least one emotion.")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
                .popover(isPresented: $showMaxReached) {
                    Text("Maximum 8 emotions can be selected.")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
                .popover(isPresented: $showAlreadySelected) {
                    Text("This emotion is already selected.")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(focusedEmotion != nil)
    }

    // keep all helpers unchanged

    func offsetX(_ value: Int) -> CGFloat {
        let rowNumber = value / gridItems.count
        if rowNumber % 2 == 0 {
            return Self.size/2 + Self.spacingBetweenColumns/2
        }
        return 0
    }

    var center: CGPoint {
        CGPoint(
            x: UIScreen.main.bounds.size.width*0.5,
            y: UIScreen.main.bounds.size.height*0.5
        )
    }

    func scale(proxy: GeometryProxy, value: Int) -> CGFloat {
        let rowNumber = value / gridItems.count
        let x = (rowNumber % 2 == 0)
        ? proxy.frame(in: .global).midX + Self.size/2 + Self.spacingBetweenColumns/2
        : proxy.frame(in: .global).midX

        let y = proxy.frame(in: .global).midY
        let maxDistanceToCenter = getDistanceFromEdgeToCenter(x: x, y: y)
        let currentPoint = CGPoint(x: x, y: y)
        let distanceFromCurrentPointToCenter = distanceBetweenPoints(p1: center, p2: currentPoint)

        let distanceDelta = min(
            abs(distanceFromCurrentPointToCenter - maxDistanceToCenter),
            maxDistanceToCenter*0.3
        )

        let scalingFactor = 3.3
        let scaleValue = distanceDelta/(maxDistanceToCenter) * scalingFactor
        return scaleValue
    }

    func getDistanceFromEdgeToCenter(x: CGFloat, y: CGFloat) -> CGFloat {
        let m = slope(p1: CGPoint(x: x, y: y), p2: center)
        let currentAngle = angle(slope: m)

        let edgeSlope = slope(p1: .zero, p2: center)
        let deviceCornerAngle = angle(slope: edgeSlope)

        if currentAngle > deviceCornerAngle {
            let yEdge = (y > center.y) ? center.y*2 : 0
            let xEdge = (yEdge - y)/m + x
            let edgePoint = CGPoint(x: xEdge, y: yEdge)
            return distanceBetweenPoints(p1: center, p2: edgePoint)
        } else {
            let xEdge = (x > center.x) ? center.x*2 : 0
            let yEdge = m * (xEdge - x) + y
            let edgePoint = CGPoint(x: xEdge, y: yEdge)
            return distanceBetweenPoints(p1: center, p2: edgePoint)
        }
    }

    func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDistance = abs(p2.x - p1.x)
        let yDistance = abs(p2.y - p1.y)
        return CGFloat(sqrt(pow(xDistance, 2) + pow(yDistance, 2)))
    }

    func slope(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return (p2.y - p1.y)/(p2.x - p1.x)
    }

    func angle(slope: CGFloat) -> CGFloat {
        return abs(atan(slope) * 180 / .pi)
    }
    private func centerID(for index: Int) -> String { "center-\(index)" }
    
}

extension View {
    func badge(count: Int) -> some View {
        self.overlay(alignment: .topTrailing) {
            if count > 0 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .frame(minWidth: 18, minHeight: 18)
                    .background(Circle().fill(Color.red))
                    .offset(x: 0, y: 20)
            }
        }
    }
}

#Preview{
    ExploreView()
}
