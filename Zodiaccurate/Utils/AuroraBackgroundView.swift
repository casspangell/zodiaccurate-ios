import SwiftUI

struct AuroraBackgroundView: View {
    @State private var time: Double = 0
    let colors: [Color] = [
        Color(red: 0.4, green: 0.6, blue: 1.0, opacity: 0.5), // blue
        Color(red: 0.7, green: 0.5, blue: 1.0, opacity: 0.4), // purple
        Color(red: 0.5, green: 0.8, blue: 1.0, opacity: 0.3), // light blue
        Color(red: 0.8, green: 0.6, blue: 1.0, opacity: 0.2)  // light purple
    ]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            AuroraCanvas(now: timeline.date.timeIntervalSinceReferenceDate, colors: colors)
        }
    }
}

struct AuroraCanvas: View {
    let now: Double
    let colors: [Color]
    
    var body: some View {
        Canvas { context, size in
            for i in 0..<6 {
                let phase = now * 0.03 + Double(i) * 0.7
                let baseX = size.width * (0.1 + 0.15 * Double(i))
                let offsetX = sin(phase) * 40
                let x = baseX + offsetX
                
                let baseWidth: CGFloat = 60
                let widthOffset = CGFloat(sin(phase) * 20)
                let streakWidth = baseWidth + widthOffset
                
                let colorIndex = i % colors.count
                let nextColorIndex = (i + 1) % colors.count
                let startColor = colors[colorIndex].opacity(0.7)
                let endColor = colors[nextColorIndex].opacity(0.2)
                
                let gradient = Gradient(colors: [startColor, endColor])
                
                let rect = CGRect(x: x, y: 0, width: streakWidth, height: size.height)
                let path = Path(rect)
                let startPoint = CGPoint(x: x, y: 0)
                let endPoint = CGPoint(x: x, y: size.height)
                
                context.fill(
                    path,
                    with: .linearGradient(gradient, startPoint: startPoint, endPoint: endPoint)
                )
            }
        }
        .ignoresSafeArea()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.07, green: 0.13, blue: 0.25), Color(red: 0.13, green: 0.18, blue: 0.32)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    AuroraBackgroundView()
        .frame(width: 390, height: 844)
} 