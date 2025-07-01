import SwiftUI

struct LoadingView: View {
    var message: String = "Generating your cosmic welcome..."
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Text(message)
                .font(.title2)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8).ignoresSafeArea())
    }
} 