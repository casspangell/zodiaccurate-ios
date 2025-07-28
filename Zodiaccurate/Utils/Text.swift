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

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HoroscopeDateText(date: "Monday\nJanuary 5, 2025")
            .padding()
    }
}

