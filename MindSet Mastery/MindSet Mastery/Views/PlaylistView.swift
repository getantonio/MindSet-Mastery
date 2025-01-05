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
            ForEach(recordings) { recording in
                VStack(alignment: .leading) {
                    Text(recording.title ?? "Untitled")
                        .font(.headline)
                    Text(recording.categoryName ?? "Unknown Category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    audioManager.startPlayback(recording: recording)
                }
            }
            .onDelete(perform: deleteRecordings)
        }
        .navigationTitle("My Recordings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        withAnimation {
            offsets.map { recordings[$0] }.forEach { recording in
                if let path = recording.filePath {
                    try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
                }
                viewContext.delete(recording)
            }
            try? viewContext.save()
        }
    }
} 