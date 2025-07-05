import Foundation
import Speech
import AVFoundation
import SwiftUI

class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    
    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = 3.0 // Stop recording after 3 seconds of silence
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    
    // Add this flag
    private var userManuallyStopped = false
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        // Request microphone permission using the new iOS 17+ API
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Microphone access is required for voice input"
                        completion(false)
                    }
                    return
                }
                
                // Request speech recognition permission
                SFSpeechRecognizer.requestAuthorization { [weak self] status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            completion(true)
                        case .denied, .restricted:
                            self?.errorMessage = "Speech recognition access is required for voice input"
                            completion(false)
                        case .notDetermined:
                            // Permission dialog will be shown automatically
                            completion(true)
                        @unknown default:
                            self?.errorMessage = "Unknown authorization status"
                            completion(false)
                        }
                    }
                }
            }
        } else {
            // Fallback for iOS versions prior to 17.0
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Microphone access is required for voice input"
                        completion(false)
                    }
                    return
                }
                
                // Request speech recognition permission
                SFSpeechRecognizer.requestAuthorization { [weak self] status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            completion(true)
                        case .denied, .restricted:
                            self?.errorMessage = "Speech recognition access is required for voice input"
                            completion(false)
                        case .notDetermined:
                            // Permission dialog will be shown automatically
                            completion(true)
                        @unknown default:
                            self?.errorMessage = "Unknown authorization status"
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        // Reset state
        transcribedText = ""
        errorMessage = nil
        userManuallyStopped = false // Reset flag on new recording
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Create and configure recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create speech recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            errorMessage = "Unable to create audio engine"
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            return
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    // If user manually stopped, suppress all errors
                    if self?.userManuallyStopped == true {
                        // Don't show any errors when user manually stops
                        self?.errorMessage = nil
                        self?.transcribedText = ""
                        self?.stopRecording()
                        return
                    }
                    
                    // Handle specific error types
                    if error.localizedDescription.localizedCaseInsensitiveContains("no speech detected") {
                        self?.errorMessage = "Recognition error: No speech detected"
                    } else if error.localizedDescription.localizedCaseInsensitiveContains("cancelled") {
                        // Suppress cancelled errors as they're expected when stopping
                        self?.errorMessage = nil
                    } else {
                        // Other errors
                        self?.errorMessage = "Recognition error: \(error.localizedDescription)"
                    }
                    self?.stopRecording()
                    return
                }
                
                if let result = result {
                    self?.transcribedText = result.bestTranscription.formattedString
                    
                    // Reset silence timer when we get new transcription
                    self?.resetSilenceTimer()
                    
                    if result.isFinal {
                        self?.stopRecording()
                    }
                }
            }
        }
        
        // Start silence timer
        startSilenceTimer()
        
        isRecording = true
    }
    
    func stopRecording(userInitiated: Bool = false) {
        if userInitiated {
            userManuallyStopped = true
        }
        guard isRecording else { return }
        
        // Stop silence timer
        silenceTimer?.invalidate()
        silenceTimer = nil
        
        // Stop audio engine
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Stop recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        // Clear any error messages if user manually stopped
        if userManuallyStopped {
            errorMessage = nil
        }
        
        isRecording = false
    }
    
    private func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopRecording()
            }
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        startSilenceTimer()
    }
    
    func reset() {
        stopRecording()
        transcribedText = ""
        errorMessage = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension SpeechRecognitionService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            if !available {
                self.errorMessage = "Speech recognition is not available"
                self.stopRecording()
            }
        }
    }
} 