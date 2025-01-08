import SwiftUI
import AVFoundation

struct MindSetMasteryApp: App {
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session:", error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 