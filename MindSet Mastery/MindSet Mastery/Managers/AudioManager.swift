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
    func setCurrentPlaylist(_ playlist: Playlist?)
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
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setVolume(_ volume: Double) {
        audioPlayer?.volume = Float(volume)
    }
    
    func nextTrack() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let currentPlaylist = self.currentPlaylist,
                  let recordings = currentPlaylist.recordings else {
                self.stopPlayback()
                return
            }
            
            let recordingsArray = Array(recordings).sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
            guard let currentIndex = recordingsArray.firstIndex(where: { $0.id == self.currentRecording?.id }) else {
                if let firstRecording = recordingsArray.first {
                    self.startPlayback(recording: firstRecording)
                }
                return
            }
            
            let nextIndex = (currentIndex + 1) % recordingsArray.count
            self.startPlayback(recording: recordingsArray[nextIndex])
        }
    }
    
    func previousTrack() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let currentPlaylist = self.currentPlaylist,
                  let recordings = currentPlaylist.recordings else {
                self.stopPlayback()
                return
            }
            
            let recordingsArray = Array(recordings).sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
            guard let currentIndex = recordingsArray.firstIndex(where: { $0.id == self.currentRecording?.id }) else {
                if let lastRecording = recordingsArray.last {
                    self.startPlayback(recording: lastRecording)
                }
                return
            }
            
            let previousIndex = (currentIndex - 1 + recordingsArray.count) % recordingsArray.count
            self.startPlayback(recording: recordingsArray[previousIndex])
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let filePath = recording.filePath else { return }
            
            // Ensure audio session is active
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to activate audio session: \(error)")
                return
            }
            
            let url = URL(fileURLWithPath: filePath)
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                self.audioPlayer?.delegate = self
                self.audioPlayer?.prepareToPlay()
                
                if self.audioPlayer?.play() == true {
                    self.currentRecording = recording
                    if self.currentPlaylist == nil {
                        self.currentPlaylist = recording.playlist
                    }
                    self.isPlaying = true
                    self.duration = self.audioPlayer?.duration ?? 0
                    self.startTimer()
                }
            } catch {
                print("Error starting playback: \(error)")
                self.nextTrack()
            }
        }
    }
    
    func pausePlayback() {
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.pause()
            self?.isPlaying = false
            self?.stopTimer()
        }
    }
    
    func resumePlayback() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                self.audioPlayer?.play()
                self.isPlaying = true
                self.startTimer()
            } catch {
                print("Failed to resume playback: \(error)")
            }
        }
    }
    
    func stopPlayback() {
        DispatchQueue.main.async { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
            self?.isPlaying = false
            self?.currentRecording = nil
            self?.stopTimer()
            self?.currentTime = 0
        }
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isRecording {
                self.audioRecorder?.updateMeters()
                let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedLevel = pow(10, level/20)
                self.audioLevel = CGFloat(normalizedLevel)
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
    
    func setCurrentPlaylist(_ playlist: Playlist?) {
        currentPlaylist = playlist
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.isLooping {
                if let currentRecording = self.currentRecording {
                    self.startPlayback(recording: currentRecording)
                }
            } else {
                self.nextTrack()
            }
        }
    }
} 