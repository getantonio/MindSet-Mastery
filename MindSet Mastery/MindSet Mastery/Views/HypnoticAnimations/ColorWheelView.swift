import SwiftUI

struct ColorWheelView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var rotation = 0.0
    @State private var innerRotation = 0.0
    @State private var scale = 1.0
    @State private var pulsePhase = 0.0
    
    // More saturated colors
    let colors: [Color] = [
        .red,
        Color(red: 1, green: 0.5, blue: 0),  // Bright orange
        Color(red: 1, green: 1, blue: 0),     // Bright yellow
        Color(red: 0, green: 1, blue: 0),     // Bright green
        Color(red: 0, green: 0.5, blue: 1),   // Bright blue
        Color(red: 0.7, green: 0, blue: 1)    // Bright purple
    ]
    let segments = 24
    
    var body: some View {
        ZStack {
            // Outer color wheel - spins clockwise
            ForEach(0..<2) { ring in
                ZStack {
                    ForEach(0..<segments, id: \.self) { index in
                        Path { path in
                            let center = CGPoint(x: 100, y: 100)
                            let radius = 100.0 - Double(ring * 30)
                            let angle = Double.pi * 2 / Double(segments)
                            let startAngle = angle * Double(index)
                            let endAngle = startAngle + angle
                            
                            path.move(to: center)
                            path.addArc(center: center,
                                      radius: radius,
                                      startAngle: .radians(startAngle),
                                      endAngle: .radians(endAngle),
                                      clockwise: false)
                            path.closeSubpath()
                        }
                        .fill(
                            colors[index % colors.count]
                                .opacity(isActive ? 0.9 : 0.3)
                                .saturated(by: 1.3)
                        )
                        .blur(radius: CGFloat(ring) * 2)
                    }
                }
                .rotationEffect(.degrees(rotation + Double(ring * 30)))
                .rotationEffect(.degrees(sin(pulsePhase) * 10))
                .scaleEffect(scale + (audioLevel * 4.0) + sin(pulsePhase + Double(ring)) * 0.1)
            }
            
            // Inner color wheel - spins counter-clockwise
            ZStack {
                ForEach(0..<segments, id: \.self) { index in
                    Path { path in
                        let center = CGPoint(x: 100, y: 100)
                        let radius = 40.0
                        let angle = Double.pi * 2 / Double(segments)
                        let startAngle = angle * Double(index)
                        let endAngle = startAngle + angle
                        
                        path.move(to: center)
                        path.addArc(center: center,
                                  radius: radius,
                                  startAngle: .radians(startAngle),
                                  endAngle: .radians(endAngle),
                                  clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(
                        colors[index % colors.count]
                            .opacity(isActive ? 0.9 : 0.3)
                            .saturated(by: 1.3)
                    )
                    .blur(radius: 1)
                }
            }
            .rotationEffect(.degrees(innerRotation))
            .scaleEffect(scale + (audioLevel * 4.0))
            
            // Pulsing rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(lineWidth: 4)
                    .fill(Color.white)
                    .frame(width: 160 - CGFloat(index * 50))
                    .opacity(isActive ? 0.4 : 0.1)
                    .scaleEffect(scale + (audioLevel * 5.0) + sin(pulsePhase + Double(index)) * 0.2)
                    .rotationEffect(.degrees(innerRotation * Double(index + 1)))
                    .blur(radius: 1.5)
            }
        }
        .frame(width: 200, height: 200)
        .blur(radius: audioLevel * 2)
        .onAppear {
            // Faster main rotation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Faster counter rotation
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                innerRotation = -360
            }
            
            // Faster pulsing
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                pulsePhase = .pi * 2
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.15
            }
        }
    }
}

extension Color {
    func saturated(by amount: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: Double(hue),
                    saturation: min(Double(saturation) * amount, 1.0),
                    brightness: Double(brightness),
                    opacity: Double(alpha))
    }
} 