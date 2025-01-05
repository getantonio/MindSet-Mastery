import SwiftUI
import CoreData

struct PlaylistDetailView: View {
    @ObservedObject var playlist: Playlist
    @StateObject private var audioManager = AudioManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showAddRecording = false
    @State private var isExpanded = true
    
    var body: some View {
        List {
            if let recordings = playlist.recordings {
                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: {
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
                    },
                    label: {
                        HStack {
                            Text(playlist.name ?? "Playlist")
                            Spacer()
                            Text("\(recordings.count) recordings")
                                .foregroundColor(.secondary)
                        }
                    }
                )
            }
        }
        .navigationTitle("Playlist")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddRecording = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRecording) {
            NavigationView {
                AddRecordingView(playlist: playlist)
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
} 