import Foundation
import AVFoundation
import Combine

class AffirmationMixer: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published var tickSoundType: MetronomeSound.TickSound = .classic {
        didSet {
            updateTickSound()
        }
    }
    @Published var selectedSpeed: Speed = .bpm100 {
        didSet {
            if isPlaying {
                updateMetronomeSpeed(to: selectedSpeed.rawValue)
            }
        }
    }
    
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
        case bpm20 = 20
        case bpm40 = 40
        case bpm60 = 60
        case bpm80 = 80
        case bpm100 = 100
        case bpm120 = 120
        case bpm140 = 140
        case bpm160 = 160
        case bpm180 = 180
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
        isPlaying = true
        // Create audio player
        metronomePlayer = try? AVAudioPlayer(contentsOf: tickSound)
        metronomePlayer?.prepareToPlay()
        
        updateMetronomeSpeed(to: bpm)
        playTick()  // Play first tick immediately
    }
    
    func stopMetronome() {
        isPlaying = false
        metronomeTimer?.invalidate()
        metronomeTimer = nil
        metronomePlayer?.stop()
        metronomePlayer = nil
    }
    
    private func playTick() {
        metronomePlayer?.currentTime = 0
        metronomePlayer?.play()
    }
    
    private func updateMetronomeSpeed(to bpm: Double) {
        let interval = 60.0 / bpm
        metronomeTimer?.invalidate()
        metronomeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playTick()
        }
    }
    
    private func updateTickSound() {
        tickSound = MetronomeSound.createTickSound(tickSoundType)
        if isPlaying {
            // Update the player with new sound without stopping
            metronomePlayer = try? AVAudioPlayer(contentsOf: tickSound)
            metronomePlayer?.prepareToPlay()
        }
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