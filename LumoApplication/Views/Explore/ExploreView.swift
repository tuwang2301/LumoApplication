////
////  ExploreView.swift
////  LumoApplication
////
////  Created by Quang Tu Nguyen on 6/11/2025.
////
//
//import SwiftUI
//
//struct ExploreView: View {
//    @EnvironmentObject var appState : AppState
//    @State private var showTracking = false
//
//    var body: some View {
//        VStack(spacing: 30) {
//            HStack {
//                Spacer()
//                Button {
//                    showTracking = true
//                } label: {
//                    Image(systemName: "chart.bar.xaxis")
//                        .font(.title2)
//                        .padding()
//                }
//            }
//            
//            Spacer()
//            Text("Explore Your Emotions")
//                .font(.largeTitle)
//                .padding()
//            
//            Button {
//                appState.path.append("summary") // push Summary
//            } label: {
//                Text("Choose Emotion → Summary")
//                    .padding()
//                    .background(Color.orange)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//            }
//            Spacer()
//        }
//        .navigationBarBackButtonHidden(true) // Ẩn back button
//        .interactiveDismissDisabled(true)   // Tắt swipe back (iOS 16+)
//    }
//}
//
//
//#Preview {
//    ExploreView()
//}

import SwiftUI

struct ExploreView: View {
    // Load emotions from JSON
    let emotions: [Emotion] = EmotionLoader.loadEmotions()
    
    // Bubble size for grid
    private let bubbleSize: CGFloat = 120
    private let spacing: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Star background
            StarBackground()
            
            // Scrollable emotion grid
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(bubbleSize), spacing: spacing), count: 14),
                    spacing: spacing
                ) {
                    ForEach(emotions) { emotion in
                        SmallBubble(
                            color: EmotionPalette.shared.color(for: emotion),
                            size: bubbleSize,
                            emotionName: emotion.label
                        )
                        .onTapGesture {
                            // TODO: Handle emotion selection
                            print("Selected: \(emotion.label)")
                        }
                    }
                }
                .padding(40)
            }
            
            // Navigation bar
            VStack {
                HStack {
                    Button(action: {
                        // TODO: Back action
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Info action
                    }) {
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
