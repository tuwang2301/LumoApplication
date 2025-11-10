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
        NavigationStack(path: $appState.path) {
            LandingView()
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "explore":
                        ExploreView()
                            .toolbarBackground(.black, for: .navigationBar)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                    case "confirmation":
                        ConfirmEmotionsView()
                    case "visualise":
                        VisualiseView(selectedEmotions: appState.selectedEmotions)
//                    case "summary":
//                        ConfirmEmotionsView()
                    default:
                        EmptyView()
                    }
                }
                .opacity(appState.hasSeenHook ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: appState.hasSeenHook)
                .onAppear {
                    // When the app's main view appears,
                    // request notification permission.
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
