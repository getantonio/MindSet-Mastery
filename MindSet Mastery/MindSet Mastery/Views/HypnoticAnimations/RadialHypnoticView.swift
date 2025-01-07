import SwiftUI

struct RadialHypnoticView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    let clockwise: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var rotation = 0.0
    @State private var scale = 1.0
    
    let segments = 36
    let rings = 12
    
    // Add new properties for random motion
    @State private var offsetX = 0.0
    @State private var offsetY = 0.0
    
    // Add properties for dynamic speed and movement
    @State private var rotationSpeed = Double.random(in: 4.8...6.4)  // Base rotation speed
    
    // More random parameters
    private let phaseX = Double.random(in: 0...2 * .pi)
    private let phaseY = Double.random(in: 0...2 * .pi)
    private let amplitude = Double.random(in: 50...70)
    private let baseFrequencyX = Double.random(in: 0.2...0.4)
    private let baseFrequencyY = Double.random(in: 0.2...0.4)
    private let speedVariation = Double.random(in: 0.8...1.2)  // Random speed multiplier
    
    // Faster phase changes for more active movement
    private let phaseChangeSpeed = Double.random(in: 0.08...0.12)  // Increased from 0.05
    
    // More frequent position updates
    private let positionUpdateInterval = 0.05  // Reduced from 0.1
    
    // Much more dampened movement during recording
    private var currentAmplitude: Double {
        isRecording ? amplitude * 0.1 : amplitude  // Reduce to 10% when recording
    }
    
    // Much more dampened audio effect
    private var dampedAudioLevel: CGFloat {
        isRecording ? audioLevel * 0.1 : audioLevel  // Reduce to 10% when recording
    }
    
    // Slower frequencies during recording
    private var currentFrequencyX: Double {
        isRecording ? baseFrequencyX * 0.5 : baseFrequencyX
    }
    
    private var currentFrequencyY: Double {
        isRecording ? baseFrequencyY * 0.5 : baseFrequencyY
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            // Use slower frequencies during recording
            let xOffset = currentAmplitude * sin(time * currentFrequencyX + phaseX)
            let yOffset = currentAmplitude * cos(time * currentFrequencyY + phaseY)
            
            ZStack {
                // Background
                Circle()
                    .fill(.black)
                    .frame(width: 96, height: 96)
                
                // Spiral segments with twist
                ForEach(0..<rings, id: \.self) { ring in
                    ForEach(0..<segments, id: \.self) { segment in
                        let angle = Double(segment) * (360.0 / Double(segments))
                        let ringRadius = Double(ring + 1) * (48.0 / Double(rings))
                        let twist = Double(ring) * 5.0  // Add twist effect
                        
                        Path { path in
                            path.move(to: CGPoint(x: 48, y: 48))
                            path.addArc(
                                center: CGPoint(x: 48, y: 48),
                                radius: ringRadius,
                                startAngle: Angle.degrees(angle + twist),  // Add twist to angle
                                endAngle: Angle.degrees(angle + twist + (360.0 / Double(segments)) - 2),
                                clockwise: false
                            )
                            path.closeSubpath()
                        }
                        .fill(segment % 2 == 0 ? themeManager.activeColor : .black)
                        .opacity(isActive ? 1.0 : 0.3)
                    }
                }
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale + (dampedAudioLevel * 2.0))
                
                // Enhanced glow overlay
                Circle()
                    .strokeBorder(
                        themeManager.activeColor.opacity(0.6),
                        lineWidth: 1.5
                    )
                    .frame(width: 96, height: 96)
                    .blur(radius: 1)
                
                // Center glow with dampened audio
                Circle()
                    .fill(themeManager.activeColor)
                    .frame(width: 12, height: 12)
                    .blur(radius: 4)
                    .opacity(isActive ? 0.8 : 0.3)
                    .scaleEffect(1.0 + sin(rotation * .pi / 180) * 0.3 + (dampedAudioLevel * 2.0))
            }
            .frame(width: 96, height: 96)
            .offset(x: xOffset, y: yOffset)
        }
        .onAppear {
            // Keep only rotation and scale animations
            withAnimation(.linear(duration: rotationSpeed * speedVariation).repeatForever(autoreverses: false)) {
                rotation = clockwise ? 360 : -360
            }
            
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
            
            // Speed variation timer
            Timer.scheduledTimer(withTimeInterval: Double.random(in: 3...6), repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    rotationSpeed = Double.random(in: 4.8...6.4)
                }
            }
        }
    }
}

// New container view for dual pinwheels
struct DualPinwheelView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    var body: some View {
        HStack(spacing: 53) {
            // Left pinwheel - clockwise
            RadialHypnoticView(
                isActive: isActive,
                isRecording: isRecording,
                audioLevel: audioLevel,
                clockwise: true
            )
            .frame(width: 96, height: 96)
            
            // Right pinwheel - counter-clockwise
            RadialHypnoticView(
                isActive: isActive,
                isRecording: isRecording,
                audioLevel: audioLevel,
                clockwise: false
            )
            .frame(width: 96, height: 96)
        }
    }
} 