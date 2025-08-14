import SwiftUI

struct ProgressBar: View {
    var progress: Double // Value between 0.0 and 1.0
    var barHeight: CGFloat = 8
    var backgroundColor: Color = Color.white.opacity(0.15)
    var foregroundColor: Color = Color.purple
    var cornerRadius: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: barHeight)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(foregroundColor)
                    .frame(width: max(geometry.size.width * CGFloat(progress), cornerRadius * 2), height: barHeight)
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
        .frame(height: barHeight)
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBar(progress: 0.25)
        ProgressBar(progress: 0.5, foregroundColor: .blue)
        ProgressBar(progress: 0.75, foregroundColor: .green)
    }
    .padding()
    .background(Color.black)
} 