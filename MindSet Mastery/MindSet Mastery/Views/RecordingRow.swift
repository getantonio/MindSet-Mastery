import SwiftUI
import CoreData

struct RecordingRow: View {
    let recording: Recording
    @StateObject private var audioManager = AudioManager()
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.name, ascending: true)]
    ) private var playlists: FetchedResults<Playlist>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(recording.wrappedTitle)
                .font(.headline)
            Text(recording.wrappedCategoryName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            audioManager.startPlayback(recording: recording)
        }
        .contextMenu {
            Menu("Move to Playlist") {
                ForEach(playlists) { playlist in
                    if playlist != recording.playlist {
                        Button(playlist.name ?? "Untitled") {
                            moveRecording(to: playlist)
                        }
                    }
                }
            }
        }
    }
    
    private func moveRecording(to playlist: Playlist) {
        recording.playlist = playlist
        try? viewContext.save()
    }
} 