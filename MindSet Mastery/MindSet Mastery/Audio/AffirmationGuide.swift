import Foundation
import Combine

class AffirmationGuide: ObservableObject {
    @Published private(set) var isProcessing = false
    private let elevenlabsAPI = ElevenLabsAPI.shared
    
    // Voice options
    enum GuideVoice: String {
        case calm = "calm_guide"
        case motivational = "motivational_coach"
        case spiritual = "spiritual_mentor"
        case custom = "cloned_voice"
    }
    
    // Generate guided session
    func createGuidedSession(
        affirmation: String,
        voice: GuideVoice,
        includePrompts: Bool = true
    ) async throws -> URL {
        let script = buildScript(affirmation: affirmation, withPrompts: includePrompts)
        return try await elevenlabsAPI.generateSpeech(text: script, voiceId: voice.rawValue)
    }
    
    // Clone user's voice
    func cloneVoice(from audioSamples: [URL]) async throws -> String {
        return try await elevenlabsAPI.cloneVoice(samples: audioSamples)
    }
    
    private func buildScript(affirmation: String, withPrompts: Bool) -> String {
        var script = ""
        if withPrompts {
            script += "Take a deep breath... "
            script += "Now, repeat after me... "
        }
        script += affirmation
        if withPrompts {
            script += "... Again, feeling the power of these words... "
            script += affirmation
            script += "... Let these words sink deep into your being."
        }
        return script
    }
} 