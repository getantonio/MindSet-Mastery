import Foundation
import AVFoundation
import AVKit
import MediaPlayer
import Combine
import CoreData
#if os(iOS)
import UIKit
#else
import AppKit
#endif

protocol AudioManaging: ObservableObject {
    var isRecording: Bool { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var currentRecording: Recording? { get }
    var currentPlaylist: Playlist? { get }
    var isLooping: Bool { get }
    var audioLevel: CGFloat { get }
    
    func startRecording(for category: BehaviorCategory)
    func stopRecording() -> URL?
    func startPlayback(recording: Recording)
    func pausePlayback()
    func resumePlayback()
    func stopPlayback()
    func seek(to time: TimeInterval)
    func setVolume(_ volume: Double)
    func nextTrack()
    func previousTrack()
}

class AudioManager: NSObject, AudioManaging {
    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var currentRecording: Recording?
    @Published private(set) var currentPlaylist: Playlist?
    @Published var isLooping = false
    @Published var audioLevel: CGFloat = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var currentURL: URL?
    
    override init() {
        super.init()
        setupVolumeControl()
    }
    
    private func setupVolumeControl() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            #if os(iOS)
            // Set up system volume control
            let volumeView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 0, height: 0))
            
            // Use AVRoutePickerView for modern route selection
            if #available(iOS 13.0, *) {
                let routePicker = AVRoutePickerView(frame: CGRect.zero)
                routePicker.isHidden = true  // Hide but keep functional
            } else {
                volumeView.showsRouteButton = false
            }
            #endif
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func setVolume(_ volume: Double) {
        audioPlayer?.volume = Float(volume)
    }
    
    func nextTrack() {
        guard let currentPlaylist = currentPlaylist,
              let recordings = currentPlaylist.recordings else {
            return
        }
        
        let recordingsArray = Array(recordings).sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
        guard let currentIndex = recordingsArray.firstIndex(where: { $0.id == currentRecording?.id }) else {
            return
        }
        
        let nextIndex = (currentIndex + 1) % recordingsArray.count
        startPlayback(recording: recordingsArray[nextIndex])
    }
    
    func previousTrack() {
        guard let currentPlaylist = currentPlaylist,
              let recordings = currentPlaylist.recordings else {
            return
        }
        
        let recordingsArray = Array(recordings).sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
        guard let currentIndex = recordingsArray.firstIndex(where: { $0.id == currentRecording?.id }) else {
            return
        }
        
        let previousIndex = (currentIndex - 1 + recordingsArray.count) % recordingsArray.count
        startPlayback(recording: recordingsArray[previousIndex])
    }
    
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func startRecording(for category: BehaviorCategory) {
        print("Starting new recording for category: \(category.name)")
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        // Check permission before recording
        requestMicrophonePermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.beginRecording(for: category)
            } else {
                print("Microphone permission denied")
            }
        }
    }
    
    private func beginRecording(for category: BehaviorCategory) {
        // Always stop any existing recording first
        if isRecording {
            print("Stopping existing recording before starting new one")
            _ = stopRecording()
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
        print("New recording path: \(audioFilename.path)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            if audioRecorder?.record() == true {
                currentURL = audioFilename
                isRecording = true
                print("Recording started successfully")
                startTimer()
            } else {
                print("Failed to start recording")
            }
        } catch {
            print("Error setting up recording: \(error)")
        }
    }
    
    func stopRecording() -> URL? {
        guard isRecording, let recorder = audioRecorder else {
            print("No active recording to stop")
            return nil
        }
        
        print("Stopping recording...")
        recorder.stop()
        let url = currentURL
        
        // Clean up
        audioRecorder = nil
        currentURL = nil
        isRecording = false
        stopTimer()
        
        if let url = url {
            print("Recording stopped, file saved at: \(url.path)")
        }
        
        return url
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func startPlayback(recording: Recording) {
        guard let filePath = recording.filePath else { return }
        let url = URL(fileURLWithPath: filePath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            if audioPlayer?.play() == true {
                currentRecording = recording
                currentPlaylist = recording.playlist
                isPlaying = true
                duration = audioPlayer?.duration ?? 0
                startTimer()
            }
        } catch {
            print("Error starting playback: \(error)")
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentRecording = nil
        stopTimer()
        currentTime = 0
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isRecording {
                self.currentTime = self.audioRecorder?.currentTime ?? 0
            } else if self.isPlaying {
                self.currentTime = self.audioPlayer?.currentTime ?? 0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        stopTimer()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentRecording = nil
        stopTimer()
        currentTime = 0
    }
} 