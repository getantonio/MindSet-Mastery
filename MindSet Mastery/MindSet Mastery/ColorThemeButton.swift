import SwiftUI

struct ColorThemeButton: View {
    let color: Color
    let action: () -> Void
    let isActive: Bool
    
    // Get fully saturated colors
    private var buttonColor: Color {
        switch color {
        case .red:
            return Color(red: 1, green: 0, blue: 0)      // Pure RGB Red (255,0,0)
        case .green:
            return Color(red: 0, green: 1, blue: 0)      // Pure RGB Green
        case .blue:
            return Color(red: 0, green: 0, blue: 1)      // Pure RGB Blue
        case .gray:
            return Color(white: 0.15)  // Match the UI gray
        default:
            return color
        }
    }
    
    // Separate opacity control
    private var buttonOpacity: Double {
        if color == .white {
            return isActive ? 0.8 : 0.4  // Mustard button stays visible but dims when inactive
        }
        return isActive ? 1.0 : 0.1      // RGB buttons follow original opacity rules
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Base circle with bevel effect
                Circle()
                    .fill(buttonColor.opacity(buttonOpacity))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .black.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .blur(radius: 0.5)
                    )
                
                // Glossy overlay
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(isActive ? 0.6 : 0.3),
                                .clear,
                                buttonColor.opacity(isActive ? 0.3 : 0.1)
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
                color: isActive ? buttonColor.opacity(0.6) : .clear,
                radius: 4,
                x: 0,
                y: 1
            )
        }
    }
} 
