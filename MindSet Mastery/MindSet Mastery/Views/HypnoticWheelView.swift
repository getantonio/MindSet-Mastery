import SwiftUI

struct HypnoticWheelView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    let rotateClockwise: Bool
    
    @State private var rotation = 0.0
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var velocity = CGPoint(x: 0, y: 0)
    @State private var timer: Timer?
    
    var rotationDuration: Double {
        if isRecording { return 1.8 }
        if isActive { return 12.0 }
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
                // Animated background circle with increased sensitivity
                Circle()
                    .stroke(Color.green, lineWidth: 4)
                    .blur(radius: 0.5)
                    .shadow(color: .green.opacity(0.3), radius: 2)
                    .frame(width: wheelSize, height: wheelSize)
                    .scaleEffect(1.0 + (isActive ? amplifiedAudioLevel * 0.5 : 0))
                    .animation(.easeInOut(duration: 0.1), value: audioLevel) // Faster response
                
                // Hypnotic spiral with increased audio response
                ForEach(0..<4) { index in
                    HypnoticSpiral(
                        spokes: 4,
                        index: index,
                        audioLevel: amplifiedAudioLevel
                    )
                    .stroke(Color.green, lineWidth: 2)
                    .shadow(color: .green.opacity(0.3), radius: 1)
                    .frame(width: wheelSize, height: wheelSize)
                    .rotationEffect(.degrees(rotateClockwise ? rotation : -rotation))
                    .animation(
                        rotationDuration > 0 ?
                            Animation.linear(duration: rotationDuration)
                            .repeatForever(autoreverses: false) : .default,
                        value: rotation
                    )
                    .clipShape(Circle().scale(1.0 + (isActive ? amplifiedAudioLevel * 0.5 : 0)))
                }
                
                // More responsive center pulse
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .blur(radius: 2)
                    .shadow(color: .green.opacity(0.8), radius: 4)
                    .scaleEffect(isActive ? 1.0 + amplifiedAudioLevel : 1.0)
            }
            .offset(x: position.x, y: position.y)
            .onAppear {
                startMovement()
                updateRotation()
            }
            .onChange(of: isRecording) { newValue in
                if newValue {
                    // Start movement when recording begins
                    startMovement()
                } else {
                    // Return to center when recording stops
                    withAnimation(.spring()) {
                        position = .zero
                        velocity = .zero
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func updateRotation() {
        if rotationDuration > 0 {
            withAnimation(.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        } else {
            rotation = 0
        }
    }
    
    private func startMovement() {
        timer?.invalidate()
        
        // Ensure we start with movement
        velocity = CGPoint(
            x: CGFloat.random(in: -3...3),
            y: CGFloat.random(in: -3...3)
        )
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard isRecording else { return }
            
            // Add random force
            velocity.x += CGFloat.random(in: -0.8...0.8)
            velocity.y += CGFloat.random(in: -0.8...0.8)
            
            // Update position
            position.x += velocity.x
            position.y += velocity.y
            
            // Bounce off boundaries
            let maxX: CGFloat = 50
            let maxY: CGFloat = 25
            
            if abs(position.x) > maxX {
                position.x = position.x > 0 ? maxX : -maxX
                velocity.x = -velocity.x * 0.8
            }
            
            if abs(position.y) > maxY {
                position.y = position.y > 0 ? maxY : -maxY
                velocity.y = -velocity.y * 0.8
            }
            
            // Apply drag
            velocity.x *= 0.98
            velocity.y *= 0.98
            
            // Ensure minimum movement
            let minSpeed: CGFloat = 0.5
            if sqrt(velocity.x * velocity.x + velocity.y * velocity.y) < minSpeed {
                velocity = CGPoint(
                    x: CGFloat.random(in: -2...2),
                    y: CGFloat.random(in: -2...2)
                )
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
        HypnoticWheelView(isActive: true, isRecording: false, audioLevel: 0.5, rotateClockwise: true)
            .frame(width: 200, height: 200)
    }
} 