import SwiftUI

struct ZodiacProfileBadge: View {
    var zodiacImage: Image = Image("Capricorn") // Change as needed
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.0, green: 0.6, blue: 0.2), // orange
                            Color(red: 0.7, green: 0.2, blue: 0.7), // purple
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 180, height: 180)
                .shadow(color: Color.purple.opacity(0.5), radius: 40, x: 0, y: 0)
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