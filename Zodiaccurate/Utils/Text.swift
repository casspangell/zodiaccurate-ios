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
    var line1: String
    var line2: String
    var line3: String
    
    init(line1: String = "Hey there!", line2: String = "How is everything?", line3: String = "What's the latest?") {
        self.line1 = line1
        self.line2 = line2
        self.line3 = line3
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(line1)
                .dmSansSemiboldGradient(size: 38)
                .lineLimit(1)
            
            Text(line2)
                .font(Font.dmSansMedium(size: 32))
                .foregroundColor(.white)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(line3)
                .font(Font.dmSansMedium(size: 24))
                .foregroundColor(.white)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
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

