//
//  ConfirmationView.swift
//  LumoApplication
//
//  Created by Surface on 10/11/2025.
//

import SwiftUI
import Combine

// MARK: - Model

struct EmotionBubble: Identifiable, Equatable {
    let id = UUID()
    var label: String
    var color: Color
}

// MARK: - ViewModel

final class ConfirmEmotionsViewModel: ObservableObject {
    @Published var bubbles: [EmotionBubble]

    init() {
        // Each emotion is assigned to a coordinate in the 14x14 palette grid.
        // Adjust these coordinates to position them nicely around your emotion wheel.
        let emotionPositions: [(label: String, coord: GridCoord)] = [
            ("Lonely",       GridCoord(xIdx: 6, yIdx: 10)),
            ("Insecure",     GridCoord(xIdx: 8, yIdx: 9)),
            ("Empty",        GridCoord(xIdx: 5, yIdx: 8)),
            ("Nervous",      GridCoord(xIdx: 9, yIdx: 7)),
            ("Overwhelmed",  GridCoord(xIdx: 4, yIdx: 9)),
            ("Tired",        GridCoord(xIdx: 7, yIdx: 11)),
            ("Stressed",     GridCoord(xIdx: 10, yIdx: 8)),
            ("Anxious",      GridCoord(xIdx: 9, yIdx: 10))
        ]

        self.bubbles = emotionPositions.map { pair in
            EmotionBubble(
                label: pair.label,
                color: EmotionPalette.shared.color(for: pair.coord)
            )
        }
    }

    func remove(_ bubble: EmotionBubble) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            bubbles.removeAll { $0.id == bubble.id }
        }
    }
}


// MARK: - Layout Mode (grid by default; radial also available)

enum BubbleLayoutMode { case grid, radial }

// MARK: - Screen

struct ConfirmEmotionsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm = ConfirmEmotionsViewModel()
    var layout: BubbleLayoutMode = .grid
    var onRelease: (([EmotionBubble]) -> Void)?
    
    // Give the background a stable identity for the lifetime of this view
    private let persistentBackground = StarBackground()
    
    var body: some View {
        ZStack {
            persistentBackground
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0)))
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Your Emotions")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                
                Group {
                    let displayedBubbles = Array(vm.bubbles.prefix(8))
                    switch layout {
                    case .grid:
                        BubbleGrid(bubbles: displayedBubbles, onRemove: vm.remove)
                    case .radial:
                        RadialBubbleCloud(bubbles: displayedBubbles, onRemove: vm.remove)
                            .frame(maxHeight: 420)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, 40)
                // Remove the global animation to avoid touching unrelated views.
                // You already animate deletions inside `remove(_:)`.
                // .animation(.spring(response: 0.35, dampingFraction: 0.9), value: vm.bubbles)
                
                Spacer(minLength: 0)
                
                Button {
                    onRelease?(vm.bubbles)
                } label: {
                    Text("Let them flow")
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryCapsuleButton())
                .padding(.horizontal, 96)
                .disabled(vm.bubbles.isEmpty)
                .opacity(vm.bubbles.isEmpty ? 0.6 : 1)
                
                Color.clear.frame(height: 8)
            }
        }
        .onChange(of: vm.bubbles.count) { oldValue, newValue in
            if newValue == 0 {
                dismiss()
            }
        }
    }
}

// MARK: - Grid layout

private struct BubbleGrid: View {
    let bubbles: [EmotionBubble]
    var onRemove: (EmotionBubble) -> Void

    private func columnCount(for n: Int) -> Int {
        if n <= 1 { return 1 }
        return 2
    }

    var body: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 0, alignment: .center),
                         count: columnCount(for: bubbles.count))

        LazyVGrid(columns: cols, spacing: 0) {
            ForEach(bubbles) { bubble in
                BubbleItem(bubble: bubble, onRemove: onRemove)
                    .frame(width: 128, height: 128)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Radial (circular) layout option

private struct RadialBubbleCloud: View {
    let bubbles: [EmotionBubble]
    var onRemove: (EmotionBubble) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(bubbles.enumerated()), id: \.element.id) { idx, bubble in
                    let total = max(bubbles.count, 1)
                    let angle = (Double(idx) / Double(total)) * 2 * Double.pi
                    let r = min(geo.size.width, geo.size.height) * 0.32
                    let cx = geo.size.width / 2
                    let cy = geo.size.height / 2
                    let x = cx + CGFloat(cos(angle)) * r
                    let y = cy + CGFloat(sin(angle)) * r

                    BubbleItem(bubble: bubble, onRemove: onRemove)
                        .frame(width: 128, height: 128)
                        .position(x: x, y: y)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Bubble + minus button wrapper

private struct BubbleItem: View {
    let bubble: EmotionBubble
    var onRemove: (EmotionBubble) -> Void

    var body: some View {
        SmallBubble(color: bubble.color, size: 128, emotionName: bubble.label)
            .frame(width: 128, height: 128)
            .overlay(alignment: .topLeading) {
                Button {
                    onRemove(bubble)
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

// MARK: - Preview

#Preview {
    ConfirmEmotionsView(layout: .grid) { bubbles in
        print("Release tapped with \(bubbles.count) bubbles")
    }
}

