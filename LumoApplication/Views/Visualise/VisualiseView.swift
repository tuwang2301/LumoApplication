import SwiftUI

struct VisualiseView: View {
    let selectedEmotions: [Emotion]
    
    // State management
    @State private var bigBubbleFloat: CGFloat = 0
    @State private var remainingEmotions: [Emotion]
    @State private var releasedEmotions: [Emotion] = []
    @State private var currentPopupEmotion: String? = nil
    @State private var fadingColors: Set<String> = []
    @State private var draggedBubble: (emotion: Emotion, offset: CGSize, position: CGPoint)?
    
    @State private var cachedBackground = AnyView(StarBackground())

    
    // Large bubble configuration
    private let largeBubbleSize: CGFloat = 400
    private let largeBubbleCenter: CGPoint
    
    init(selectedEmotions: [Emotion]) {
        self.selectedEmotions = selectedEmotions
        _remainingEmotions = State(initialValue: selectedEmotions)
        
        self.largeBubbleCenter = CGPoint(
            x: 200,
            y: 320
        )
    }
    
    // Active colors for animation
    var activeColors: [Color] {
        remainingEmotions
            .filter { !fadingColors.contains($0.id) }
            .map { EmotionPalette.shared.color(for: $0) }
    }
    
    // Fading colors for smooth removal animation
    var fadingColorsList: [Color] {
        remainingEmotions
            .filter { fadingColors.contains($0.id) }
            .map { EmotionPalette.shared.color(for: $0) }
    }
    
    var body: some View {
        ZStack {
            cachedBackground
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 150)
                
                // Large bubble with animation
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
                .frame(width: largeBubbleSize, height: largeBubbleSize)
                .offset(y: bigBubbleFloat)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        bigBubbleFloat = -14
                    }
                }
                .frame(width: largeBubbleSize, height: largeBubbleSize)
                
                Spacer()
                    .frame(height: 5)
                
                // Small bubbles carousel
                if !remainingEmotions.isEmpty {
                    SmallBubbleCarousel(
                        emotions: remainingEmotions,
                        largeBubbleCenter: largeBubbleCenter,
                        largeBubbleSize: largeBubbleSize,
                        onDragStart: { emotion, position in
                            draggedBubble = (emotion, .zero, position)
                        },
                        onDragChange: { emotion, offset in
                            if draggedBubble?.emotion.id == emotion.id {
                                draggedBubble?.offset = offset
                            }
                        },
                        onRelease: releaseEmotion
                    )
                    .frame(height: 180)
                    .padding(.bottom, 60)
                } else {
                    VStack(spacing: 20) {
                        Text("Emotions are just visitors, let them come and go")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: {
                            // TODO: Navigate back
                        }) {
                            Text("Return to Home")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                    }
                    .padding(.bottom, 60)
                }
                
                Spacer()
                    .frame(minHeight: 20)
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
        
        }
        .ignoresSafeArea()
    }
    
    func releaseEmotion(_ emotion: Emotion) {
        fadingColors.insert(emotion.id)
        draggedBubble = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                remainingEmotions.removeAll { $0.id == emotion.id }
                releasedEmotions.append(emotion)
                fadingColors.remove(emotion.id)
            }
        }
        
        showEmotionNamePopup(emotion.label)
    }
    
    func showEmotionNamePopup(_ name: String) {
        currentPopupEmotion = name
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                currentPopupEmotion = nil
            }
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
        
        if distance > maxDistance {
            return maxScale
        }
        
        let ratio = distance / maxDistance
        return minScale + (maxScale - minScale) * ratio
    }
    
    func getDragOpacity(for dragged: (emotion: Emotion, offset: CGSize, position: CGPoint)) -> Double {
        let scale = getDragScale(for: dragged)
        return scale < 0.5 ? Double(scale) : 1.0
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
    
    private let bubbleSize: CGFloat = 100
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
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
                        onRelease: onRelease
                    )
                }
            }
            .padding(.vertical, 10)
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
    
    @State private var isBeingDragged: Bool = false
    
    private var arcOffset: CGSize {
        let visibleCount = min(totalCount, 4)
        let arcRadius: CGFloat = 20
        let totalAngle: CGFloat = .pi / 2
        let startAngle: CGFloat = .pi / 6
        
        if visibleCount == 1 {
            return CGSize(width: 0, height: arcRadius)
        }
        
        let angleStep = totalAngle / CGFloat(max(visibleCount - 1, 1))
        let angle = startAngle + angleStep * CGFloat(index)
        
        let x = arcRadius * cos(angle)
        let y = arcRadius * sin(angle)
        
        return CGSize(width: x, height: y)
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
        SmallBubble(
            color: EmotionPalette.shared.color(for: emotion),
            size: bubbleSize,
            emotionName: emotion.label
        )
        .offset(x: arcOffset.width, y: arcOffset.height)
        .opacity(isBeingDragged ? 0.3 : 1.0)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !isBeingDragged {
                        isBeingDragged = true
                        onDragStart(emotion, value.startLocation)
                    }
                    onDragChange(emotion, value.translation)
                }
                .onEnded { value in
                    isBeingDragged = false
                    
                    if isInsideLargeBubble(position: value.startLocation, offset: value.translation) {
                        onRelease(emotion)
                    }
                }
        )
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
            
            ForEach(Array(fadingColors.enumerated()), id: \.offset) { index, color in
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

// MARK: - Preview
#Preview {
    let sampleEmotions = [
        Emotion(id: "anxious", label: "Anxious", coord: GridCoord(xIdx: 0, yIdx: 8), description: nil, vRaw: 0.0, aRaw: 0.615),
        Emotion(id: "frustrated", label: "Frustrated", coord: GridCoord(xIdx: 3, yIdx: 9), description: nil, vRaw: 0.231, aRaw: 0.692),
        Emotion(id: "joyful", label: "Joyful", coord: GridCoord(xIdx: 13, yIdx: 10), description: nil, vRaw: 1.0, aRaw: 0.769),
        Emotion(id: "calm", label: "Calm", coord: GridCoord(xIdx: 7, yIdx: 0), description: nil, vRaw: 0.538, aRaw: 0.0)
    ]
    
    VisualiseView(selectedEmotions: sampleEmotions)
}
