import SwiftUI
import CoreData

struct PlaylistManagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var audioPlayerVM: AudioPlayerViewModel
    @State private var showNewPlaylistSheet = false
    @State private var expandedPlaylists = Set<UUID>()
    @State private var editingPlaylist: Playlist?
    @State private var newName = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.createdAt, ascending: false)]
    ) private var playlists: FetchedResults<Playlist>
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
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
                                ForEach(Array(recordings).sorted(by: { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) })) { recording in
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
                                if playlist.name != PlaylistManager.defaultPlaylistName {
                                    Button {
                                        editingPlaylist = playlist
                                        newName = playlist.name ?? ""
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let recordings = playlist.recordings,
                                   let firstRecording = Array(recordings).sorted(by: { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }).first {
                                    audioPlayerVM.audioManager.setCurrentPlaylist(playlist)
                                    audioPlayerVM.audioManager.startPlayback(recording: firstRecording)
                                }
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
                
                // Playback controls
                PlaybackControlBar()
                    .environmentObject(audioPlayerVM)
                    .background(.ultraThinMaterial)
            }
            .alert("Rename Playlist", isPresented: Binding(
                get: { editingPlaylist != nil },
                set: { if !$0 { editingPlaylist = nil } }
            )) {
                TextField("Playlist Name", text: $newName)
                Button("Cancel") {
                    editingPlaylist = nil
                }
                Button("Save") {
                    if let playlist = editingPlaylist {
                        playlist.name = newName
                        try? viewContext.save()
                    }
                    editingPlaylist = nil
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