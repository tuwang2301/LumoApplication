import SwiftUI

struct ExploreView: View {
    // Load emotions from JSON
    private let emotions: [Emotion] = EmotionLoader.loadEmotions()

    // Grid config
    private let gridCount: Int = 14
    private let bubbleSize: CGFloat = 120
    private let spacing: CGFloat = 20
    private let outerPadding: CGFloat = 40

    // Sort by coord so row-major layout matches JSON
    private var emotionsGrid: [Emotion] {
        emotions.sorted {
            if $0.coord.yIdx != $1.coord.yIdx {
                return $0.coord.yIdx < $1.coord.yIdx   // top to bottom
            } else {
                return $0.coord.xIdx < $1.coord.xIdx   // left to right
            }
        }
    }

    // Ensure content is larger than the viewport so scrolling is enabled
    private var contentWidth: CGFloat {
        CGFloat(gridCount) * bubbleSize + CGFloat(gridCount - 1) * spacing + outerPadding * 2
    }
    private var contentHeight: CGFloat {
        CGFloat(gridCount) * bubbleSize + CGFloat(gridCount - 1) * spacing + outerPadding * 2
    }

    var body: some View {
        ZStack {
            StarBackground()

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(bubbleSize), spacing: spacing), count: gridCount),
                    spacing: spacing
                ) {
                    ForEach(emotionsGrid) { emotion in
                        SmallBubble(
                            color: EmotionPalette.shared.color(for: emotion),
                            size: bubbleSize,
                            emotionName: emotion.label
                        )
                        .onTapGesture {
                            print("Selected: \(emotion.label)")
                        }
                    }
                }
                .padding(outerPadding)
                // Make sure the grid has enough size to scroll in both axes
                .frame(minWidth: contentWidth, minHeight: contentHeight, alignment: .topLeading)
            }

            // Top bar
            VStack {
                HStack {
                    Button { /* back */ } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Button { /* info */ } label: {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ExploreView()
}
