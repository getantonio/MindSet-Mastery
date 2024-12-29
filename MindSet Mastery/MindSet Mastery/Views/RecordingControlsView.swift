import SwiftUI

struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    
    var body: some View {
        Button(action: {
            isRecording.toggle()
        }) {
            Group {
                if isRecording {
                    Image(systemName: "stop.fill")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Text("REC")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)
            .cornerRadius(8)
        }
    }
}

#Preview {
    RecordingControlsView(isRecording: .constant(false))
} 