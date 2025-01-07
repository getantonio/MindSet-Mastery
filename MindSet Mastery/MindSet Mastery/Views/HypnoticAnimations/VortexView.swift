import SwiftUI

struct VortexView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    var body: some View {
        ZStack {
            // Outer vortex rings
            ForEach(0..<8) { index in
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.purple, .blue, .cyan, .purple]),
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 200 - CGFloat(index * 20))
                    .rotationEffect(.degrees(rotation + Double(index * 15)))
                    .opacity(isActive ? 0.7 : 0.3)
                    .scaleEffect(scale + (audioLevel * CGFloat(index) * 0.8))
                    .blur(radius: 1)
            }
            
            // Inner spiral
            ForEach(0..<6) { index in
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100 - CGFloat(index * 15))
                    .rotationEffect(.degrees(-rotation * 0.5 + Double(index * 30)))
                    .scaleEffect(scale + (audioLevel * 0.4))
            }
            
            // Center glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .blue.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: 30
                    )
                )
                .frame(width: 40, height: 40)
                .blur(radius: 5)
                .opacity(isRecording ? 0.8 : 0.4)
                .scaleEffect(isRecording ? 1.2 + (audioLevel * 0.4) : 1.0)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
} 