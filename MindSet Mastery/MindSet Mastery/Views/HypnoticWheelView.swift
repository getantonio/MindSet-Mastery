import SwiftUI

struct HypnoticWheelView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    let rotateClockwise: Bool
    
    var rotationDuration: Double {
        if isRecording { return 2.0 }     // Even slower for smoother motion
        if isActive { return 8.0 }        // Very slow base rotation
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
                    .stroke(Color.green, lineWidth: 4)
                    .blur(radius: 0.5)
                    .shadow(color: .green.opacity(0.3), radius: 2)
                    .frame(width: wheelSize, height: wheelSize)
                    .scaleEffect(1.0 + (isActive ? amplifiedAudioLevel * 0.5 : 0))
                    .animation(.easeInOut(duration: 0.1), value: audioLevel)
                
                // Hypnotic spiral
                ForEach(0..<4) { index in
                    HypnoticSpiral(
                        spokes: 4,
                        index: index,
                        audioLevel: amplifiedAudioLevel
                    )
                    .stroke(Color.green, lineWidth: 2)
                    .shadow(color: .green.opacity(0.3), radius: 1)
                    .frame(width: wheelSize, height: wheelSize)
                    .modifier(SpinningModifier(
                        isActive: isActive,
                        isRecording: isRecording,
                        clockwise: rotateClockwise
                    ))
                }
                .clipShape(Circle())
                
                // Center pulse
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .blur(radius: 2)
                    .shadow(color: .green.opacity(0.8), radius: 4)
                    .scaleEffect(isActive ? 1.0 + amplifiedAudioLevel : 1.0)
            }
        }
    }
}

struct HypnoticSpiral: Shape {
    let spokes: Int
    let index: Int
    let audioLevel: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angleIncrement = (2.0 * Double.pi) / Double(spokes)
        let baseAngle = angleIncrement * Double(index)
        
        // Create a spiral effect
        let points = stride(from: 0.0, through: 1.0, by: 0.01).map { t -> CGPoint in
            let angle = baseAngle + t * 2 * Double.pi
            let spiralRadius = radius * t * (1.0 + Double(audioLevel) * 0.5)
            return CGPoint(
                x: center.x + cos(angle) * spiralRadius,
                y: center.y + sin(angle) * spiralRadius
            )
        }
        
        path.move(to: center)
        points.forEach { point in
            path.addLine(to: point)
        }
        
        return path
    }
}

// Custom modifier for continuous spinning
struct SpinningModifier: ViewModifier {
    let isActive: Bool
    let isRecording: Bool
    let clockwise: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(clockwise ? 1 : -1))
            .modifier(TimelineModifier(
                duration: isRecording ? 2.0 : 8.0,
                isActive: isActive
            ))
    }
}

// Timeline modifier for smooth continuous animation
struct TimelineModifier: ViewModifier {
    let duration: Double
    let isActive: Bool
    
    @State private var angle = 0.0
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    angle = 360
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black
        HypnoticWheelView(isActive: true, isRecording: false, audioLevel: 0.5, rotateClockwise: true)
            .frame(width: 200, height: 200)
    }
} 