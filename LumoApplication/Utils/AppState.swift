//
//  AppState.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import Combine

class AppState: ObservableObject {
    @Published var hasSeenHook = false
    @Published var selectedEmotions: [Emotion] = []
    @Published var path: [String] = []
    @Published var hasSeenExploreTutorial = false
    @Published var hasSeenVisualiseTutorial = false
}
