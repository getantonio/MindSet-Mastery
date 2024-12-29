import SwiftUI

struct NebulaBackground: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                // Base colors
                let baseColor = Color(red: 0.1, green: 0.3, blue: 0.6)
                let highlightColor = Color(red: 0.4, green: 0.2, blue: 0.6)
                
                // Create time-based animation
                let time = Date().timeIntervalSinceReferenceDate
                
                // Add overall blur for softness
                context.addFilter(.blur(radius: 30))
                
                // Create nebula effect with multiple layers
                for i in 0..<8 {
                    let speed = Double(i) * 0.1
                    let scale = Double(i) * 0.2
                    
                    let x = size.width * 0.5 + sin(time * speed + Double(i)) * 20
                    let y = size.height * 0.5 + cos(time * speed + Double(i)) * 20
                    
                    // Add subtle movement
                    context.addFilter(.blur(radius: 10))
                    
                    // Draw base nebula shape
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x,
                            y: y,
                            width: 50 + scale * 10,
                            height: 50 + scale * 10
                        )),
                        with: .color(baseColor.opacity(0.1))
                    )
                    
                    // Add highlight areas
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x + 10,
                            y: y - 10,
                            width: 30 + scale * 5,
                            height: 30 + scale * 5
                        )),
                        with: .color(highlightColor.opacity(0.05))
                    )
                }
            }
        }
        .opacity(0.3)
        .allowsHitTesting(false)
    }
}

#Preview {
    NebulaBackground()
        .frame(width: 300, height: 200)
        .background(.black)
} 