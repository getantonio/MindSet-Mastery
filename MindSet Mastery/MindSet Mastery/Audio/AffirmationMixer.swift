import Foundation
import AVFoundation
import Combine

class AffirmationMixer: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published var tickSoundType: MetronomeSound.TickSound = .classic
    @Published var selectedSpeed: Speed = .medium
    
    private let elevenlabsAPI = ElevenLabsAPI.shared
    private var metronomePlayer: AVAudioPlayer?
    private var metronomeTimer: Timer?
    private var tickSound: URL
    
    init() {
        // Initialize tickSound first
        self.tickSound = MetronomeSound.createTickSound(.classic)
        // Then call updateTickSound for any additional setup
        updateTickSound()
    }
    
    // Metronome speeds (BPM)
    enum Speed: Double, CaseIterable {
        case verySlow = 40
        case slow = 60
        case medium = 80
        case fast = 100
        case veryFast = 120
    }
    
    func generateAffirmationTrack(
        text: String,
        voiceId: String,
        speed: Speed,
        backgroundTrack: BackgroundTrack
    ) async throws -> URL {
        // Generate voice audio from text
        let voiceAudio = try await elevenlabsAPI.generateSpeech(
            text: text,
            voiceId: voiceId
        )
        
        // Mix with background track and metronome
        return try await mixAudio(
            voice: voiceAudio,
            background: backgroundTrack,
            bpm: speed.rawValue
        )
    }
    
    func mixAudio(voice: URL, background: BackgroundTrack, bpm: Double) async throws -> URL {
        // TODO: Implement audio mixing
        return voice
    }
    
    func startMetronome(bpm: Double) {
        stopMetronome()  // Stop any existing metronome
        
        let interval = 60.0 / bpm
        
        // Create audio player
        metronomePlayer = try? AVAudioPlayer(contentsOf: tickSound)
        metronomePlayer?.prepareToPlay()
        
        // Start timer
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playTick()
        }
        
        playTick()  // Play first tick immediately
    }
    
    func stopMetronome() {
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        metronomePlayer?.stop()
        metronomePlayer = nil
    }
    
    private func playTick() {
        metronomePlayer?.currentTime = 0
        metronomePlayer?.play()
    }
    
    private func updateTickSound() {
        tickSound = MetronomeSound.createTickSound(tickSoundType)
    }
    
    // Add method to change sound type
    func changeTickSound(to type: MetronomeSound.TickSound) {
        tickSoundType = type
        updateTickSound()
        if isPlaying {
            // Now we can access selectedSpeed
            let currentBPM = selectedSpeed.rawValue
            stopMetronome()
            startMetronome(bpm: currentBPM)
        }
    }
    
    deinit {
        stopMetronome()
    }
}

// Background track options
enum BackgroundTrack: String, CaseIterable {
    case calm = "ambient_calm"
    case energetic = "upbeat_energy"
    case spiritual = "deep_meditation"
    case nature = "forest_sounds"
    case cosmic = "space_harmony"
} 