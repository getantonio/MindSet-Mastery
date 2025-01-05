import SwiftUI

struct NeonSCurveView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer circle
                Circle()
                    .stroke(Color.green, lineWidth: 4)
                    .blur(radius: 2)
                
                // Animated S curves
                ForEach(0..<9) { index in
                    SCurve()
                        .stroke(Color.green, lineWidth: 2)
                        .blur(radius: 1)
                        .rotationEffect(.degrees(Double(index) * 40 + (isAnimating ? 360 : 0)))
                        .animation(
                            Animation.linear(duration: 2.0 + Double(index) * 0.8)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                
                // Center dot
                Circle()
                    .fill(Color.black)
                    .frame(width: 4, height: 4)
                    .blur(radius: 0.5)
                    .opacity(0.95)
                    .scaleEffect(isAnimating ? 2 : 1)
                    .animation(Animation.easeInOut(duration: 2).repeatForever(), value: isAnimating)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width/2, y: height * 0.15))
        path.addCurve(
            to: CGPoint(x: width/2, y: height * 0.5),
            control1: CGPoint(x: width * 0.7, y: height * 0.15),
            control2: CGPoint(x: width * 0.7, y: height * 0.5)
        )
        path.addCurve(
            to: CGPoint(x: width/2, y: height * 0.85),
            control1: CGPoint(x: width * 0.3, y: height * 0.5),
            control2: CGPoint(x: width * 0.3, y: height * 0.85)
        )
        
        return path
    }
} 