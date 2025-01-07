import SwiftUI

struct HypnoExamples: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var isAnimating = false
    @State private var rotation = 0.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    // Spiral Animation
                    ZStack {
                        ForEach(0..<8) { index in
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundStyle(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]),
                                        center: .center
                                    )
                                )
                                .frame(width: 200 - CGFloat(index * 20), height: 200 - CGFloat(index * 20))
                                .rotationEffect(.degrees(rotation + Double(index * 45)))
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    
                    // Ripple Effect
                    ZStack {
                        ForEach(0..<5) { index in
                            Circle()
                                .stroke(themeManager.accentColor.opacity(1 - Double(index) * 0.2), lineWidth: 2)
                                .frame(width: 50 + CGFloat(index * 50), height: 50 + CGFloat(index * 50))
                                .opacity(isAnimating ? 0 : 1)
                                .scaleEffect(isAnimating ? 2 : 1)
                                .animation(
                                    Animation.easeOut(duration: 2)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                }
                .padding()
            }
            .navigationTitle("Animation Examples")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Start the ripple animation
            isAnimating = true
            
            // Start the spiral animation
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    HypnoExamples()
}
