import SwiftUI

struct AudioWaveformView: View {
    let audioLevel: CGFloat
    @State private var waveOffset = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                
                // Waveform
                WaveformShape(amplitude: audioLevel * 20, frequency: 8, phase: waveOffset)
                    .stroke(Color.green, lineWidth: 2)
                    .clipShape(Circle())
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            waveOffset = .pi * 2
                        }
                    }
            }
        }
    }
}

struct WaveformShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = Path { p in
            let midHeight = rect.height / 2
            let width = rect.width
            
            p.move(to: CGPoint(x: 0, y: midHeight))
            
            for x in stride(from: 0, through: width, by: 1) {
                let relativeX = x / width
                let normalizedSin = sin(relativeX * frequency * .pi * 2 + phase)
                let y = midHeight + normalizedSin * amplitude
                p.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
} 