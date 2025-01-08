import SwiftUI

struct SpiralMandalaView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var outerRotation = 0.0
    @State private var innerRotation = 0.0
    @State private var pulseScale = 1.0
    @State private var glowOpacity = 0.5
    
    var body: some View {
        ZStack {
            // Outer orange spiral
            ForEach(0..<3) { index in
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.orange, .red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 160 - CGFloat(index * 40))
                    .rotationEffect(.degrees(outerRotation))
                    .opacity(isActive ? 0.8 : 0.3)
            }
            
            // Inner blue rings
            ForEach(0..<2) { index in
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [.blue, .cyan.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 80 - CGFloat(index * 30))
                    .rotationEffect(.degrees(innerRotation))
                    .scaleEffect(pulseScale + (audioLevel * 0.5))
            }
            
            // Center glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .blue.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 1,
                        endRadius: 20
                    )
                )
                .frame(width: 30, height: 30)
                .opacity(glowOpacity)
                .blur(radius: 3)
        }
        .onChange(of: isRecording) { oldValue, newValue in
            if newValue {
                startAnimations()
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                startAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Continuous rotation animations
        withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
            outerRotation = 360
        }
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            innerRotation = -360
        }
        
        // Pulsing animations
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            glowOpacity = 0.8
        }
    }
} 