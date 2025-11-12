import SwiftUI
import FoundationModels // keep if you plan to wire Apple FM

struct VisualiseView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    // State management
    @State private var bigBubbleFloat: CGFloat = 0
    @State private var currentPopupEmotion: String? = nil
    @State private var fadingColors: Set<String> = []
    @State private var draggedBubble: (emotion: Emotion, offset: CGSize, position: CGPoint)?
    @State private var bigBubbleAppear: Bool = false
    @State private var cachedBackground = AnyView(StarBackground())
    
    // Tutorial states
    @State private var showTutorial: Bool = false
    @State private var firstBubblePosition: CGPoint? = nil
//    @AppStorage("hasSeenVisualiseTutorial")
    @State private var hasSeenTutorial: Bool = false

    // AI output + snapshot of final emotions
    @State private var aiMessage: String? = nil
    @State private var emotionSnapshot: [Emotion] = []
    
    // Large bubble configuration
    private let largeBubbleSize: CGFloat = 400
    private let largeBubbleCenter: CGPoint = CGPoint(x: 200, y: 320)
    
    // Active colors for animation
    var activeColors: [Color] {
        appState.selectedEmotions
            .filter { !fadingColors.contains($0.id) }
            .map { EmotionPalette.shared.color(for: $0) }
    }
    
    // Fading colors for smooth removal animation
    var fadingColorsList: [Color] {
        appState.selectedEmotions
            .filter { fadingColors.contains($0.id) }
            .map { EmotionPalette.shared.color(for: $0) }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            cachedBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 150)
                
                // Large bubble with entrance + float + animation
                ZStack {
                    ZStack {
                        if !activeColors.isEmpty || !fadingColorsList.isEmpty {
                            DynamicLightAnimation(
                                colors: activeColors,
                                fadingColors: fadingColorsList
                            )
                            .frame(width: 350, height: 350)
                            .clipShape(Circle())
                        }

                        BubbleFrame(size: largeBubbleSize)

                        if let emotionName = currentPopupEmotion {
                            EmotionNamePopup(emotionName: emotionName)
                        }
                    }
                    .scaleEffect(bigBubbleAppear ? 1.0 : 0.7)
                    .opacity(bigBubbleAppear ? 1.0 : 0.0)
                }
                .frame(width: largeBubbleSize, height: largeBubbleSize)
                .offset(y: bigBubbleFloat)
                .onAppear {
                    // Entrance
                    withAnimation(.easeOut(duration: 0.7)) { bigBubbleAppear = true }
                    // Gentle float
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        bigBubbleFloat = -14
                    }
                    // First-time tutorial
                    if !hasSeenTutorial && !appState.selectedEmotions.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showTutorial = true }
                    }
                }

                if !appState.selectedEmotions.isEmpty {
                    Spacer().frame(height: 5)
                } else {
                    Spacer().frame(height: 50)
                }
                
                // Small bubbles carousel OR final AI line
                if !appState.selectedEmotions.isEmpty {
                    SmallBubbleCarousel(
                        emotions: appState.selectedEmotions,
                        largeBubbleCenter: largeBubbleCenter,
                        largeBubbleSize: largeBubbleSize,
                        onDragStart: { emotion, position in
                            draggedBubble = (emotion, .zero, position)
                            if showTutorial {
                                withAnimation { showTutorial = false }
                                hasSeenTutorial = true
                            }
                        },
                        onDragChange: { emotion, offset in
                            if draggedBubble?.emotion.id == emotion.id {
                                draggedBubble?.offset = offset
                            }
                        },
                        onRelease: releaseEmotion,
                        onDragEnd: { draggedBubble = nil },
                        onFirstBubblePosition: { position in firstBubblePosition = position }
                    )
                    .frame(height: 180)
                    .padding(.bottom, 50)
                } else {
                    VStack(spacing: 60) {
                        if let line = aiMessage {
                            Text(line)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(10)
                                .padding(.horizontal, 32)
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            ProgressView("Preparing a note for you…")
                                .tint(.white)
                                .foregroundStyle(.white)
                        }

                        Button(action: { appState.path.removeAll() }) {
                            Text("Return to Home")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Capsule().fill(Color.white.opacity(0.2)))
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer().frame(minHeight: 20)
            }
            
            // Dragged bubble overlay
            if let dragged = draggedBubble {
                SmallBubble(
                    color: EmotionPalette.shared.color(for: dragged.emotion),
                    size: 100,
                    emotionName: dragged.emotion.label
                )
                .scaleEffect(getDragScale(for: dragged))
                .opacity(getDragOpacity(for: dragged))
                .position(
                    x: dragged.position.x + dragged.offset.width,
                    y: dragged.position.y + dragged.offset.height
                )
            }
            
            // Tutorial overlay
            if showTutorial, let startPos = firstBubblePosition {
                HandGestureTutorial(
                    startPosition: CGPoint(x: startPos.x + 30, y: startPos.y + 30),
                    endPosition: CGPoint(x: largeBubbleCenter.x, y: largeBubbleCenter.y + 50),
                    onDismiss: {
                        withAnimation { showTutorial = false }
                        hasSeenTutorial = true
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(appState.selectedEmotions.isEmpty)
        .interactiveDismissDisabled(appState.selectedEmotions.isEmpty)
        .ignoresSafeArea()
    }
    
    // MARK: - Release logic (safe snapshot → AI)
    func releaseEmotion(_ emotion: Emotion) {
        var snapshot = appState.selectedEmotions // BEFORE removal

        fadingColors.insert(emotion.id)
        draggedBubble = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                appState.selectedEmotions.removeAll { $0.id == emotion.id }
                fadingColors.remove(emotion.id)
            }

            if snapshot.isEmpty { snapshot = [emotion] } // defensive

            if appState.selectedEmotions.isEmpty {
                self.emotionSnapshot = snapshot
                Task { await generateSupportiveMessage(from: snapshot) }
            }
        }
        
        showEmotionNamePopup(emotion.label)
    }
    
    func showEmotionNamePopup(_ name: String) {
        currentPopupEmotion = name
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) { currentPopupEmotion = nil }
        }
    }
    
    func getDragScale(for dragged: (emotion: Emotion, offset: CGSize, position: CGPoint)) -> CGFloat {
        let currentX = dragged.position.x + dragged.offset.width
        let currentY = dragged.position.y + dragged.offset.height
        let dx = currentX - largeBubbleCenter.x
        let dy = currentY - largeBubbleCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        let maxDistance = largeBubbleSize / 2 + 100
        let minScale: CGFloat = 0.3
        let maxScale: CGFloat = 1.0
        if distance > maxDistance { return maxScale }
        let ratio = distance / maxDistance
        return minScale + (maxScale - minScale) * ratio
    }
    
    func getDragOpacity(for dragged: (emotion: Emotion, offset: CGSize, position: CGPoint)) -> Double {
        let scale = getDragScale(for: dragged)
        return scale < 0.5 ? Double(scale) : 1.0
    }
}

// MARK: - AI message generation (no presets, AI decides)
extension VisualiseView {
    @MainActor
    private func generateSupportiveMessage(from emotions: [Emotion]) async {
        let labels = emotions
            .map { $0.label.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let emotionList = labels.isEmpty ? "your current state" : labels.joined(separator: ", ")

        let prompt = """
        You are a gentle, supportive coach. The user just released these emotions: \(emotionList).
        Write exactly ONE short, supportive sentence (8–18 words), second person (“you”), no emojis, no exclamation marks.
        Avoid clichés and avoid repeating their words verbatim unless necessary. Output only the sentence.
        """

        // TODO: Replace the placeholder block below with your actual Foundation Models call.
        // Keep types out so this compiles even before you add the SDK call.
        do {
            // Example (pseudo):
            // let session = try await SomeFMTextSession(instructions: "Be concise, supportive, non-judgmental.")
            // let text = try await session.generate(prompt)
            // self.aiMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
            throw NSError(domain: "FM.placeholder", code: -1)
        } catch {
            self.aiMessage = fallbackLine(from: labels) // minimal generic fallback
        }

        #if DEBUG
        print("AI supportive line for [\(emotionList)]: \(aiMessage ?? "<nil>")")
        #endif
    }

    // Minimal generic fallback that builds a single sentence from labels (no preset list).
    private func fallbackLine(from labels: [String]) -> String {
        let subject = labels.isEmpty
            ? "what you feel"
            : labels.prefix(2).joined(separator: " and ").lowercased()
        return "You can notice \(subject) and let it move through at your pace."
    }
}

// MARK: - Hand Gesture Tutorial
struct HandGestureTutorial: View {
    let startPosition: CGPoint
    let endPosition: CGPoint
    let onDismiss: () -> Void
    
    @State private var handPosition: CGPoint
    @State private var opacity: Double = 0
    
    init(startPosition: CGPoint, endPosition: CGPoint, onDismiss: @escaping () -> Void) {
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.onDismiss = onDismiss
        _handPosition = State(initialValue: startPosition)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture { onDismiss() }
            
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 60))
                .position(handPosition)
                .opacity(opacity)
                .foregroundColor(.white)
            
            Text("Drag to release")
                .font(.title)
                .foregroundColor(.gray)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) { opacity = 1.0 }
            animateHand()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onDismiss()
            }
        }
    }
    
    private func animateHand() {
        withAnimation(.easeOut(duration: 0.5)) { handPosition = endPosition }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            handPosition = startPosition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateHand() }
        }
    }
}

// MARK: - Small Bubble Carousel
struct SmallBubbleCarousel: View {
    let emotions: [Emotion]
    let largeBubbleCenter: CGPoint
    let largeBubbleSize: CGFloat
    let onDragStart: (Emotion, CGPoint) -> Void
    let onDragChange: (Emotion, CGSize) -> Void
    let onRelease: (Emotion) -> Void
    let onDragEnd: () -> Void
    let onFirstBubblePosition: (CGPoint) -> Void
    
    private let bubbleSize: CGFloat = 100
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(Array(emotions.enumerated()), id: \.element.id) { index, emotion in
                    DraggableSmallBubble(
                        emotion: emotion,
                        index: index,
                        totalCount: emotions.count,
                        largeBubbleCenter: largeBubbleCenter,
                        largeBubbleSize: largeBubbleSize,
                        bubbleSize: bubbleSize,
                        onDragStart: onDragStart,
                        onDragChange: onDragChange,
                        onRelease: onRelease,
                        onDragEnd: onDragEnd,
                        onPositionReady: { position in
                            if index == 0 {
                                onFirstBubblePosition(position)
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 100)
            .frame(height: UIScreen.main.bounds.height)
            .frame(maxWidth: .infinity, alignment: .center)

            if emotions.count < 5 {
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Draggable Small Bubble
struct DraggableSmallBubble: View {
    let emotion: Emotion
    let index: Int
    let totalCount: Int
    let largeBubbleCenter: CGPoint
    let largeBubbleSize: CGFloat
    let bubbleSize: CGFloat
    let onDragStart: (Emotion, CGPoint) -> Void
    let onDragChange: (Emotion, CGSize) -> Void
    let onRelease: (Emotion) -> Void
    let onDragEnd: () -> Void
    let onPositionReady: (CGPoint) -> Void
    
    @State private var isBeingDragged: Bool = false
    @State private var currentOffset: CGSize = .zero
    @State private var isReleasing: Bool = false
    
    private var arcOffset: CGFloat {
       let visibleCount = min(totalCount, 4)
       let arcRadius: CGFloat = -50
       if visibleCount == 1 { return 0 }
       let midPoint = CGFloat(visibleCount - 1) / 2.0
       let distanceFromCenter = abs(CGFloat(index) - midPoint)
       let normalizedDistance = distanceFromCenter / midPoint
       return -50 * normalizedDistance
    }
    
    private func isInsideLargeBubble(position: CGPoint, offset: CGSize) -> Bool {
        let currentX = position.x + offset.width
        let currentY = position.y + offset.height
        let dx = currentX - largeBubbleCenter.x
        let dy = currentY - largeBubbleCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        return distance < largeBubbleSize / 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            SmallBubble(
                color: EmotionPalette.shared.color(for: emotion),
                size: bubbleSize,
                emotionName: emotion.label
            )
            .opacity(isBeingDragged || isReleasing ? 0 : 1.0)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                let frame = geo.frame(in: .global)
                                let center = CGPoint(x: frame.midX, y: frame.midY + arcOffset)
                                onPositionReady(center)
                            }
                        }
                }
            )
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        if !isBeingDragged {
                            isBeingDragged = true
                            onDragStart(emotion, value.startLocation)
                        }
                        currentOffset = value.translation
                        onDragChange(emotion, value.translation)
                    }
                    .onEnded { value in
                        isBeingDragged = false
                        if isInsideLargeBubble(position: value.startLocation, offset: value.translation) {
                            isReleasing.toggle()
                            onRelease(emotion)
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentOffset = .zero
                            }
                        }
                        onDragEnd()
                    }
            )
        }
        .frame(width: bubbleSize, height: bubbleSize)
    }
}

// MARK: - Emotion Name Popup
struct EmotionNamePopup: View {
    let emotionName: String
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Text(emotionName)
            .font(.system(size: 42, weight: .semibold))
            .foregroundColor(.white)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    scale = 1.3
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeInOut(duration: 2)) {
                        scale = 0.8
                        opacity = 0.0
                    }
                }
            }
    }
}

// MARK: - Dynamic Light Animation
struct DynamicLightAnimation: View {
    let colors: [Color]
    let fadingColors: [Color]
    
    @State private var rotation: Double = 0
    @State private var pulse: Double = 1.0
    @State private var fadingOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.85),
                                color.opacity(0.6),
                                color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 10)
                    .scaleEffect(pulse + Double(index) * 0.12)
                    .offset(
                        x: cos(rotation / 30 + Double(index) * 2) * 55,
                        y: sin(rotation / 30 + Double(index) * 2) * 55
                    )
                    .opacity(0.9)
            }
            
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.7),
                                color.opacity(0.3),
                                color.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 80)
                    .blur(radius: 18)
                    .rotationEffect(.degrees(-rotation * 1.5 + Double(index) * 45))
                    .offset(
                        x: sin(rotation / 25 + Double(index)) * 50,
                        y: cos(rotation / 25 + Double(index)) * 50
                    )
                    .opacity(0.8)
            }
            
            ForEach(Array(fadingColors.enumerated()), id: \.offset) { _, color in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.9 * fadingOpacity),
                                color.opacity(0.5 * fadingOpacity),
                                color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .blur(radius: 30)
                    .scaleEffect(1.2 - (1.0 - fadingOpacity) * 0.7)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                rotation = 1440
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulse = 1.15
            }
        }
        .onChange(of: fadingColors) { _, _ in
            fadingOpacity = 1.0
            withAnimation(.easeOut(duration: 0.8)) {
                fadingOpacity = 0.0
            }
        }
    }
}

#Preview {
    VisualiseView()
        .environmentObject(AppState())
}
