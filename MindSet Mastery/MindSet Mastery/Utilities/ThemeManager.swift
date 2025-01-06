import SwiftUI

class ThemeManager: ObservableObject {
    @Published var activeColor: Color = .green
    
    static let shared = ThemeManager()
    
    var accentColor: Color { activeColor }
    var textColor: Color { activeColor }
    var buttonColor: Color { activeColor }
    var shadowColor: Color { activeColor.opacity(0.3) }
    var glowColor: Color { activeColor.opacity(0.6) }
} 