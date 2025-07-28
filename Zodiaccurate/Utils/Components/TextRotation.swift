//
//  TextRotation.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

struct TextRotation: View {
    @State private var currentSentenceIndex = 0
    @State private var sentenceTimer: Timer? = nil
    
    private let mysticalLoadingSentences = [
        "Consulting the stars...",
        "Aligning your cosmic energies...",
        "Reading your astral chart...",
        "Whispering to the cosmos...",
        "Gathering celestial insights...",
        "Translating zodiac wisdom...",
        "Peering into the future...",
        "Summoning your horoscope..."
    ]
    
    var body: some View {
        Text(mysticalLoadingSentences[currentSentenceIndex])
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .animation(.easeInOut(duration: 0.5), value: currentSentenceIndex)
            .onAppear {
                startSentenceTimer()
            }
            .onDisappear {
                stopSentenceTimer()
            }
    }
    
    // MARK: - Sentence Timer Management
    private func startSentenceTimer() {
        stopSentenceTimer()
        sentenceTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation {
                currentSentenceIndex = (currentSentenceIndex + 1) % mysticalLoadingSentences.count
            }
        }
    }
    
    private func stopSentenceTimer() {
        sentenceTimer?.invalidate()
        sentenceTimer = nil
        currentSentenceIndex = 0
    }
}

#Preview {
    ZStack {
        Color.black
        TextRotation()
    }
}

