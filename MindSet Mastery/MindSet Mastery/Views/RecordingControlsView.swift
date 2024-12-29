import SwiftUI
import AVFoundation
import AppKit

struct RecordingControlsView: View {
    @Binding var isRecording: Bool
    @State private var showMicrophoneAlert = false
    
    var body: some View {
        Button(action: toggleRecording) {
            Group {
                if isRecording {
                    Image(systemName: "stop.fill")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .blur(radius: 8)
                                .opacity(0.6)
                        )
                } else {
                    Text("REC")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isRecording ? Color.red : Color(.windowBackgroundColor).opacity(1))
            .cornerRadius(8)
        }
        .alert("Microphone Access Required", isPresented: $showMicrophoneAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please allow microphone access in System Settings to record affirmations.")
        }
    }
    
    private func toggleRecording() {
        print("Toggle recording button pressed. Current state: \(isRecording)")
        if isRecording {
            print("Stopping recording...")
            isRecording = false
        } else {
            print("Attempting to start recording...")
            checkAndRequestPermission()
        }
    }
    
    private func checkAndRequestPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        print("Current microphone permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Microphone access already authorized, starting recording")
            isRecording = true
        case .notDetermined:
            print("Requesting microphone permission...")
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("Microphone permission granted, starting recording")
                        isRecording = true
                    } else {
                        print("Microphone permission denied")
                        showMicrophoneAlert = true
                    }
                }
            }
        case .denied, .restricted:
            print("Microphone access denied or restricted")
            showMicrophoneAlert = true
        @unknown default:
            print("Unknown microphone permission status")
            break
        }
    }
}

#Preview {
    RecordingControlsView(isRecording: .constant(false))
} 