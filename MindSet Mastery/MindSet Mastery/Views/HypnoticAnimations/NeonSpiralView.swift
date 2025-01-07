import SwiftUI

struct NeonSpiralView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var pulsePhase = 0.0
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [themeManager.activeColor.opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 16
                    )
                )
                .blur(radius: 4)
                .scaleEffect(1.2 + (audioLevel * 0.5))
            
            // Main spiral image
            Image("spiralPinwheel")
                .renderingMode(.template)
                .foregroundColor(themeManager.activeColor)
                .rotationEffect(.degrees(rotation))
                .scaleEffect((scale + (audioLevel * 4.0)) * 0.16)
                .shadow(color: themeManager.activeColor, radius: 1)
                .opacity(isActive ? 0.8 : 0.3)
            
            // Counter-rotating copy
            Image("spiralPinwheel")
                .renderingMode(.template)
                .foregroundColor(themeManager.activeColor)
                .scaleEffect(0.08)
                .rotationEffect(.degrees(-rotation * 1.5))
                .scaleEffect(scale + sin(pulsePhase) * 0.2 + (audioLevel * 3.0))
                .shadow(color: themeManager.activeColor, radius: 0.6)
                .opacity(isActive ? 0.6 : 0.2)
            
            // Center glow
            Circle()
                .fill(themeManager.activeColor)
                .frame(width: 2.4, height: 2.4)
                .blur(radius: 0.8)
                .opacity(isActive ? 0.8 : 0.3)
                .scaleEffect(1.0 + sin(pulsePhase) * 0.3 + (audioLevel * 2.0))
        }
        .frame(width: 32, height: 32)
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                pulsePhase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
} 