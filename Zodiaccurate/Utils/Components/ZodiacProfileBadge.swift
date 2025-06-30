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
                .frame(width: 180, height: 180)
                .blur(radius: 20)
            
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
                .frame(width: 140, height: 140)
            
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

// MARK: - Partial Profile Widget
/// A partial profile widget that shows a cropped portion of the zodiac profile badge
/// This creates a peek-a-boo effect where the badge appears to be partially hidden
struct PartialProfileWidget: View {
    var zodiacImage: Image = Image("Capricorn")
    var size: CGFloat = 120
    var showPercentage: CGFloat = 0.6 // How much of the badge to show (0.0 to 1.0)
    
    var body: some View {
        ZStack {
            // Large gradient circle behind (partial)
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
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: 15)
                .offset(x: -size * 0.25, y: 0) // Offset to show partial view
            
            // Main black circle (partial)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8)
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.17, height: size * 1.17)
                .offset(x: -size * 0.08, y: 0) // Offset to show partial view
            
            // Zodiac image (partial)
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .offset(x: -size * 0.08, y: 0) // Offset to show partial view
        }
        .frame(width: size * showPercentage, height: size)
        .clipped() // Clip the view to show only the partial amount
        .padding(.top, 16)
        .padding(.leading, 8)
    }
}

// MARK: - Compact Profile Widget
/// A more compact version of the partial profile widget
struct CompactProfileWidget: View {
    var zodiacImage: Image = Image("Capricorn")
    var size: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Gradient background (smaller and more subtle)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.4),
                            Color.pink.opacity(0.4),
                            Color.purple.opacity(0.4)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: 10)
                .offset(x: -size * 0.15, y: 0)
            
            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7)
                        ]),
                        center: .center,
                        startRadius: 3,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .offset(x: -size * 0.1, y: 0)
            
            // Zodiac image
            zodiacImage
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.85, height: size * 0.85)
                .clipShape(Circle())
                .offset(x: -size * 0.1, y: 0)
        }
        .frame(width: size * 0.7, height: size)
        .clipped()
        .padding(.top, 12)
        .padding(.leading, 6)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Full Profile Badge")
            .foregroundColor(.white)
        ZodiacProfileBadge()
        
        Text("Partial Profile Widget")
            .foregroundColor(.white)
        PartialProfileWidget()
        
        Text("Compact Profile Widget")
            .foregroundColor(.white)
        CompactProfileWidget()
    }
    .background(Color.black)
    .padding()
} 
