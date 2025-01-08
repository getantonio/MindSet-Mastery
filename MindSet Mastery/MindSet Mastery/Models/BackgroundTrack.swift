import Foundation

enum BackgroundTrack: String, CaseIterable {
    case calm = "ambient_calm"
    case energetic = "upbeat_energy"
    case spiritual = "deep_meditation"
    case nature = "forest_sounds"
    case cosmic = "space_harmony"
    
    var url: URL? {
        Bundle.main.url(forResource: self.rawValue, withExtension: "mp3")
    }
}

// Add this extension for testing
extension BackgroundTrack {
    static func verifyAudioFiles() {
        for track in BackgroundTrack.allCases {
            if let url = track.url {
                print("Found audio file for \(track.rawValue): \(url)")
            } else {
                print("⚠️ Missing audio file for \(track.rawValue)")
            }
        }
    }
} 