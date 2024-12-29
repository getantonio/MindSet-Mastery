import SwiftUI
import CoreData

struct PlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: false)],
        predicate: NSPredicate(format: "playlist.name == %@", PlaylistManager.defaultPlaylistName)
    ) private var recordings: FetchedResults<Recording>
    
    var body: some View {
        List {
            if recordings.isEmpty {
                ContentUnavailableView(
                    "No Recordings",
                    systemImage: "waveform",
                    description: Text("Start recording affirmations to see them here")
                )
            } else {
                ForEach(recordings) { recording in
                    RecordingRow(recording: recording)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteRecording(recording)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle(PlaylistManager.defaultPlaylistName)
        .frame(minWidth: 400, minHeight: 300)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func deleteRecording(_ recording: Recording) {
        withAnimation {
            if let path = recording.filePath {
                let url = URL(fileURLWithPath: path)
                try? FileManager.default.removeItem(at: url)
            }
            viewContext.delete(recording)
            try? viewContext.save()
        }
    }
}

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

struct NewPlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
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
            // Reset the context if there's an error
            viewContext.rollback()
        }
    }
}

struct PlaylistDetailView: View {
    @ObservedObject var playlist: Playlist
    @StateObject private var audioManager = AudioManager()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            if let recordings = playlist.recordings {
                ForEach(Array(recordings)) { recording in
                    RecordingRow(recording: recording)
                }
                .onDelete(perform: deleteRecordings)
            }
        }
        .navigationTitle(playlist.name ?? "Playlist")
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            if let recordings = playlist.recordings {
                let recordingsArray = Array(recordings)
                offsets.map { recordingsArray[$0] }.forEach { recording in
                    viewContext.delete(recording)
                }
                try? viewContext.save()
            }
        }
    }
}

struct AddRecordingView: View {
    @ObservedObject var playlist: Playlist
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: false)],
        animation: .default
    ) private var recordings: FetchedResults<Recording>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recordings) { recording in
                    if let playlistRecordings = playlist.recordings, !playlistRecordings.contains(recording) {
                        Button(action: { addRecording(recording) }) {
                            RecordingRow(recording: recording)
                        }
                    }
                }
            }
            .navigationTitle("Add Recording")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addRecording(_ recording: Recording) {
        withAnimation {
            if playlist.recordings == nil {
                playlist.recordings = Set<Recording>()
            }
            playlist.recordings?.insert(recording)
            try? viewContext.save()
            dismiss()
        }
    }
}

struct RecordingRow: View {
    let recording: Recording
    @StateObject private var audioManager = AudioManager()
    
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
    }
} 