import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct RecordingControlsView: View {
    @Binding var isPlaying: Bool
    let onPlayPause: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.green)
            }
            .buttonStyle(.plain)
            
            Button(action: onStop) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    RecordingControlsView(
        isPlaying: .constant(false),
        onPlayPause: {},
        onStop: {}
    )
} 