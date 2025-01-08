import SwiftUI

struct VoiceCloningView: View {
    @ObservedObject var affirmationGuide: AffirmationGuide
    @Environment(\.dismiss) var dismiss
    @State private var audioSamples: [URL] = []
    @State private var isRecording = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Record 3 samples of your voice")
                    .font(.headline)
                
                // Sample recording UI
                ForEach(0..<3) { index in
                    Button(action: {
                        // Start recording sample
                    }) {
                        Text("Record Sample \(index + 1)")
                    }
                }
                
                Button("Clone Voice") {
                    Task {
                        do {
                            let voiceId = try await affirmationGuide.cloneVoice(from: audioSamples)
                            print("Successfully cloned voice with ID: \(voiceId)")
                            dismiss()
                        } catch {
                            print("Failed to clone voice: \(error)")
                        }
                    }
                }
                .disabled(audioSamples.count < 3)
            }
            .navigationTitle("Voice Cloning")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
} 