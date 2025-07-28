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
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        TaglineView()
    }
}
