import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var activeColor: Color = .green
    @Published var isAutoCycling = false
    
    private var timer: Timer?
    private weak var affirmationMixer: AffirmationMixer?
    
    var textColor: Color { activeColor }
    var accentColor: Color { activeColor }
    var glowColor: Color { activeColor.opacity(0.5) }
    var shadowColor: Color { activeColor.opacity(0.3) }
    
    init(affirmationMixer: AffirmationMixer? = nil) {
        self.affirmationMixer = affirmationMixer
        setupTimer()
    }
    
    private func setupTimer() {
        updateTimerInterval()
    }
    
    private func updateTimerInterval() {
        timer?.invalidate()
        
        // Get BPM from mixer or use default
        let bpm = affirmationMixer?.selectedSpeed.rawValue ?? 100
        let interval = 60.0 / bpm  // Convert BPM to seconds
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self, self.isAutoCycling else { return }
            self.cycleToNextColor()
            
            // Update interval if BPM changed
            if let currentBPM = self.affirmationMixer?.selectedSpeed.rawValue,
               interval != 60.0 / currentBPM {
                self.updateTimerInterval()
            }
        }
    }
    
    private func cycleToNextColor() {
        let pureRed = Color(red: 1, green: 0, blue: 0)
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
                self.activeColor = pureRed
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
} 