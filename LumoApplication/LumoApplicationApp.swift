//
//  LumoApplicationApp.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

@main
struct LumoApplicationApp: App {
    @StateObject private var appState = AppState()
    
    // 1. Add this variable
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                // 2. Add this modifier
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        // App has become active
                        // Use the file name you added in Step 1
                        AudioManager.shared.startPlaying(musicFileName: "background-music.mp3")
                    } else if newPhase == .inactive || newPhase == .background {
                        // App is no longer active
                        AudioManager.shared.stopPlaying()
                    }
                }
        }
    }
}
