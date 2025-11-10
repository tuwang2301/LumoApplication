//
//  ConfirmationView.swift
//  LumoApplication
//
//  Created by Surface on 10/11/2025.
//

import SwiftUI
import Combine


// MARK: - Layout Mode (grid by default; radial also available)

enum BubbleLayoutMode { case grid, radial }

// MARK: - Screen

struct ConfirmEmotionsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    var layout: BubbleLayoutMode = .grid
    
    @State private var cachedBackground = AnyView(StarBackground())
    
    func remove(_ emotion: Emotion) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            appState.selectedEmotions.removeAll { $0.id == emotion.id }
            if appState.selectedEmotions.isEmpty {
                appState.path.remove(at: appState.path.count - 1)
            }
        }
    }
    
    var body: some View {
        ZStack {
            cachedBackground
    
            VStack(spacing: 24) {
                
                Text("Your Emotions")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                
                Group {
                    let displayedBubbles = Array(appState.selectedEmotions)
                    switch layout {
                    case .grid:
                        BubbleGrid(emotions: displayedBubbles, onRemove: remove)
                    case .radial:
                        RadialBubbleCloud(emotions: displayedBubbles, onRemove: remove)
                            .frame(maxHeight: 420)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 40)
                
                Spacer(minLength: 0)
                
                Button {
                    appState.path.append("visualise")
                } label: {
                    Text("Let them flow")
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCapsuleButton())
                .padding(.horizontal, 96)
                .disabled(appState.selectedEmotions.isEmpty)
                .opacity(appState.selectedEmotions.isEmpty ? 0.6 : 1)
                
                Color.clear.frame(height: 8)
            }
        }
    }
}

// MARK: - Grid layout

private struct BubbleGrid: View {
    let emotions: [Emotion]
    var onRemove: (Emotion) -> Void

    private func columnCount(for n: Int) -> Int {
        if n <= 1 { return 1 }
        return 2
    }

    var body: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 0, alignment: .center),
                         count: columnCount(for: emotions.count))

        LazyVGrid(columns: cols, spacing: 0) {
            ForEach(emotions) { emotion in
                BubbleItem(emotion: emotion, onRemove: onRemove)
                    .frame(width: 128, height: 128)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Radial (circular) layout option

private struct RadialBubbleCloud: View {
    let emotions: [Emotion]
    var onRemove: (Emotion) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(emotions.enumerated()), id: \.element.id) { idx, bubble in
                    let total = max(emotions.count, 1)
                    let angle = (Double(idx) / Double(total)) * 2 * Double.pi
                    let r = min(geo.size.width, geo.size.height) * 0.32
                    let cx = geo.size.width / 2
                    let cy = geo.size.height / 2
                    let x = cx + CGFloat(cos(angle)) * r
                    let y = cy + CGFloat(sin(angle)) * r

                    BubbleItem(emotion: bubble, onRemove: onRemove)
                        .position(x: x, y: y)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Bubble + minus button wrapper

private struct BubbleItem: View {
    let emotion: Emotion
    var onRemove: (Emotion) -> Void

    var body: some View {
        SmallBubble(
            color: EmotionPalette.shared.color(for: emotion),
            size: 128,
            emotionName: emotion.label
        )
        .overlay(alignment: .topLeading) {
            Button {
                onRemove(emotion)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .gray.opacity(0.65))
                    .shadow(radius: 2)
            }
            .padding(6)             // stays inside the hit area
            .buttonStyle(.plain)    // avoids weird list/grid styles
        }
        // .contentShape(Circle())  // remove this so the button isn’t clipped
    }
}

// MARK: - Button Style


struct PrimaryCapsuleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        return configuration.label
            .font(.headline)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    // Glass blur base
                    .fill(.ultraThinMaterial)
                    // Tint the glass with a purple gradient
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.35),
                                        Color.blue.opacity(0.25),
                                        Color.pink.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    // Glossy border highlight
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    )
                    // Soft glow
                    .shadow(color: Color.purple.opacity(isPressed ? 0.15 : 0.25),
                            radius: isPressed ? 2 : 10,
                            y: isPressed ? 1 : 4)
            )
            .cornerRadius(296)
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
    }
}

