import SwiftUI

struct ColorThemeButton: View {
    let color: Color
    let action: () -> Void
    let isActive: Bool
    
    // Get fully saturated colors
    private var buttonColor: Color {
        switch color {
        case .red:
            return Color(red: 1, green: 0, blue: 0)  // Pure RGB Red
        case .green:
            return Color(red: 0, green: 1, blue: 0)  // Pure RGB Green
        case .blue:
            return Color(red: 0, green: 0, blue: 1)  // Pure RGB Blue
        default:
            return color
        }
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Base circle with bevel effect
                Circle()
                    .fill(buttonColor.opacity(isActive ? 1.0 : 0.1))  // More contrast between states
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),  // Brighter highlight
                                        .black.opacity(0.4)   // Darker shadow
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .blur(radius: 0.5)  // Sharper bevel
                    )
                
                // Glossy overlay
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(isActive ? 0.8 : 0.4),  // Brighter highlight
                                .clear,
                                buttonColor.opacity(isActive ? 0.5 : 0.1)  // More color in active state
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                
                // Shine effect
                Circle()
                    .trim(from: 0, to: 0.4)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(isActive ? 1.0 : 0.5),  // Brighter shine
                                .white.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(-45))
                
                // Outer rim highlight
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(isActive ? 0.8 : 0.4),  // Brighter rim
                                buttonColor.opacity(isActive ? 0.6 : 0.2)  // More color contrast
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 24, height: 24)
            }
            .shadow(
                color: isActive ? buttonColor.opacity(0.6) : .clear,  // Stronger glow
                radius: 4,  // Slightly larger radius
                x: 0,
                y: 1
            )
        }
    }
} 