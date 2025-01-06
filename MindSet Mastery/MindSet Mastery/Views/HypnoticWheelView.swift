import SwiftUI

struct HypnoticWheelView: View {
    @StateObject private var themeManager = ThemeManager.shared
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    let rotateClockwise: Bool
    
    @State private var rotation = 0.0
    @State private var isSpinning = false
    
    var rotationDuration: Double {
        if isRecording { return 0.8 }     // Even faster during recording
        if isActive { return 3.0 }        // Moderate speed when idle
        return 0
    }
    
    var amplifiedAudioLevel: CGFloat {
        max(audioLevel * 8.0, 0.3)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let wheelSize = min(size.width, size.height) * 0.7
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(themeManager.accentColor, lineWidth: 4)
                    .blur(radius: 0.5)
                    .shadow(color: themeManager.shadowColor, radius: 2)
                    .frame(width: wheelSize, height: wheelSize)
                    .scaleEffect(1.0 + (isActive ? amplifiedAudioLevel * 0.5 : 0))
                    .animation(.easeInOut(duration: 0.1), value: audioLevel)
                
                // Hypnotic spiral
                ForEach(0..<4) { index in
                    HypnoticSpiral(
                        spokes: 4,
                        index: index,
                        audioLevel: amplifiedAudioLevel,
                        color: themeManager.accentColor
                    )
                    .stroke(themeManager.accentColor, lineWidth: 2)
                    .shadow(color: themeManager.shadowColor, radius: 1)
                    .frame(width: wheelSize, height: wheelSize)
                    .rotationEffect(.degrees(isSpinning ? (rotateClockwise ? 360 : -360) : 0))
                    .animation(
                        .linear(duration: rotationDuration)
                        .repeatForever(autoreverses: false),
                        value: isSpinning
                    )
                }
                
                // Center pulse
                Circle()
                    .fill(themeManager.accentColor)
                    .frame(width: 8, height: 8)
                    .blur(radius: 2)
                    .shadow(color: themeManager.shadowColor, radius: 4)
                    .scaleEffect(isActive ? 1.0 + amplifiedAudioLevel : 1.0)
            }
            .onAppear {
                if isActive {
                    isSpinning = true
                }
            }
            .onChange(of: isRecording) { _ in
                // Restart spinning animation
                isSpinning = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSpinning = true
                }
            }
        }
    }
}

struct HypnoticSpiral: Shape {
    let spokes: Int
    let index: Int
    let audioLevel: CGFloat
    let color: Color
    
    private func calculateSpiralPoint(t: Double, center: CGPoint, radius: CGFloat, baseAngle: Double) -> CGPoint {
        let angle = baseAngle + t * 2 * Double.pi
        let radiusMultiplier = 0.1 + (0.9 * t)  // Start at 10%, go to 100%
        let audioMultiplier = 1.0 + Double(audioLevel) * 0.3
        let spiralRadius = radius * radiusMultiplier * audioMultiplier
        
        return CGPoint(
            x: center.x + cos(angle) * spiralRadius,
            y: center.y + sin(angle) * spiralRadius
        )
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleIncrement = (2.0 * Double.pi) / Double(spokes)
        let baseAngle = angleIncrement * Double(index)
        
        // Create points array
        var points: [CGPoint] = []
        let steps = stride(from: 0.0, through: 1.0, by: 0.01)
        
        // Calculate points
        for t in steps {
            let point = calculateSpiralPoint(
                t: t,
                center: center,
                radius: radius,
                baseAngle: baseAngle
            )
            points.append(point)
        }
        
        // Draw the path
        path.move(to: center)
        for point in points {
            path.addLine(to: point)
        }
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black
        HypnoticWheelView(isActive: true, isRecording: false, audioLevel: 0.5, rotateClockwise: true)
            .frame(width: 200, height: 200)
    }
} 