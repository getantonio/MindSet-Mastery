import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var activeColor: Color = Color(red: 1, green: 0, blue: 0)
    @Published var isAutoCycling = false
    
    var textColor: Color { activeColor }
    var accentColor: Color { activeColor }
    var glowColor: Color { activeColor.opacity(0.5) }
    var shadowColor: Color { activeColor.opacity(0.3) }
    
    private var timer: Timer?
    
    init() {
        setupTimer()
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isAutoCycling else { return }
            self.cycleToNextColor()
        }
    }
    
    private func cycleToNextColor() {
        let pureRed = Color(red: 1, green: 0, blue: 0)  // Pure RGB Red (255,0,0)
        let colors: [Color] = [
            pureRed,
            .green,
            .blue,
            .gray
        ]
        
        if let currentIndex = colors.firstIndex(where: { $0 == activeColor }) {
            let nextIndex = (currentIndex + 1) % colors.count
            DispatchQueue.main.async {
                withAnimation {
                    self.activeColor = colors[nextIndex]
                }
            }
        } else {
            withAnimation {
                self.activeColor = pureRed  // Start with pure red if no match
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
} 