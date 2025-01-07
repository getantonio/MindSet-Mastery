import SwiftUI

struct HypnoticPatternView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    @State private var rotation = 0.0
    @State private var scale = 1.0
    @State private var opacity = 0.8
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Spiral pattern
                ForEach(0..<8) { index in
                    Circle()
                        .stroke(themeManager.accentColor.opacity(opacity), lineWidth: 2)
                        .frame(width: 50.0 + CGFloat(index) * 40)
                        .rotationEffect(.degrees(rotation + Double(index) * 45))
                }
                
                // Center mandala
                ForEach(0..<6) { index in
                    Rectangle()
                        .fill(themeManager.accentColor)
                        .frame(width: 100, height: 2)
                        .offset(x: 50)
                        .rotationEffect(.degrees(Double(index) * 60 + rotation))
                }
                .scaleEffect(scale)
            }
            .navigationTitle("Hypnotic Pattern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.2
                opacity = 0.6
            }
        }
    }
} 