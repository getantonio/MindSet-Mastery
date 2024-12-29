import Foundation
import AVFoundation
import Combine

protocol AudioManaging: ObservableObject {
    var isRecording: Bool { get }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var currentRecording: Recording? { get }
    var audioLevel: CGFloat { get }
    
    func startRecording(for category: BehaviorCategory)
    func stopRecording() -> URL?
    func startPlayback(recording: Recording)
    func pausePlayback()
    func resumePlayback()
    func stopPlayback()
    func seek(to time: TimeInterval)
}

class AudioManager: NSObject, AudioManaging {
    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var currentRecording: Recording?
    @Published var audioLevel: CGFloat = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var audioLevelTimer: Timer?
    private var captureSession: AVCaptureSession?
    
    override init() {
        super.init()
        checkPermissionsAndSetup()
    }
    
    private func checkPermissionsAndSetup() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("Microphone access granted")
                    self?.setupAudioCapture()
                } else {
                    print("Microphone access denied")
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowMicrophoneAccessAlert"),
                        object: nil
                    )
                }
            }
        }
    }
    
    private func setupAudioCapture() {
        captureSession = AVCaptureSession()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              let captureSession = captureSession else {
            print("Failed to set up audio capture")
            return
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
            print("Audio capture setup successful")
        }
    }
    
    func startRecording(for category: BehaviorCategory) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            beginRecording(for: category)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.beginRecording(for: category)
                    }
                }
            }
        default:
            print("Microphone access not authorized")
            return
        }
    }
    
    private func beginRecording(for category: BehaviorCategory) {
        do {
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let timestamp = Date().timeIntervalSince1970
            let filename = "\(category.name)_\(timestamp).m4a"
            let audioFilename = documentPath.appendingPathComponent(filename)
            
            print("Starting recording to: \(audioFilename.path)")
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startTimer()
            
            // Start monitoring audio levels
            startAudioLevelMonitoring()
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }
    
    private func updateAudioLevel() {
        audioRecorder?.updateMeters()
        let peakPower = audioRecorder?.peakPower(forChannel: 0) ?? -160
        let normalized = (peakPower + 160) / 160
        audioLevel = max(0, min(1, CGFloat(normalized)))
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        let url = audioRecorder?.url
        audioRecorder = nil
        isRecording = false
        stopTimer()
        
        if let url = url {
            print("Recording stopped, file saved at: \(url.path)")
        }
        
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        audioLevel = 0
        
        return url
    }
    
    func startPlayback(recording: Recording) {
        guard let urlString = recording.filePath,
              let url = URL(string: urlString) else {
            print("Invalid recording URL")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentRecording = recording
            isPlaying = true
            duration = audioPlayer?.duration ?? 0
            startTimer()
        } catch {
            print("Playback failed: \(error)")
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