import SwiftUI
import CoreData

struct PlaylistManagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager()
    @State private var showNewPlaylistSheet = false
    @State private var expandedPlaylists = Set<UUID>()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.createdAt, ascending: false)]
    ) private var playlists: FetchedResults<Playlist>
    
    var body: some View {
        List {
            ForEach(playlists) { playlist in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedPlaylists.contains(playlist.id!) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedPlaylists.insert(playlist.id!)
                            } else {
                                expandedPlaylists.remove(playlist.id!)
                            }
                        }
                    )
                ) {
                    if let recordings = playlist.recordings {
                        ForEach(Array(recordings)) { recording in
                            RecordingRow(recording: recording)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteRecording(recording)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } label: {
                    HStack {
                        Text(playlist.name ?? "Untitled Playlist")
                            .font(.headline)
                        Spacer()
                        Text("\(playlist.recordings?.count ?? 0) recordings")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .swipeActions(edge: .trailing) {
                        if playlist.name != PlaylistManager.defaultPlaylistName {
                            Button(role: .destructive) {
                                deletePlaylist(playlist)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Playlists")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showNewPlaylistSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showNewPlaylistSheet) {
            NavigationView {
                NewPlaylistView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func deleteRecording(_ recording: Recording) {
        if let path = recording.filePath {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
        }
        viewContext.delete(recording)
        try? viewContext.save()
    }
    
    private func deletePlaylist(_ playlist: Playlist) {
        // Delete all recordings in the playlist
        if let recordings = playlist.recordings {
            for recording in recordings {
                if let path = recording.filePath {
                    try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
                }
                viewContext.delete(recording)
            }
        }
        viewContext.delete(playlist)
        try? viewContext.save()
    }
} 