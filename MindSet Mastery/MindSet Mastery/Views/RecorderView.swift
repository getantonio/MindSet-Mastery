import SwiftUI
import AppKit

struct WaveformCircle: View {
    let isRecording: Bool
    let audioLevel: CGFloat
    let animationDelay: Double
    let rotationDirection: Double
    
    init(isRecording: Bool, audioLevel: CGFloat, animationDelay: Double, rotationDirection: Double) {
        self.isRecording = isRecording
        self.audioLevel = audioLevel
        self.animationDelay = animationDelay
        self.rotationDirection = rotationDirection
    }
    
    var body: some View {
        ZStack {
            // Reduced number of S-curves with longer paths
            ForEach(0..<6, id: \.self) { i in
                RotatingCurve(
                    isRecording: isRecording,
                    index: i,
                    direction: rotationDirection,
                    isLeftWheel: rotationDirection == -1
                )
            }
            
            // Tighter outer circle
            Circle()
                .stroke(Color.green, lineWidth: 2)
                .frame(width: 70, height: 70)
                .shadow(color: Color.green.opacity(0.5), radius: 2)
            
            // Center dot remains the same
            Circle()
                .fill(Color.black)
                .frame(width: 4, height: 4)
                .shadow(color: Color.green, radius: 1)
                .modifier(PulsingModifier(isActive: isRecording))
        }
        .scaleEffect(x: rotationDirection == 1 ? 1 : -1, y: 1)
    }
}

// New component for rotating curves
struct RotatingCurve: View {
    let isRecording: Bool
    let index: Int
    let direction: Double
    let isLeftWheel: Bool
    @State private var rotation: Double
    
    init(isRecording: Bool, index: Int, direction: Double, isLeftWheel: Bool) {
        self.isRecording = isRecording
        self.index = index
        self.direction = direction
        self.isLeftWheel = isLeftWheel
        _rotation = State(initialValue: Double(index) * 40)
    }
    
    var body: some View {
        SCurveShape(isReversed: isLeftWheel)
            .stroke(
                Color.green.opacity(0.8),
                lineWidth: 1
            )
            .frame(width: 70, height: 70)
            .rotationEffect(.degrees(rotation))
            .onChange(of: isRecording) { _, newValue in
                if newValue {
                    // Start animation
                    withAnimation(
                        .linear(duration: 3.0 - (Double(index) * 0.3))
                        .repeatForever(autoreverses: false)
                    ) {
                        rotation += 360 * direction * (isLeftWheel ? -1 : 1)
                    }
                } else {
                    // Stop animation completely
                    withAnimation(.easeOut(duration: 0.3)) {
                        rotation = Double(index) * 40  // Reset to initial position
                    }
                }
            }
    }
}

// Pulsing animation modifier for the center dot
struct PulsingModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0
    
    init(isActive: Bool) {
        self.isActive = isActive
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        scale = 2.0
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// Replace the MinimalSliderStyle with this custom slider view
struct MinimalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                // Active track
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)), height: 1)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .offset(x: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) - 3)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(gesture.location.x / geometry.size.width)
                        withAnimation(.linear(duration: 0.1)) {
                            value = max(range.lowerBound, min(range.upperBound, newValue))
                        }
                    }
            )
        }
        .frame(height: 20)
    }
}

// S-curve shape definition
struct SCurveShape: Shape {
    let isReversed: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Start from top of circle
        path.move(to: CGPoint(x: width/2, y: 0))
        
        if isReversed {
            // Reversed S-curve for left wheel
            path.addCurve(
                to: CGPoint(x: width/2, y: height/2),
                control1: CGPoint(x: width * 0.15, y: 0),
                control2: CGPoint(x: width * 0.15, y: height/2)
            )
            path.addCurve(
                to: CGPoint(x: width/2, y: height),
                control1: CGPoint(x: width * 0.85, y: height/2),
                control2: CGPoint(x: width * 0.85, y: height)
            )
        } else {
            // Normal S-curve for right wheel
            path.addCurve(
                to: CGPoint(x: width/2, y: height/2),
                control1: CGPoint(x: width * 0.85, y: 0),
                control2: CGPoint(x: width * 0.85, y: height/2)
            )
            path.addCurve(
                to: CGPoint(x: width/2, y: height),
                control1: CGPoint(x: width * 0.15, y: height/2),
                control2: CGPoint(x: width * 0.15, y: height)
            )
        }
        
        return path
    }
}

struct RecorderView: View {
    @Binding var isRecording: Bool
    @Binding var selectedCategory: BehaviorCategory?
    let onRecordingStateChanged: (Bool) -> Void
    @State private var isPulsing = false
    @State private var audioLevel: CGFloat = 0.0
    
    // Add timer for audio level updates
    let audioLevelTimer = Timer.publish(
        every: 0.1,  // Update every 0.1 seconds
        on: .main,
        in: .common
    ).autoconnect()
    
    private func getNegationAffirmation(for category: BehaviorCategory) -> String {
        switch category.name.lowercased() {
        case "sleep":
            return "I embrace peaceful rest"
        case "focus":
            return "I maintain laser focus"
        case "relationship":
            return "I nurture deep connections"
        case "anxiety":
            return "I choose serene calm"
        case "gratitude":
            return "I embrace life's gifts"
        case "forgiveness":
            return "I release all resentment"
        case "motivation":
            return "I ignite my inner drive"
        case "addiction":
            return "I choose freedom and health"
        case "depression":
            return "I welcome joy and light"
        case "stress":
            return "I embrace inner peace"
        case "fear":
            return "I face challenges boldly"
        case "anger":
            return "I choose calm responses"
        case "procrastination":
            return "I take immediate action"
        case "self-doubt":
            return "I trust my abilities fully"
        default:
            return "I am empowered"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Display
            ZStack {
                Rectangle()
                    .fill(Color(.black))
                    .frame(height: 60)
                
                if let category = selectedCategory {
                    GeometryReader { geometry in
                        Text(getNegationAffirmation(for: category))
                            .font(.system(.title3, design: .monospaced))
                            .foregroundColor(.green)
                            .shadow(color: Color.green.opacity(0.5), radius: 2)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scaleEffect(isPulsing ? 1.45 : 0.6)
                            .opacity(isPulsing ? 1.0 : 0.7)
                            .animation(
                                Animation.easeInOut(duration: 6.0)
                                    .repeatForever(autoreverses: true),
                                value: isPulsing
                            )
                    }
                    .frame(height: 60)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isPulsing = true
                        }
                    }
                    .onChange(of: category.name) { _, _ in
                        isPulsing = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isPulsing = true
                        }
                    }
                } else {
                    Text("SELECT CATEGORY")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundColor(.green)
                        .shadow(color: Color.green.opacity(0.5), radius: 2)
                }
            }
            .frame(height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Waveform Display
            HStack(spacing: 40) {
                WaveformCircle(isRecording: isRecording, audioLevel: audioLevel, animationDelay: 0, rotationDirection: 1)
                WaveformCircle(isRecording: isRecording, audioLevel: audioLevel, animationDelay: 0.05, rotationDirection: -1)
            }
            .padding(.vertical, 20)
            .background(Color.black)
            
            // Controls
            RecordingControlsView(isRecording: $isRecording)
                .onChange(of: isRecording) { _, newValue in
                    onRecordingStateChanged(newValue)
                }
                .padding(.vertical, 10)
            
            // Remove the MinimalSlider since we're not using hue anymore
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        )
        .padding()
        .frame(maxWidth: 500)
        .frame(height: 200)
    }
}

#Preview {
    RecorderView(
        isRecording: .constant(false),
        selectedCategory: .constant(nil),
        onRecordingStateChanged: { _ in }
    )
    .frame(width: 500, height: 200)
    .background(Color.black)
} 
