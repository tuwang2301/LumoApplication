//
//  SummaryView.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var appState : AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Emotion Summary")
                .font(.title)
                .padding(.top, 60)
            
            Text("You felt Calm 😌 today")
                .font(.headline)
            
        }
        .background(.clear)
    }
}
