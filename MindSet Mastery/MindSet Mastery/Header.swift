import SwiftUI

struct Header: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack {
            Image("brainShiftLogo")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 96)
                .foregroundColor(themeManager.accentColor)
                .shadow(color: themeManager.accentColor.opacity(0.3), radius: 5)
                .glow(color: themeManager.accentColor, radius: 10)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.top, 8)
        .padding(.horizontal)
        .background(
            Color(white: 0.1)
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
        )
    }
}

// Custom glow modifier with reduced intensity
extension View {
    func glow(color: Color = .green, radius: CGFloat = 20) -> some View {
        self
            .overlay(
                self
                    .blur(radius: radius / 2)
                    .opacity(0.2)
                    .blendMode(.screen)
            )
            .overlay(
                self
                    .blur(radius: radius)
                    .opacity(0.05)
                    .blendMode(.screen)
            )
    }
}

#Preview {
    Header()
        .preferredColorScheme(.dark)
} 