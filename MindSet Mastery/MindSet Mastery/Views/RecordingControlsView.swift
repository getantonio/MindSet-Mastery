import SwiftUI

struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    let hue: Double
    
    var body: some View {
        Button(action: {
            isRecording.toggle()
        }) {
            Text(isRecording ? "STOP" : "REC")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isRecording {
                            Color.red
                                .opacity(0.8)
                                .shadow(color: .red, radius: 5)
                        } else {
                            Color(hue: hue, saturation: 1, brightness: 1)
                        }
                    }
                )
                .cornerRadius(8)
        }
        .shadow(
            color: isRecording ? 
                Color.red.opacity(0.5) : 
                Color(hue: hue, saturation: 1, brightness: 1).opacity(0.3),
            radius: isRecording ? 10 : 5
        )
    }
}

#Preview {
    RecordingControlsView(isRecording: .constant(false), hue: 0.5)
} 