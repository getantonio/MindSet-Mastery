import SwiftUI

struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    
    var body: some View {
        Button(action: {
            isRecording.toggle()
        }) {
            Text(isRecording ? "STOP" : "REC")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isRecording ? Color.red : Color.blue)
                .cornerRadius(8)
        }
    }
}

#Preview {
    RecordingControlsView(isRecording: .constant(false))
} 