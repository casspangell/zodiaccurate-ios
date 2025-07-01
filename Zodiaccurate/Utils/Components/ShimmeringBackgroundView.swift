import SwiftUI

struct ShimmeringBackgroundView: View {
    @State private var shimmerOffset: CGFloat = -300
    @State private var gradientRotation: Double = 0
    @State private var opacity: Double = 0.6
    @State private var particlePositions: [CGPoint] = []
    
    let isAnimating: Bool
    
    init(isAnimating: Bool = true) {
        self.isAnimating = isAnimating
        // Initialize particle positions
        _particlePositions = State(initialValue: (0..<15).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1)
            )
        })
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.1),
                        Color.pink.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(gradientRotation))
                
                // Shimmering overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200, height: geo.size.height)
                    .offset(x: shimmerOffset)
                    .opacity(opacity)
                    .rotationEffect(.degrees(15))
                
                // Floating cosmic particles
                ForEach(0..<15, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 8
                            )
                        )
                        .frame(width: 6, height: 6)
                        .position(
                            x: particlePositions[index].x * geo.size.width,
                            y: particlePositions[index].y * geo.size.height
                        )
                        .opacity(opacity * 0.8)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3.0...6.0))
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
                
                // Subtle wave effect
                WaveShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geo.size.height * 0.3)
                    .offset(y: geo.size.height * 0.7)
                    .opacity(opacity * 0.5)
            }
        }
        .onAppear {
            if isAnimating {
                startAnimations()
            }
        }
        .onChange(of: isAnimating) { oldValue, newValue in
            if newValue {
                startAnimations()
            } else {
                stopAnimations()
            }
        }
    }
    
    private func startAnimations() {
        // Shimmer animation
        withAnimation(
            Animation.linear(duration: 3.0)
                .repeatForever(autoreverses: false)
        ) {
            shimmerOffset = 300
        }
        
        // Gradient rotation
        withAnimation(
            Animation.linear(duration: 20.0)
                .repeatForever(autoreverses: false)
        ) {
            gradientRotation = 360
        }
        
        // Opacity pulse
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            opacity = 1.0
        }
        
        // Particle movement
        withAnimation(
            Animation.easeInOut(duration: 8.0)
                .repeatForever(autoreverses: true)
        ) {
            particlePositions = particlePositions.map { _ in
                CGPoint(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1)
                )
            }
        }
    }
    
    private func stopAnimations() {
        // Reset to static state
        shimmerOffset = 0
        gradientRotation = 0
        opacity = 0.3
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: 0, y: height))
        
        // Create a gentle wave pattern
        for x in stride(from: 0, through: width, by: width / 8) {
            let waveHeight = sin(x / width * 2 * .pi) * 10
            path.addLine(to: CGPoint(x: x, y: height - waveHeight))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black
        ShimmeringBackgroundView(isAnimating: true)
            .frame(height: 300)
    }
} 