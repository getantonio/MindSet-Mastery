import SwiftUI
import CoreData

struct PlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: false)],
        predicate: NSPredicate(format: "playlist.name == %@", Playlist.defaultName)
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
                }
                .onDelete(perform: deleteRecordings)
            }
        }
        .navigationTitle(Playlist.defaultName)
        .frame(minWidth: 400, minHeight: 300)  // Add minimum size
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            offsets.map { recordings[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}

struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(playlist.name)
                .font(.headline)
            Text("\(playlist.recordings.count) recordings")
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
            ForEach(Array(playlist.recordings)) { recording in
                RecordingRow(recording: recording)
            }
            .onDelete(perform: deleteRecordings)
        }
        .navigationTitle(playlist.name)
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            let recordingsArray = Array(playlist.recordings)
            offsets.map { recordingsArray[$0] }.forEach { recording in
                viewContext.delete(recording)
            }
            try? viewContext.save()
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
    )
    private var recordings: FetchedResults<Recording>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recordings) { recording in
                    if !playlist.recordings.contains(recording) {
                        Button(action: { addRecording(recording) }) {
                            RecordingRow(recording: recording)
                        }
                    }
                }
            }
            .navigationTitle("Add Recording")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
            playlist.recordings.insert(recording)
            try? viewContext.save()
            dismiss()
        }
    }
}

struct RecordingRow: View {
    let recording: Recording
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recording.title)
                    .font(.headline)
                Text(recording.categoryName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatDuration(recording.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 