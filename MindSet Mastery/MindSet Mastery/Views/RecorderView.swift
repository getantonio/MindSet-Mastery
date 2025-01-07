import SwiftUI
import AVFoundation

struct RecorderView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var isRecording: Bool
    @Binding var selectedCategory: BehaviorCategory?
    @State private var showMicrophoneAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Title
                Text(selectedCategory?.name ?? "Select Category")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                
                Spacer()
                
                // Wheels
                HStack(spacing: 53) {
                    // Left tunnel
                    HypnoticTunnelView(
                        isActive: selectedCategory != nil,
                        isRecording: isRecording,
                        audioLevel: audioManager.audioLevel
                    )
                    .frame(width: 96, height: 96)
                    
                    // Right tunnel
                    HypnoticTunnelView(
                        isActive: selectedCategory != nil,
                        isRecording: isRecording,
                        audioLevel: audioManager.audioLevel
                    )
                    .frame(width: 96, height: 96)
                }
                
                Spacer()
                
                // Record controls
                if isRecording {
                    Button(action: {
                        isRecording = false
                        audioManager.discardRecording()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(.title2))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                
                Button(action: {
                    isRecording.toggle()
                    handleRecordingStateChanged()
                }) {
                    Text("REC")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isRecording ? Color.red : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .shadow(color: isRecording ? .red.opacity(0.5) : .green.opacity(0.3), radius: 4)
                }
                .disabled(selectedCategory == nil)
                .padding(.bottom, 10)  // Exactly 10px from bottom
            }
            .frame(height: geometry.size.height)
            .background(Color.black.opacity(0.2))
        }
        .frame(height: 180)  // Even more compact
    }
    
    private func handleRecordingStateChanged() {
        if isRecording {
            guard let category = selectedCategory else {
                isRecording = false
                return
            }
            
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.audioManager.startRecording(for: category)
                    } else {
                        self.showMicrophoneAlert = true
                        self.isRecording = false
                    }
                }
            }
        } else if let url = audioManager.stopRecording() {
            // Handle saving recording
            saveRecording(url: url)
        }
    }
    
    private func saveRecording(url: URL) {
        guard let category = selectedCategory else { return }
        // Add your recording saving logic here
        print("Saving recording at \(url) for category \(category.name)")
    }
}

#Preview {
    RecorderView(
        audioManager: AudioManager(),
        isRecording: .constant(false),
        selectedCategory: .constant(nil)
    )
} 
