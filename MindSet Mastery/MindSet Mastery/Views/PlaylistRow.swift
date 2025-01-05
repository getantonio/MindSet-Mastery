import SwiftUI

struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(playlist.name ?? "Untitled Playlist")
                .font(.headline)
            Text("\(playlist.recordings?.count ?? 0) recordings")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 