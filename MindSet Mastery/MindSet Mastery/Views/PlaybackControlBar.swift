import SwiftUI
import MediaPlayer

struct PlaybackControlBar: View {
    @StateObject private var audioManager = AudioManager()
    @State private var volume: Double = 0.5
    @State private var isShowingPlaylist = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Current Playing Info
            if let recording = audioManager.currentRecording {
                HStack {
                    VStack(alignment: .leading) {
                        Text(recording.wrappedTitle)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(recording.wrappedCategoryName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { isShowingPlaylist.toggle() }) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Progress Bar
            ProgressView(value: audioManager.currentTime, total: audioManager.duration)
                .tint(.green)
                .padding(.horizontal)
            
            // Controls
            HStack(spacing: 20) {
                // Volume Slider
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume, in: 0...1) { _ in
                        audioManager.setVolume(volume)
                    }
                    Image(systemName: "speaker.wave.3.fill")
                }
                .frame(width: 120)
                
                // Playback Controls
                Button(action: audioManager.previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.pausePlayback()
                    } else {
                        audioManager.resumePlayback()
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                }
                
                Button(action: audioManager.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                
                // Loop Button
                Button(action: { audioManager.isLooping.toggle() }) {
                    Image(systemName: audioManager.isLooping ? "repeat.1" : "repeat")
                        .foregroundColor(audioManager.isLooping ? .green : .primary)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .sheet(isPresented: $isShowingPlaylist) {
            NavigationView {
                if let playlist = audioManager.currentPlaylist {
                    PlaylistDetailView(playlist: playlist)
                }
            }
        }
    }
} 