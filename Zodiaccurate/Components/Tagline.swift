//
//  Tagline.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

struct TaglineView: View {
    @State private var line1Offset: CGFloat = -50
    @State private var line2Offset: CGFloat = -50
    @State private var line3Offset: CGFloat = -50
    @State private var line1Opacity: Double = 0
    @State private var line2Opacity: Double = 0
    @State private var line3Opacity: Double = 0
    @State private var verticalLineOpacity: Double = 0
    @State private var verticalLineScale: CGFloat = 0
    @State private var hasAnimatedIn = false
    
    var onReverseAnimation: (() -> Void)?
    @Binding var shouldReverse: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome to Zodiaccurate.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .offset(x: line1Offset)
                    .opacity(line1Opacity)
                
                Text("Life is easier WHEN YOU CAN")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .offset(x: line2Offset)
                    .opacity(line2Opacity)
                
                Text("SEE IT COMING")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: line3Offset)
                    .opacity(line3Opacity)
            }
            
            Rectangle()
                .fill(Color.white)
                .frame(width: 1)
                .frame(height: 60)
                .opacity(verticalLineOpacity)
                .scaleEffect(verticalLineScale, anchor: .bottom)
        }
        .padding(.trailing, 40)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .onAppear {
            animateIn()
        }
        .onChange(of: shouldReverse) { _, shouldReverse in
            if shouldReverse && hasAnimatedIn {
                reverseAnimation()
            }
        }
    }
    
    private func animateIn() {
        // Start with vertical line
        withAnimation(.easeOut(duration: 0.5)) {
            verticalLineOpacity = 1
            verticalLineScale = 1
        }
        
        // Animate first line after vertical line
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.5)) {
                line1Offset = 0
                line1Opacity = 1
            }
        }
        
        // Animate second line
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                line2Offset = 0
                line2Opacity = 1
            }
        }
        
        // Animate third line
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                line3Offset = 0
                line3Opacity = 1
            }
            hasAnimatedIn = true
        }
    }
    
    private func reverseAnimation() {
        guard hasAnimatedIn else { return }
        
        // First, animate text lines out to the left
        withAnimation(.easeIn(duration: 0.4)) {
            line3Offset = -50
            line3Opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.4)) {
                line2Offset = -50
                line2Opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.4)) {
                line1Offset = -50
                line1Opacity = 0
            }
        }
        
        // Finally, animate vertical line out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeIn(duration: 0.4)) {
                verticalLineOpacity = 0
                verticalLineScale = 0
            }
            hasAnimatedIn = false
            onReverseAnimation?()
        }
    }
}

#Preview {
    ZStack {
        Color.black
        TaglineView(shouldReverse: .constant(false))
    }
}
