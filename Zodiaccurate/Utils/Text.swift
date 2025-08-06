//
//  Text.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/28/25.
//

import SwiftUI

struct HoroscopeDateText: View {
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let lines = date.components(separatedBy: "\n")
            
            if lines.count > 0 {
                Text(lines[0])
                    .dmSansSemiboldGradient(size: 38)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            if lines.count > 1 {
                Text(lines[1])
                    .dmSansSemiboldGradient(size: 24)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}

struct UpdateCardText: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hey there!")
                .dmSansSemiboldGradient(size: 38)
                .lineLimit(1)
            
            Text("How is everything?")
                .font(Font.dmSansMedium(size: 32))
                .foregroundColor(.white)
                .lineLimit(1)
            
            Text("What's the latest?")
                .font(Font.dmSansMedium(size: 24))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HoroscopeDateText(date: "Monday\nJanuary 5, 2025")
            .padding(.bottom, 300)
        UpdateCardText()
    }
}

