import SwiftUI

struct ZodiacProfileBadge: View {
    var zodiacImage: Image = Image("Capricorn") // Change as needed
    var body: some View {
        ZStack {
            // Large gradient circle behind
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.6),
                            Color.pink.opacity(0.6),
                            Color.purple.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 10)
            
            // Main black circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 160, height: 160)
            
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        }
        .frame(width: 180, height: 180)
        .padding(.top, 24)
        .padding(.leading, 16)
    }
}

#Preview {
    ZodiacProfileBadge()
} 
