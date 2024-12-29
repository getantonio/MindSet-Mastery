import SwiftUI

struct PlaybackControlsView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Slider
            Slider(
                value: Binding(
                    get: { audioManager.currentTime },
                    set: { audioManager.seek(to: $0) }
                ),
                in: 0...max(audioManager.duration, 0.01)
            )
            .disabled(!audioManager.isPlaying)
            
            // Time Labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                Spacer()
                Text(formatTime(audioManager.duration))
            }
            .font(.caption)
            .monospacedDigit()
            
            // Playback Controls
            HStack(spacing: 40) {
                Button(action: {
                    // Previous track functionality can be added here
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(true)
                
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pausePlayback()
                    } else {
                        audioManager.resumePlayback()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                .disabled(audioManager.currentRecording == nil)
                
                Button(action: {
                    // Next track functionality can be added here
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 