import SwiftUI

struct HypnoticWheelView: View {
    let isActive: Bool
    let audioLevel: CGFloat
    @State private var rotation = 0.0
    let rotateClockwise: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Reduced glow on background circle
                Circle()
                    .stroke(Color.green, lineWidth: 4)
                    .blur(radius: 0.5)
                    .shadow(color: .green.opacity(0.3), radius: 2)
                
                // Hypnotic spiral with fewer spokes and simpler curves
                ForEach(0..<4) { index in
                    HypnoticSpiral(
                        spokes: 4,
                        index: index,
                        audioLevel: audioLevel
                    )
                    .stroke(Color.green, lineWidth: 2)
                    .shadow(color: .green.opacity(0.3), radius: 1)
                    .rotationEffect(.degrees(rotateClockwise ? rotation : -rotation))
                    .animation(
                        isActive ?
                            Animation.linear(duration: 2.2)
                            .repeatForever(autoreverses: false) : .default,
                        value: rotation
                    )
                }
                
                // Pulsing center with enhanced glow
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .blur(radius: 2)
                    .shadow(color: .green.opacity(0.8), radius: 4)
                    .scaleEffect(isActive ? 1.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isActive
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                if isActive {
                    withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    rotation = 0
                }
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

#Preview {
    ZStack {
        Color.black
        HypnoticWheelView(isActive: true, audioLevel: 0.5, rotateClockwise: true)
            .frame(width: 200, height: 200)
    }
} 