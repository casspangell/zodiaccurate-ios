//
//  AudioManager.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio Manager
class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying = false
    @Published var currentAudioKey: String?
    
    private var audioPlayer: AVAudioPlayer?
    private var currentAudioPath: String?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ AudioManager: Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Audio Playback
    
    /// Play audio from a file path
    func playAudio(from filePath: String, for key: String) {
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("❌ AudioManager: Audio file not found at path: \(filePath)")
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            // Stop any currently playing audio
            stopAudio()
            
            // Create new audio player
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // Start playback
            if audioPlayer?.play() == true {
                isPlaying = true
                currentAudioKey = key
                currentAudioPath = filePath
                print("🎵 AudioManager: Started playing audio for key: \(key)")
            } else {
                print("❌ AudioManager: Failed to start audio playback")
            }
        } catch {
            print("❌ AudioManager: Failed to create audio player: \(error)")
        }
    }
    
    /// Play audio for a horoscope
    func playAudio(for horoscope: Horoscope) {
        guard let audioFilePath = horoscope.audioFilePath else {
            print("❌ AudioManager: No audio file path for horoscope with key: \(horoscope.key)")
            return
        }
        
        playAudio(from: audioFilePath, for: horoscope.key)
    }
    
    /// Stop current audio playback
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentAudioKey = nil
        currentAudioPath = nil
        print("🛑 AudioManager: Stopped audio playback")
    }
    
    /// Pause current audio playback
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        print("⏸️ AudioManager: Paused audio playback")
    }
    
    /// Resume current audio playback
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        print("▶️ AudioManager: Resumed audio playback")
    }
    
    /// Toggle audio playback for a horoscope
    func toggleAudio(for horoscope: Horoscope) {
        if isPlaying && currentAudioKey == horoscope.key {
            // If same audio is playing, stop it
            stopAudio()
        } else if isPlaying {
            // If different audio is playing, stop and play new one
            stopAudio()
            playAudio(for: horoscope)
        } else {
            // If nothing is playing, start playback
            playAudio(for: horoscope)
        }
    }
    
    /// Check if audio file exists for a horoscope
    func hasAudio(for horoscope: Horoscope) -> Bool {
        guard let audioFilePath = horoscope.audioFilePath else { return false }
        return FileManager.default.fileExists(atPath: audioFilePath)
    }
    
    /// Get audio duration for a horoscope
    func getAudioDuration(for horoscope: Horoscope) -> TimeInterval? {
        guard let audioFilePath = horoscope.audioFilePath,
              FileManager.default.fileExists(atPath: audioFilePath) else { return nil }
        
        let fileURL = URL(fileURLWithPath: audioFilePath)
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            return audioPlayer.duration
        } catch {
            print("❌ AudioManager: Failed to get audio duration: \(error)")
            return nil
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioKey = nil
            self.currentAudioPath = nil
        }
        print("✅ AudioManager: Audio playback finished successfully")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentAudioKey = nil
            self.currentAudioPath = nil
        }
        print("❌ AudioManager: Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
    }
}
