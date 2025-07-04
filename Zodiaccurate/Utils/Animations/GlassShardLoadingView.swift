import SwiftUI

struct GlassShardLoadingView: View {
    @State private var shimmerOffset: CGFloat = -200
    @State private var rotationAngle: Double = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Background glass shard
            GlassShardShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    GlassShardShape()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.white.opacity(0.1), radius: 10, x: 0, y: 0)
                .rotationEffect(.degrees(rotationAngle))
            
            // Shimmering streak
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 60, height: 2)
                .rotationEffect(.degrees(45))
                .offset(x: shimmerOffset)
                .opacity(opacity)
            
            // Cosmic particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 20...180),
                        y: CGFloat.random(in: 20...180)
                    )
                    .opacity(opacity)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1.5...3.0))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: opacity
                    )
            }
            
            // Loading text
            VStack(spacing: 16) {
                Text("Crafting your cosmic insights...")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(opacity)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Shimmer animation
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 200
        }
        
        // Rotation animation
        withAnimation(
            Animation.linear(duration: 8.0)
                .repeatForever(autoreverses: false)
        ) {
            rotationAngle = 360
        }
        
        // Opacity animation
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            opacity = 1.0
        }
    }
}

struct GlassShardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create an irregular glass shard shape
        path.move(to: CGPoint(x: width * 0.1, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.15))
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.3))
        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.6))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.8))
        path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.85))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.7))
        path.addLine(to: CGPoint(x: width * 0.1, y: height * 0.5))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black
        GlassShardLoadingView()
    }
} 