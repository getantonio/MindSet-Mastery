import SwiftUI
import MediaPlayer

struct PlaybackControlBar: View {
    @EnvironmentObject private var audioPlayerVM: AudioPlayerViewModel
    @State private var volume: Double = 0.5
    @State private var isShowingPlaylist = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Current Playing Info
            if let recording = audioPlayerVM.audioManager.currentRecording {
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
            ProgressView(value: audioPlayerVM.audioManager.currentTime, total: audioPlayerVM.audioManager.duration)
                .tint(.green)
                .padding(.horizontal)
            
            // Controls
            HStack(spacing: 20) {
                // Volume Slider
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume, in: 0...1) { _ in
                        audioPlayerVM.audioManager.setVolume(volume)
                    }
                    Image(systemName: "speaker.wave.3.fill")
                }
                .frame(width: 120)
                
                // Playback Controls
                Button(action: audioPlayerVM.audioManager.previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                
                Button(action: {
                    if audioPlayerVM.audioManager.isPlaying {
                        audioPlayerVM.audioManager.pausePlayback()
                    } else {
                        audioPlayerVM.audioManager.resumePlayback()
                    }
                }) {
                    Image(systemName: audioPlayerVM.audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                }
                
                Button(action: audioPlayerVM.audioManager.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                
                // Loop Button
                Button(action: { audioPlayerVM.audioManager.isLooping.toggle() }) {
                    Image(systemName: audioPlayerVM.audioManager.isLooping ? "repeat.1" : "repeat")
                        .foregroundColor(audioPlayerVM.audioManager.isLooping ? .green : .primary)
                }
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .sheet(isPresented: $isShowingPlaylist) {
            NavigationView {
                if let playlist = audioPlayerVM.audioManager.currentPlaylist {
                    PlaylistDetailView(playlist: playlist)
                        .environmentObject(audioPlayerVM)
                }
            }
            .interactiveDismissDisabled(false)
        }
    }
} 