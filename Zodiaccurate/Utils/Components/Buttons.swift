import SwiftUI

struct PrimaryGradientButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .poppinsMediumButton(size: 17)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .textCase(.uppercase)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// Circular icon button with indigo-sapphire gradient background
struct CircleIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.sapphire]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                // Icon
                Image(systemName: systemName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4F8CFF"), Color(hex: "B39DDB")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .frame(width: 40, height: 40)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        .accessibilityLabel(accessibilityLabel)
    }
}

// Outlined circular asset image button
struct CircleAssetButton: View {
    let assetName: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .padding(9)
                .background(Color.clear)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                )
        }
        .frame(width: 40, height: 40)
        .accessibilityLabel(accessibilityLabel)
    }
}

// Preview
struct PrimaryGradientButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryGradientButton(title: "Sign In", action: {})
            .padding()
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
} 