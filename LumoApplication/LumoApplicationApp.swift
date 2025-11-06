//
//  LumoApplicationApp.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

@main
struct EmotionApp: App {
    @StateObject var appState: AppState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
