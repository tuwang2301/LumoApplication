//
//  ExploreView.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var appState : AppState
    @State private var showTracking = false

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button {
                    showTracking = true
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .padding()
                }
            }
            
            Spacer()
            Text("Explore Your Emotions")
                .font(.largeTitle)
                .padding()
            
            Button {
                appState.path.append("summary") // push Summary
            } label: {
                Text("Choose Emotion → Summary")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true) // Ẩn back button
        .interactiveDismissDisabled(true)   // Tắt swipe back (iOS 16+)
    }
}


#Preview {
    ExploreView()
}
