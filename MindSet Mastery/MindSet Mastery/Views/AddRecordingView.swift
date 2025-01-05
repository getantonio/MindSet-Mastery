import SwiftUI
import CoreData

struct AddRecordingView: View {
    @ObservedObject var playlist: Playlist
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recording.createdAt, ascending: false)],
        animation: .default
    ) private var recordings: FetchedResults<Recording>
    
    var body: some View {
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