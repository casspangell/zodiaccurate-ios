//
//  TapAnywhere.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

struct TapAnywhere: View {
    @State private var tapHintOpacity: Double = 0.0
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .stroke(Color.gray.opacity(0.6), lineWidth: 2)
                .frame(width: 18, height: 18)
                .scaleEffect(tapHintOpacity > 0.5 ? 1.1 : 1.0)
            Text("Tap anywhere to continue")
                .font(.dmSansMedium13_4)
                .foregroundColor(Color.gray.opacity(0.7))
        }
        .opacity(tapHintOpacity)
        .animation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true),
            value: tapHintOpacity
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                tapHintOpacity = 1.0
            }
        }
        .onDisappear {
            tapHintOpacity = 0.0
        }
    }
}

#Preview {
    TapAnywhere()
        .padding()
}
