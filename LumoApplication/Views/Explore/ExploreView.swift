//
//  ContentView.swift
//  AppleWatchHome
//
//  Created by Pedro Rojas on 29/09/21.
//

import SwiftUI

struct ExploreView: View {
    private static let size: CGFloat = 150
    private static let spacingBetweenColumns: CGFloat = 0
    private static let spacingBetweenRows: CGFloat = 0
    private static let totalColumns: Int = 14
    
    @EnvironmentObject var appState: AppState
    
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
        ZStack {
            StarBackground()

//            Axes()
//                .edgesIgnoringSafeArea([.all])
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
                        .onTapGesture(perform: {
                            if(appState.selectedEmotions.count < 9) {
                                appState.selectedEmotions.append(emotion)
                            }
                        })
                        // You need to add height
                        .frame(
                            height: Self.size
                        )
                    }
                }
            }
        }
        .toolbar {
            // Right Button
            ToolbarItem(placement: .navigationBarTrailing, ) {
                   Button(action: {
                       appState.path.append("visualise")
                   }) {
                       Image("BlackHole")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 44, height: 44)
                           .badge(count: appState.selectedEmotions.count)
                   }
                   .padding()
           }
            
        }
        .toolbarBackground(.hidden, for: .navigationBar) // Ẩn background

    }

    
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

        // We need to consider the offset for even rows!
        let x = (rowNumber % 2 == 0)
        ? proxy.frame(in: .global).midX + Self.size/2 + Self.spacingBetweenColumns/2
        : proxy.frame(in: .global).midX

        let y = proxy.frame(in: .global).midY
        let maxDistanceToCenter = getDistanceFromEdgeToCenter(x: x, y: y)

        let currentPoint = CGPoint(x: x, y: y)
        let distanceFromCurrentPointToCenter = distanceBetweenPoints(p1: center, p2: currentPoint)

        // This creates a threshold for not just the pure center could get
        // the max scaleValue.
        let distanceDelta = min(
            abs(distanceFromCurrentPointToCenter - maxDistanceToCenter),
            maxDistanceToCenter*0.3
        )

        // Helps to get closer to scale 1.0 after the threshold.
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

        return CGFloat(
            sqrt(
                pow(xDistance, 2) + pow(yDistance, 2)
            )
        )
    }

    func slope(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return (p2.y - p1.y)/(p2.x - p1.x)
    }

    func angle(slope: CGFloat) -> CGFloat {
        return abs(atan(slope) * 180 / .pi)
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
                    .background(
                        Circle()
                            .fill(Color.red)
                    )
                    .offset(x: 0, y: 20)
            }
        }
    }
}

#Preview{
    ExploreView()
}

//struct Axes: View {
//    var body: some View {
//
//        GeometryReader { geometry in
//            Path { path in
//                path.move(to: CGPoint(x: geometry.frame(in: .global).maxX, y: geometry.frame(in: .global).midY))
//                path.addLine(to: CGPoint(x: 0, y: geometry.frame(in: .global).midY))
//                path.move(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY))
//                path.addLine(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).maxY))
//
//                path.addLine(to: CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).minY - 60))
//            }
//            .stroke(Color.blue, lineWidth: 3)
//        }
//    }
//}
