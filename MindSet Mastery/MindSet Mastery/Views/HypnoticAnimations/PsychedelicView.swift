import SwiftUI

struct PsychedelicView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var phase = 0.0
    @State private var rotation = 0.0
    @State private var pulseScale = 1.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                // Morphing background
                ForEach(0..<6) { index in
                    Circle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    .purple,
                                    .blue,
                                    .green,
                                    .yellow,
                                    .orange,
                                    .red,
                                    .purple
                                ]),
                                center: .center,
                                startAngle: .degrees(phase * Double(index)),
                                endAngle: .degrees(360 + phase * Double(index))
                            )
                        )
                        .frame(width: 200 - CGFloat(index * 25))
                        .blur(radius: CGFloat(index) * 1.5)  // Reduced blur for more definition
                        .opacity(0.4)  // Slightly increased opacity
                        .rotationEffect(.degrees(rotation + Double(index * 30)))
                        .scaleEffect(1.0 + (audioLevel * 5.0))
                    
                    // Pulsing rings with theme color
                    ForEach(0..<4) { index in
                        Circle()
                            .stroke(lineWidth: 4)  // Changed from 5 to 4
                            .fill(
                                RadialGradient(
                                    colors: [themeManager.activeColor, .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 150 - CGFloat(index * 30))
                            .scaleEffect(pulseScale + (audioLevel * 5.0))
                            .opacity(isActive ? 0.7 + (audioLevel * 0.4) : 0.2)
                            .shadow(color: themeManager.activeColor.opacity(0.5), radius: 4, x: 0, y: 0)
                            .blur(radius: 0.5)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                phase = 360
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
        }
    }
}
