import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(Color.utilsBackground)
            .foregroundColor(.white)
            .cornerRadius(30)
    }
}

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
        VStack(spacing: 20) {
            Text("Button Components Preview")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                Text("Primary Gradient Button")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                PrimaryGradientButton(title: "Sign In", action: {})
                PrimaryGradientButton(title: "Continue", action: {})
            }
            
            VStack(spacing: 16) {
                Text("Secondary Button Style")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button("Secondary Action") {}
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Text("Circle Icon Buttons")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    CircleIconButton(
                        systemName: "bell",
                        accessibilityLabel: "Notifications"
                    ) {}
                    
                    CircleIconButton(
                        systemName: "settings",
                        accessibilityLabel: "Settings"
                    ) {}
                    
                    CircleIconButton(
                        systemName: "heart",
                        accessibilityLabel: "Favorites"
                    ) {}
                }
            }
            
            VStack(spacing: 16) {
                Text("Circle Asset Buttons")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    CircleAssetButton(
                        assetName: "Aries",
                        accessibilityLabel: "Aries Sign"
                    ) {}
                    
                    CircleAssetButton(
                        assetName: "Taurus",
                        accessibilityLabel: "Taurus Sign"
                    ) {}
                    
                    CircleAssetButton(
                        assetName: "Gemini",
                        accessibilityLabel: "Gemini Sign"
                    ) {}
                }
            }
        }
        .padding(30)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(hex: "1a1a1a")]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .previewLayout(.sizeThatFits)
    }
}

