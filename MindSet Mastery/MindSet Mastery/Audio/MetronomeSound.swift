import AVFoundation

class MetronomeSound {
    enum TickSound {
        case classic    // Classic mechanical metronome sound
        case digital    // Sharp electronic beep
        case soft      // Softer, muted tick
        case wooden    // Wood block sound
        case accent    // For first beat emphasis
        
        var frequency: Float {
            switch self {
            case .classic: return 1000.0  // 1kHz
            case .digital: return 1500.0  // 1.5kHz
            case .soft: return 800.0      // 800Hz
            case .wooden: return 400.0    // 400Hz
            case .accent: return 1200.0   // 1.2kHz
            }
        }
        
        var duration: Float {
            switch self {
            case .classic: return 0.1
            case .digital: return 0.05
            case .soft: return 0.15
            case .wooden: return 0.12
            case .accent: return 0.12
            }
        }
    }
    
    static func createTickSound(_ type: TickSound = .classic) -> URL {
        let sampleRate = 44100.0
        let duration = Double(type.duration)
        let numSamples = Int(sampleRate * duration)
        
        var audioData = [Float](repeating: 0.0, count: numSamples)
        
        // Create the waveform
        for i in 0..<numSamples {
            let t = Float(i) / Float(sampleRate)
            let frequency = type.frequency
            
            // Base sine wave
            var sample = sin(2.0 * .pi * frequency * t)
            
            // Add harmonics for richer sound
            switch type {
            case .wooden:
                // Add wooden overtones
                sample += 0.5 * sin(4.0 * .pi * frequency * t)
                sample += 0.25 * sin(6.0 * .pi * frequency * t)
            case .accent:
                // Add emphasis
                sample += 0.7 * sin(2.0 * .pi * (frequency * 1.5) * t)
            case .soft:
                // Softer harmonics
                sample += 0.3 * sin(3.0 * .pi * frequency * t)
            default:
                break
            }
            
            // Normalize
            sample = sample / 2.0
            
            // Apply envelope
            let attack = min(Float(i) / (Float(sampleRate) * 0.01), 1.0)  // 10ms attack
            let release = 1.0 - (Float(i) / Float(numSamples))
            let envelope = attack * pow(release, type == .soft ? 0.5 : 2.0)
            
            audioData[i] = sample * envelope
        }
        
        // Create audio file
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).wav")
        let audioFile = try! AVAudioFile(forWriting: url, settings: [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true
        ])
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(numSamples))!
        buffer.floatChannelData!.pointee.update(from: audioData, count: numSamples)
        buffer.frameLength = AVAudioFrameCount(numSamples)
        
        try! audioFile.write(from: buffer)
        
        return url
    }
} 