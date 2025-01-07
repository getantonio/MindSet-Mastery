import SwiftUI

struct ExpandingCirclesView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var phase = 0.0
    let numCircles = 8  // Fewer circles for cleaner look
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            ZStack {
                // Background
                Color.black
                
                // Expanding circles
                ForEach(0..<numCircles, id: \.self) { index in
                    let progress = (phase + Double(index)) / Double(numCircles)
                    let modProgress = progress.truncatingRemainder(dividingBy: 1.0)
                    let size = modProgress * 96  // Expand to full width
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: size, height: size)
                        .opacity(isActive ? 1.0 : 0.3)
                }
            }
            .frame(width: 96, height: 96)
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    phase = Double(numCircles)
                }
            }
        }
    }
} 