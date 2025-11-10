//
//  ContentView.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // HookView display first
            if !appState.hasSeenHook {
                HookView()
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            NavigationStack(path: $appState.path) {
                Color.clear
                LandingView()
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "explore":
                        ExploreView()
                            .toolbarBackground(.black, for: .navigationBar)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                    case "summary":
                        SummaryView()
                    case "visualise":
                        VisualiseView(selectedEmotions: appState.selectedEmotions)
                    default:
                        EmptyView()
                    }
                }
            }
            .tint(.white)
            .opacity(appState.hasSeenHook ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.5), value: appState.hasSeenHook)
    }
}
