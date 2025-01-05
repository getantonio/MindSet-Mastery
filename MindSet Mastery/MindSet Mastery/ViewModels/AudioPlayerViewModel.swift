import Foundation
import SwiftUI
import Combine

class AudioPlayerViewModel: ObservableObject {
    static let shared = AudioPlayerViewModel()
    @Published var audioManager = AudioManager()
    
    private init() {}
} 