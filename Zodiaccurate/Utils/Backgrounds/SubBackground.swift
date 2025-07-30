//
//  SubBackground.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 7/30/25.
//

import SwiftUI

struct SubBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.backgroundPrimary,
                Color.midnightBlue,
                Color.backgroundSecondary
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea(.all, edges: .all)
    }
}

#Preview {
    SubBackground()
}

