import SwiftUI

struct HypnoticTunnelView: View {
    let isActive: Bool
    let isRecording: Bool
    let audioLevel: CGFloat
    
    @State private var phase = 0.0
    @State private var rotation = 0.0
    let numRings = 12
    let numSpokes = 16
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { timeline in
            ZStack {
                // Background
                Color.black
                
                // Tunnel rings
                ForEach(0..<numRings, id: \.self) { ring in
                    let ringProgress = Double(ring) / Double(numRings)
                    let size = (1.0 - ringProgress) * 96  // Smaller as they go "deeper"
                    
                    // Spokes in each ring
                    ForEach(0..<numSpokes, id: \.self) { spoke in
                        let angle = Double(spoke) * (360.0 / Double(numSpokes))
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 1, height: size * 0.5)
                            .offset(y: -size * 0.25)
                            .rotationEffect(.degrees(angle))
                    }
                    .rotationEffect(.degrees(rotation * (ringProgress + 1)))
                    .frame(width: size, height: size)
                }
            }
            .frame(width: 96, height: 96)
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
} 