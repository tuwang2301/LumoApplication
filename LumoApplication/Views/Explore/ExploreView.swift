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
    
    // axis indicator state
    @State private var isScrolling = false
    @State private var scrollTimer: Timer? = nil
    @State private var centerEmotionCoord: GridCoord? = nil
    @State private var cellPositions: [String: CGRect] = [:]
    @State private var scrollOffset: CGPoint = .zero  // Track actual scroll position
    
    // Haptic feedback
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)  // light → medium
    @State private var lastHapticCoord: GridCoord? = nil  // Track last haptic trigger
    
    // BlackHole icon animation
    @State private var blackHoleScale: CGFloat = 1.0
    
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
                                    .background(
                                        GeometryReader { cellGeo in
                                            Color.clear.preference(
                                                key: CellPositionPreferenceKey.self,
                                                value: [emotion.id: cellGeo.frame(in: .global)]
                                            )
                                        }
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
                                // Haptic feedback on tap - stronger and longer
                                let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
                                heavyHaptic.prepare()
                                heavyHaptic.impactOccurred()
                                
                                // Stage A: recenter the tapped emotion to the true screen center (faster)
                                isPreparingOverlay = true
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    scrollViewProxy?.scrollTo(centerID(for: index), anchor: .center)
                                }
                                // After the recenter animation, open the overlay (faster delay)
                                let delay = 0.3
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
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isScrolling {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    isScrolling = true
                                }
                            }
                            scrollTimer?.invalidate()
                            // Update center emotion in real-time while scrolling
                            updateCenterEmotionSmooth()
                        }
                        .onEnded { _ in
                            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                withAnimation(.easeOut(duration: 0.25)) {
                                    isScrolling = false
                                }
                            }
                        }
                )
                .background(
                    GeometryReader { scrollGeo in
                        Color.clear
                            .preference(
                                key: ScrollPositionPreferenceKey.self,
                                value: scrollGeo.frame(in: .global).midX
                            )
                            .onChange(of: scrollGeo.frame(in: .global)) { oldFrame, newFrame in
                                if isScrolling {
                                    // Update scroll offset continuously
                                    scrollOffset = CGPoint(x: newFrame.midX, y: newFrame.midY)
                                    updateCenterEmotionSmooth()
                                }
                            }
                    }
                )
                .onPreferenceChange(ScrollPositionPreferenceKey.self) { _ in
                    if isScrolling {
                        updateCenterEmotion()
                    }
                }
                .onPreferenceChange(CellPositionPreferenceKey.self) { positions in
                    cellPositions = positions
                    if isScrolling {
                        updateCenterEmotion()
                    }
                }

                // Overlay sits on top and fully hides the grid behind it
                if let fe = focusedEmotion {
                    let isMax = appState.selectedEmotions.count >= 8
                    let isDup = appState.selectedEmotions.contains { $0.id == fe.id }
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
                            
                            // Animate black hole icon
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                blackHoleScale = 1.3
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    blackHoleScale = 1.0
                                }
                            }
                            
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
                        },
                        canAdd: !(isMax || isDup),
                        onReject: {
                            if isMax { showMaxReached = true }
                            else if isDup { showAlreadySelected = true }
                        }
                    )
                    .zIndex(100)
                    .transition(.scale.combined(with: .opacity))
            }
            }
            .onAppear {
                scrollViewProxy = proxy
                // Prepare haptic generator
                hapticGenerator.prepare()
                // Initialize center emotion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    updateCenterEmotion()
                }
            }
            .overlay(alignment: .bottomLeading) {
                if isScrolling, !isPreparingOverlay, focusedEmotion == nil,
                   let coord = centerEmotionCoord {
                    XAxisIndicator(progress: Double(coord.xIdx) / 13.0)
                        .padding(.bottom, 50)
                        .transition(.opacity)
                }
            }
            .overlay(alignment: .topLeading) {
                if isScrolling, !isPreparingOverlay, focusedEmotion == nil,
                   let coord = centerEmotionCoord {
                    YAxisIndicator(progress: Double(coord.yIdx) / 13.0)
                        .padding(.top, 60)
                        .transition(.opacity)
                }
            }
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
                        .scaleEffect(blackHoleScale)
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
    
    private func updateCenterEmotion() {
        let screenCenter = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2
        )
        
        // Find emotion closest to screen center using actual positions
        var closestEmotion: Emotion?
        var minDistance: CGFloat = .infinity
        
        for emotion in emotionsGrid {
            guard let frame = cellPositions[emotion.id] else { continue }
            
            let center = CGPoint(x: frame.midX, y: frame.midY)
            let dist = distance(from: screenCenter, to: center)
            
            if dist < minDistance {
                minDistance = dist
                closestEmotion = emotion
            }
        }
        
        if let closest = closestEmotion {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) {
                centerEmotionCoord = closest.coord
            }
        }
    }
    
    // Smooth continuous position update based on interpolation
    private func updateCenterEmotionSmooth() {
        let screenCenter = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2
        )
        
        // Find the 4 nearest emotions and interpolate
        var nearestEmotions: [(emotion: Emotion, distance: CGFloat)] = []
        
        for emotion in emotionsGrid {
            guard let frame = cellPositions[emotion.id] else { continue }
            let center = CGPoint(x: frame.midX, y: frame.midY)
            let dist = distance(from: screenCenter, to: center)
            nearestEmotions.append((emotion, dist))
        }
        
        nearestEmotions.sort { $0.distance < $1.distance }
        
        if nearestEmotions.count >= 4 {
            // Get the 4 closest emotions
            let closest = Array(nearestEmotions.prefix(4))
            
            // Calculate weighted average position
            var totalWeight: CGFloat = 0
            var weightedX: CGFloat = 0
            var weightedY: CGFloat = 0
            
            for item in closest {
                let weight = 1.0 / max(item.distance, 1.0) // Inverse distance weighting
                totalWeight += weight
                weightedX += CGFloat(item.emotion.coord.xIdx) * weight
                weightedY += CGFloat(item.emotion.coord.yIdx) * weight
            }
            
            if totalWeight > 0 {
                let smoothX = weightedX / totalWeight
                let smoothY = weightedY / totalWeight
                
                // Create interpolated coord
                let interpolatedCoord = GridCoord(
                    xIdx: Int(round(smoothX)),
                    yIdx: Int(round(smoothY))
                )
                
                // Trigger haptic feedback when center emotion ACTUALLY changes (different cell)
                if let lastCoord = lastHapticCoord {
                    if lastCoord.xIdx != interpolatedCoord.xIdx || lastCoord.yIdx != interpolatedCoord.yIdx {
                        hapticGenerator.impactOccurred(intensity: 1.0)  // Full intensity
                        lastHapticCoord = interpolatedCoord
                        print("🔔 Haptic triggered: (\(interpolatedCoord.xIdx), \(interpolatedCoord.yIdx))")
                    }
                } else {
                    lastHapticCoord = interpolatedCoord
                }
                
                // Update without animation for smooth continuous movement
                centerEmotionCoord = interpolatedCoord
            }
        } else if let closest = nearestEmotions.first {
            centerEmotionCoord = closest.emotion.coord
        }
    }
    
    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx*dx + dy*dy)
    }
}

struct ScrollPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CellPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
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
