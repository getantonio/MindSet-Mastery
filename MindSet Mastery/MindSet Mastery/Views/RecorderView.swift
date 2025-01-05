import SwiftUI
import AVFoundation

struct MovementLimits {
    let horizontalRange: CGFloat
    let verticalRange: CGFloat
    let minDistance: CGFloat
}

enum CompanionPosition {
    case left
    case right
}

struct RecorderView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var isRecording: Bool
    @Binding var selectedCategory: BehaviorCategory?
    @State private var showMicrophoneAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Title section - 60px
            Text(selectedCategory?.name ?? "Select Category")
                .font(.headline)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
            
            // Wheels section - 190px
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                
                // Center both wheels with 30px spacing
                HStack(spacing: 30) {
                    // Left wheel
                    HypnoticWheelView(
                        isActive: selectedCategory != nil,
                        isRecording: isRecording,
                        audioLevel: audioManager.audioLevel,
                        rotateClockwise: false
                    )
                    .frame(width: 100, height: 100)
                    
                    // Right wheel
                    HypnoticWheelView(
                        isActive: selectedCategory != nil,
                        isRecording: isRecording,
                        audioLevel: audioManager.audioLevel,
                        rotateClockwise: true
                    )
                    .frame(width: 100, height: 100)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 190)
            
            // Controls section - 50px
            VStack(spacing: 10) {
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
            }
            .frame(height: 50)
            .padding(.bottom, 10)  // 10px from bottom
        }
        .frame(height: 300)  // Total height
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
