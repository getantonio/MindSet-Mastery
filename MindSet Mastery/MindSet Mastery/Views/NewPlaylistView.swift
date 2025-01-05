import SwiftUI
import CoreData

struct NewPlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    var body: some View {
        #if os(iOS)
        if #available(iOS 16.0, *) {
            NavigationStack {
                playlistForm
            }
        } else {
            NavigationView {
                playlistForm
            }
        }
        #else
        NavigationView {
            playlistForm
        }
        #endif
    }
    
    private var playlistForm: some View {
        Form {
            TextField("Playlist Name", text: $name)
        }
        .navigationTitle("New Playlist")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    createPlaylist()
                }
                .disabled(name.isEmpty)
            }
        }
        .interactiveDismissDisabled(false)
    }
    
    private func createPlaylist() {
        let playlist = Playlist(context: viewContext)
        playlist.id = UUID()
        playlist.name = name
        playlist.createdAt = Date()
        playlist.recordings = Set<Recording>()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error creating playlist: \(error)")
            viewContext.rollback()
        }
    }
} 