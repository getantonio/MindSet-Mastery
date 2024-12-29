import SwiftUI
import CoreData

struct PlaylistManagerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.createdAt, ascending: false)],
        animation: .default
    ) private var playlists: FetchedResults<Playlist>
    
    @State private var showNewPlaylist = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(playlists) { playlist in
                    NavigationLink {
                        PlaylistDetailView(playlist: playlist)
                    } label: {
                        PlaylistRow(playlist: playlist)
                    }
                }
                .onDelete(perform: deletePlaylists)
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showNewPlaylist = true }) {
                        Label("New Playlist", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showNewPlaylist) {
            NewPlaylistView()
        }
    }
    
    private func deletePlaylists(offsets: IndexSet) {
        withAnimation {
            offsets.map { playlists[$0] }.forEach { playlist in
                // Don't delete the default playlist
                if playlist.name != PlaylistManager.defaultPlaylistName {
                    viewContext.delete(playlist)
                }
            }
            try? viewContext.save()
        }
    }
} 