import Foundation
import AVFoundation
import SwiftUI
import Combine // <-- ADD THIS LINE

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    // This @AppStorage property is what requires Combine
    @AppStorage("isMusicEnabled") private var isMusicEnabled = true
    
    func startPlaying(musicFileName: String) {
        // 1. Check if user wants music
        guard isMusicEnabled else { return }
        
        // 2. Check if music is already playing
        if audioPlayer?.isPlaying == true {
            return
        }
        
        // 3. Find the music file
        guard let url = Bundle.main.url(forResource: musicFileName, withExtension: nil) else {
            print("Error: Audio file '\(musicFileName)' not found.")
            return
        }
        
        do {
            // 4. Configure the app's audio session
            // .ambient = This is the most important part!
            // It allows your app's music to mix with other apps (like Spotify)
            // or to be silent if the user has something else playing.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 5. Setup the player
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // -1 = loop forever
            audioPlayer?.volume = 0.3 // Start at a low, ambient volume
            audioPlayer?.play()
            
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        // Deactivate the audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error.localizedDescription)")
        }
    }
}
