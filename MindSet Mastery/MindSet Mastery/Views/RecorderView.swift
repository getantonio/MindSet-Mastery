import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct RecorderView: View {
    @Binding var isRecording: Bool
    @Binding var selectedCategory: BehaviorCategory?
    let onRecordingStateChanged: (Bool) -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                isRecording.toggle()
                onRecordingStateChanged(isRecording)
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(isRecording ? .red : .green)
            }
            .buttonStyle(.plain)
            .disabled(selectedCategory == nil)
            
            Text(isRecording ? "Tap to Stop" : "Tap to Record")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    RecorderView(
        isRecording: .constant(false),
        selectedCategory: .constant(nil),
        onRecordingStateChanged: { _ in }
    )
} 
