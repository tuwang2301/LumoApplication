//
//  EmotionLoader.swift
//  LumoApplication
//
//  Created by Ina Song on 9/11/2025.
//
import Foundation

class EmotionLoader {
    static func loadEmotions() -> [Emotion] {
        guard let url = Bundle.main.url(forResource: "lumo_emotions_14x14", withExtension: "json") else {
            print("JSON file not found in bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let emotions = try JSONDecoder().decode([Emotion].self, from: data)
            print("Loaded \(emotions.count) emotions.")
            return emotions
        } catch {
            print("Failed to decode JSON: \(error)")
            return []
        }
    }
}


